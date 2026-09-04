import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/utils/certificate_downloader.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/quiz_program_pages/play_quiz_page.dart';
import 'package:coders_adda_app/views/test_program_pages/test_instructions_page.dart';
import 'package:coders_adda_app/views/test_program_pages/join_test_quiz_page.dart';
import 'package:coders_adda_app/views/test_program_pages/available_tests_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  List<Map<String, dynamic>> _availableQuizzes = [];
  List<Map<String, dynamic>> _attemptedQuizzes = [];
  bool _isLoadingQuizzes = true;
  bool _isLoadingAttempts = true;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchQuizzes();
    _fetchAttemptedQuizzes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _openInstructions(Map<String, dynamic> quiz) async {
    final targetQuizId = quiz['id'] ?? quiz['quizId'];
    final int attemptedIndex = _attemptedQuizzes.indexWhere((a) => a['quizId'] == targetQuizId);
    
    if (attemptedIndex != -1) {
      _showAttemptDetailsDialog(_attemptedQuizzes[attemptedIndex]);
      return;
    }

    DateTime? scheduledTime;
    if (quiz['scheduledStartTime'] != null) {
      scheduledTime = DateTime.tryParse(quiz['scheduledStartTime'].toString())?.toLocal();
    }
    
    if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = scheduledTime.hour > 12 ? scheduledTime.hour - 12 : (scheduledTime.hour == 0 ? 12 : scheduledTime.hour);
      final ampm = scheduledTime.hour >= 12 ? 'PM' : 'AM';
      final minute = scheduledTime.minute.toString().padLeft(2, '0');
      final formatted = '${scheduledTime.day} ${months[scheduledTime.month - 1]} ${scheduledTime.year}, ${hour.toString().padLeft(2, '0')}:$minute $ampm';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quiz hasn't started yet. Starts on: $formatted"),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final bool? completed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestInstructionsPage(
          quiz: quiz,
          isQuiz: true,
        ),
      ),
    );

    if (completed == true) {
      _fetchQuizzes();
      _fetchAttemptedQuizzes();
    }
  }

  void _joinWithCode(String code) {
    if (code.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinTestQuizPage(
            availableQuizzes: _availableQuizzes,
            attemptedQuizzes: _attemptedQuizzes,
            isQuiz: true,
          ),
        ),
      ).then((val) {
        if (val == true) {
          _fetchQuizzes();
          _fetchAttemptedQuizzes();
        }
      });
      return;
    }

    final quiz = _availableQuizzes.firstWhere(
      (q) {
        final c1 = (q['quizCode'] ?? '').toString().trim().toLowerCase();
        final c2 = (q['testCode'] ?? '').toString().trim().toLowerCase();
        final input = code.trim().toLowerCase();
        return c1 == input || c2 == input;
      },
      orElse: () => {},
    );

    if (quiz.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Invalid quiz code. Please check and try again."),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final bool hasAttempted = _attemptedQuizzes.any((a) => a['quizId'] == quiz['id']);
    if (hasAttempted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("You have already attempted this quiz."),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }

    _codeController.clear();
    _openInstructions(quiz);
  }

  Future<void> _fetchAttemptedQuizzes() async {
    try {
      final response = await _apiClient.get(ApiUrls.getMyQuizAttempts);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        if (mounted) {
          setState(() {
            _attemptedQuizzes = data.where((a) {
              final quiz = a['quizId'];
              if (quiz == null) return false;
              final type = quiz['type'] ?? 'Quiz';
              return type == 'Quiz';
            }).map((a) {
              final quiz = a['quizId'] ?? {};
              final points = quiz['points'] ?? 1;
              return {
                'id': a['_id'],
                'quizId': quiz['_id'] ?? '',
                'duration': quiz['duration'] ?? 0,
                'title': quiz['title'] ?? 'Daily Quiz',
                'score': (a['marks'] ?? 0) as int,
                'total': (a['totalMarks'] ?? 0) as int,
                'date': a['createdAt'] != null ? a['createdAt'].toString().substring(0, 10) : '',
                'timeTaken': _formatDuration(a['duration'] ?? 0),
                'correct': ((a['marks'] ?? 0) ~/ points),
                'totalQuestions': ((a['totalMarks'] ?? 0) ~/ points),
                'certificateUrl': a['certificateUrl'],
              };
            }).toList();
            _isLoadingAttempts = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingAttempts = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAttempts = false);
    }
  }

  String _formatDuration(dynamic seconds) {
    if (seconds == null) return '0:00';
    final int sec = seconds is int ? seconds : int.tryParse(seconds.toString()) ?? 0;
    final int minutes = sec ~/ 60;
    final int remainingSec = sec % 60;
    return '${minutes}:${remainingSec.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchQuizzes() async {
    try {
      final response = await _apiClient.get('${ApiUrls.getQuizzes}?courseId=general&type=Quiz');
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        if (mounted) {
          setState(() {
            _availableQuizzes = data.map((q) => {
              'id': q['_id'],
              'title': q['title'] ?? 'Daily Quiz',
              'description': q['description'] ?? '',
              'questions': q['totalQuestions'] ?? 0,
              'time': '${q['duration'] ?? 0} mins',
              'duration': q['duration'] ?? 0,
              'difficulty': q['level'] ?? 'Beginner',
              'points': q['points'] ?? 0,
              'quizCode': q['quizCode'] ?? '',
              'testCode': q['quizCode'] ?? '',
              'type': 'Quiz',
              'scheduledStartTime': q['scheduledStartTime'],
            }).toList();
            _isLoadingQuizzes = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingQuizzes = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingQuizzes = false);
    }
  }

  void _showAttemptDetailsDialog(Map<String, dynamic> attempt) {
    final score = attempt['score'] as int;
    final total = attempt['total'] as int;
    final percentage = total > 0 ? (score / total) * 100 : 0.0;
    final isPassed = percentage >= 50.0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          bool certLoading = false;

          return AlertDialog(
            backgroundColor: const Color(0xFF0F0C24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Center(
              child: Text(
                attempt['title'] as String,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                _buildDialogRow("Status:", isPassed ? "PASSED" : "FAILED", isPassed ? const Color(0xFF00FFCC) : Colors.redAccent),
                const SizedBox(height: 8),
                _buildDialogRow("Score:", "$score / $total points", Colors.white),
                const SizedBox(height: 8),
                _buildDialogRow("Percentage:", "${percentage.toStringAsFixed(1)}%", isPassed ? const Color(0xFF00FFCC) : Colors.redAccent),
                const SizedBox(height: 8),
                _buildDialogRow("Correct Answers:", "${attempt['correct']} / ${attempt['totalQuestions']}", Colors.white),
                const SizedBox(height: 8),
                _buildDialogRow("Time Taken:", attempt['timeTaken'] as String, Colors.white),
                const SizedBox(height: 8),
                _buildDialogRow("Attempt Date:", attempt['date'] as String, Colors.white),
              ],
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPassed) ...[
                    ElevatedButton.icon(
                      onPressed: certLoading
                          ? null
                          : () async {
                              final currentUrl = attempt['certificateUrl'] as String?;
                              if (currentUrl != null && currentUrl.isNotEmpty) {
                                await CertificateDownloader.downloadAndSave(context, currentUrl);
                              } else {
                                setDialogState(() => certLoading = true);
                                try {
                                  final response = await _apiClient.post(
                                    ApiUrls.issueQuizCertificate,
                                    {'attemptId': attempt['id']},
                                  );
                                  if (response != null && response['success'] == true) {
                                    final generatedUrl = response['data']?['certificateUrl'];
                                    setDialogState(() => certLoading = false);
                                    if (generatedUrl != null && mounted) {
                                      setState(() => attempt['certificateUrl'] = generatedUrl);
                                      await CertificateDownloader.downloadAndSave(context, generatedUrl);
                                    }
                                  } else {
                                    setDialogState(() => certLoading = false);
                                  }
                                } catch (_) {
                                  setDialogState(() => certLoading = false);
                                }
                              }
                            },
                      icon: certLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.workspace_premium, color: Colors.white),
                      label: Text(certLoading ? "Generating..." : "Download Certificate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B87C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("Close", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
      case 'expert':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF0033CC);
    }
  }

  Color _getLevelBgColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFFECFDF5);
      case 'intermediate':
        return const Color(0xFFFFFBEB);
      case 'advanced':
      case 'expert':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData _getTopicIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('c++') || t.contains('cpp')) {
      return Icons.code;
    } else if (t.contains('data') || t.contains('structure') || t.contains('dsa')) {
      return Icons.layers;
    } else if (t.contains('web')) {
      return Icons.language;
    } else if (t.contains('python')) {
      return Icons.terminal;
    }
    return Icons.psychology;
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Flexible Schedule';
    final parsed = DateTime.tryParse(dateStr)?.toLocal();
    if (parsed == null) return 'Flexible Schedule';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour);
    final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}, ${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1033)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF0033CC)),
            tooltip: 'All Available Quizzes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvailableTestsPage(
                    testsList: _availableQuizzes,
                    attemptedList: _attemptedQuizzes,
                    initialCategory: 'Quizzes',
                  ),
                ),
              ).then((val) {
                if (val == true) {
                  _fetchQuizzes();
                  _fetchAttemptedQuizzes();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen 1 Header Banner with Trophy
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizer.deviceWidth4,
                AppSizer.deviceHeight1_5,
                AppSizer.deviceWidth4,
                AppSizer.deviceHeight1,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CodersAdda\nDaily Quizzes',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0033CC),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),
                        Text(
                          'Test your skills, track your progress and level up your learning!',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth2),
                  // Golden Trophy Illustration with glow
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFEF3C7),
                          Color(0xFFEFF6FF),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 8,
                          right: 12,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF38BDF8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 10,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.emoji_events_rounded,
                          size: 48,
                          color: Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Join Test / Quiz Using Code Card
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight1,
              ),
              padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0033CC).withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Quiz Using Code',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B1033),
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),
                        Text(
                          'Enter the code provided by your instructor.',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _codeController,
                                  textCapitalization: TextCapitalization.characters,
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0B1033),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter quiz code',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: AppSizer.deviceSp12,
                                    ),
                                    prefixIcon: const Icon(Icons.code_rounded, size: 18, color: Color(0xFF0033CC)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSizer.deviceWidth2),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () => _joinWithCode(_codeController.text.trim()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0033CC),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Join Now',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_rounded, size: 15),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth2_5),
                  // Decorative right container </>
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0033CC).withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '</>',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0033CC),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar with Pill Buttons
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight1,
              ),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTabPill('Available Quizzes', 0),
                  const SizedBox(width: 4),
                  _buildTabPill('Attempted Quizzes', 1),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight1),

            // Tab Content
            _tabController.index == 0
                ? _buildAvailableList()
                : _buildAttemptedList(),

            SizedBox(height: AppSizer.deviceHeight4),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String title, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0033CC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0033CC).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableList() {
    if (_isLoadingQuizzes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xFF0033CC)),
        ),
      );
    }

    if (_availableQuizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.quiz_outlined, size: 54, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No Quizzes Available',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      itemCount: _availableQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = _availableQuizzes[index];
        final title = quiz['title'] as String;
        final level = quiz['difficulty'] as String;
        final qCount = quiz['questions'] ?? 10;
        final duration = quiz['duration'] ?? 15;
        final points = quiz['points'] ?? (qCount * 1);
        final dateStr = quiz['scheduledStartTime']?.toString() ?? '';

        final badgeColor = _getLevelColor(level);
        final badgeBgColor = _getLevelBgColor(level);

        DateTime? scheduledTime;
        if (quiz['scheduledStartTime'] != null) {
          scheduledTime = DateTime.tryParse(quiz['scheduledStartTime'].toString())?.toLocal();
        }
        final bool isLocked = scheduledTime != null && scheduledTime.isAfter(DateTime.now());

        return Container(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openInstructions(quiz),
              child: Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic Icon Container
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _getTopicIcon(title),
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth3),

                        // Title & Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0B1033),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: badgeBgColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      level,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp11,
                                        fontWeight: FontWeight.bold,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSizer.deviceHeight0_5),
                              Row(
                                children: [
                                  Icon(Icons.calendar_month, size: 14, color: const Color(0xFF0033CC)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(dateStr),
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Stats Row
                    Row(
                      children: [
                        _buildCardStat(Icons.article_outlined, '$qCount Qs'),
                        const SizedBox(width: 14),
                        _buildCardStat(Icons.timer_outlined, '$duration mins'),
                        const SizedBox(width: 14),
                        _buildCardStat(Icons.emoji_events_outlined, '$points pts'),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight1_5),

                    // Start Quiz Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => _openInstructions(quiz),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLocked ? Colors.grey.shade400 : const Color(0xFF0033CC),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLocked) ...[
                              const Icon(Icons.lock_clock, size: 16),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              isLocked ? 'Scheduled Quiz' : 'Start Quiz',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isLocked) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptedList() {
    if (_isLoadingAttempts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xFF0033CC)),
        ),
      );
    }

    if (_attemptedQuizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 54, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No Attempted Quizzes Yet',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      itemCount: _attemptedQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = _attemptedQuizzes[index];
        final score = quiz['score'] as int;
        final total = quiz['total'] as int;
        final percentage = total > 0 ? (score / total) * 100 : 0.0;
        final isPassed = percentage >= 50.0;

        return Container(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAttemptDetailsDialog(quiz),
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quiz['title'] as String,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B1033),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPassed ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp11,
                            color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  LinearProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $score / $total pts',
                        style: TextStyle(fontSize: AppSizer.deviceSp11, color: Colors.grey.shade600),
                      ),
                      Text(
                        'Date: ${quiz['date']}',
                        style: TextStyle(fontSize: AppSizer.deviceSp11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}