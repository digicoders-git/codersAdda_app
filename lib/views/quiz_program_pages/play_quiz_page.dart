import 'dart:async';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/utils/certificate_downloader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/views/quiz_program_pages/quiz_review_page.dart';

class PlayQuizPage extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final int totalDurationMinutes;

  const PlayQuizPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.totalDurationMinutes,
  });

  @override
  State<PlayQuizPage> createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;

  // Key is question index, value is selected option ('a', 'b', 'c', 'd')
  final Map<int, String> _userAnswers = {};

  // Timer variables
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.totalDurationMinutes * 60;
    _fetchQuizDetails();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchQuizDetails() async {
    try {
      final response = await _apiClient.get('${ApiUrls.getQuizzes}/${widget.quizId}');
      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        
        // Extract topic questions
        List<dynamic> topicQuestions = [];
        if (data['questionTopicId'] != null && data['questionTopicId']['questions'] != null) {
          topicQuestions = List.from(data['questionTopicId']['questions']);
        }

        // Extract custom manual questions
        List<dynamic> customQuestions = [];
        if (data['customQuestions'] != null) {
          customQuestions = List.from(data['customQuestions']);
        }

        // Merge questions
        setState(() {
          _questions = [...topicQuestions, ...customQuestions];
          _isLoading = false;
        });

        if (_questions.isEmpty) {
          setState(() {
            _errorMessage = "This quiz has no questions available.";
          });
        } else {
          _startTimer();
        }
      } else {
        setState(() {
          _errorMessage = response?['message'] ?? "Failed to load quiz details.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _autoSubmitQuiz();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _autoSubmitQuiz() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Time is up! Submitting your answers automatically..."),
        backgroundColor: Colors.orange,
      ),
    );
    _submitQuiz();
  }

  Future<void> _submitQuiz() async {
    _timer.cancel();
    setState(() => _isLoading = true);

    try {
      // Format answers as list of {questionId, selectedOption}
      final List<Map<String, dynamic>> answersPayload = [];
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final String? selected = _userAnswers[i];
        if (selected != null) {
          answersPayload.add({
            'questionId': question['_id'].toString(),
            'selectedOption': selected,
          });
        }
      }

      final int timeTakenSeconds = (widget.totalDurationMinutes * 60) - _secondsRemaining;

      final response = await _apiClient.post(ApiUrls.submitQuizAttempt, {
        'quizId': widget.quizId,
        'duration': timeTakenSeconds,
        'answers': answersPayload,
      });

      setState(() => _isLoading = false);

      if (response != null && response['success'] == true) {
        final attemptData = response['data'] ?? {};
        final int marksObtained = attemptData['marks'] ?? 0;
        final int totalMarks = attemptData['totalMarks'] ?? 0;

        // certificateUrl from backend (may be null if Render storage issue)
        final bool certIssued = attemptData['certificateIssued'] ?? false;
        final String? certUrl = certIssued && attemptData['certificateDetails'] != null
            ? attemptData['certificateDetails']['certificateUrl']
            : null;

        _showResultDialog(marksObtained, totalMarks, certificateUrl: certUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? "Failed to submit quiz"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResultDialog(int score, int totalScore, {String? certificateUrl}) {
    final double percentage = totalScore > 0 ? (score / totalScore) * 100 : 0.0;
    final bool isPassed = score > 0; // Any score > 0 earns a certificate
    bool certLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF0F0C24),
            title: Center(
              child: Icon(
                isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: isPassed ? const Color(0xFFFFD700) : Colors.redAccent,
                size: AppSizer.deviceSp48,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPassed ? "Congratulations!" : "Keep Practicing!",
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "You scored",
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$score / $totalScore",
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${percentage.toStringAsFixed(1)}% Score",
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? const Color(0xFF00FFCC) : Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  isPassed
                      ? "Great job! You have successfully completed this quiz."
                      : "Try again to score higher next time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Certificate Button - show if user scored any marks
                  if (isPassed) ...[                    
                    ElevatedButton.icon(
                      onPressed: certLoading
                          ? null
                          : () async {
                              if (certificateUrl != null && certificateUrl.isNotEmpty) {
                                // Direct download if we already have URL
                                _downloadCertificate(certificateUrl);
                              } else {
                                // Issue and download from backend
                                setDialogState(() => certLoading = true);
                                final url = await _issueCertificate(score, totalScore);
                                setDialogState(() => certLoading = false);
                                 if (url != null) {
                                  _downloadCertificate(url);
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Certificate not available for this quiz yet. Please contact admin."),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      icon: certLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.workspace_premium, color: Colors.white),
                      label: Text(certLoading ? "Generating..." : "Download Certificate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B87C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Close dialog
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (context) => QuizReviewPage(
                            questions: _questions,
                            userAnswers: _userAnswers,
                          ),
                        ),
                      ).then((_) {
                        Navigator.pop(this.context, true); // Close quiz page when returning
                      });
                    },
                    icon: const Icon(Icons.rate_review, color: Color(0xFFFFD700)),
                    label: const Text("Review Answers"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFD700),
                      side: const BorderSide(color: Color(0xFFFFD700)),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Pop Dialog
                      Navigator.pop(this.context, true); // Return to Quiz Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Issue certificate from backend and return the download URL
  Future<String?> _issueCertificate(int score, int totalScore) async {
    try {
      final response = await _apiClient.post(ApiUrls.issueQuizCertificate, {
        'quizId': widget.quizId,
        'totalScore': '$score / $totalScore',
      });
      if (response != null && response['success'] == true) {
        return response['certificate']?['certificateUrl'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Certificate issue error: $e');
      return null;
    }
  }

  Future<void> _downloadCertificate(String urlString) async {
    await CertificateDownloader.downloadAndSave(context, urlString);
  }

  void _onOptionSelected(String optionKey) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = optionKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0C24),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0C24),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.quizTitle, style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final questionText = currentQuestion['question'] ?? '';
    final options = currentQuestion['options'] ?? {};
    final String? selectedOption = _userAnswers[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15122E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Confirm exit dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Exit Quiz?"),
                content: const Text("Your progress will be lost. Are you sure you want to exit?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Pop dialog
                      Navigator.pop(context); // Pop quiz page
                    },
                    child: const Text("Exit", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          widget.quizTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Timer Widget
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsRemaining < 60 ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _secondsRemaining < 60 ? Colors.red : Colors.white24,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: _secondsRemaining < 60 ? Colors.red : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        color: _secondsRemaining < 60 ? Colors.red : Colors.white,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Number Count
                  Text(
                    "QUESTION ${_currentQuestionIndex + 1} OF ${_questions.length}",
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Question Text
                  Text(
                    questionText,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Option list
                  _buildOptionCard('a', options['a'] ?? '', selectedOption),
                  _buildOptionCard('b', options['b'] ?? '', selectedOption),
                  _buildOptionCard('c', options['c'] ?? '', selectedOption),
                  _buildOptionCard('d', options['d'] ?? '', selectedOption),
                ],
              ),
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Color(0xFF15122E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                if (_currentQuestionIndex > 0)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios, size: 14),
                        SizedBox(width: 5),
                        Text("Prev"),
                      ],
                    ),
                  )
                else
                  const SizedBox(),

                // Next or Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < _questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    } else {
                      // Submit Quiz confirmation
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Submit Quiz?"),
                          content: const Text("Are you sure you want to finish and submit your answers?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Pop dialog
                                _submitQuiz();
                              },
                              child: const Text("Submit", style: TextStyle(color: Color(0xFFFFD700))),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0F0C24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _currentQuestionIndex < _questions.length - 1 ? "Next" : "Submit",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      if (_currentQuestionIndex < _questions.length - 1)
                        const Icon(Icons.arrow_forward_ios, size: 14)
                      else
                        const Icon(Icons.check, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String key, String optionText, String? selectedKey) {
    final bool isSelected = selectedKey == key;
    
    return GestureDetector(
      onTap: () => _onOptionSelected(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1A3D) : const Color(0xFF15122E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Option Letter Icon/Indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  key.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0F0C24) : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            
            // Option Text
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp15,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
