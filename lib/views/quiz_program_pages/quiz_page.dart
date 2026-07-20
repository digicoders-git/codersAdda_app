import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/quiz_program_pages/play_quiz_page.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _availableQuizzes = [];
  List<Map<String, dynamic>> _attemptedQuizzes = [];
  bool _isLoadingQuizzes = true;
  bool _isLoadingAttempts = true;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchQuizzes();
    _fetchAttemptedQuizzes();
  }

  void _startQuiz(Map<String, dynamic> quiz) async {
    final bool? completed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayQuizPage(
          quizId: quiz['id'] as String,
          quizTitle: quiz['title'] as String,
          totalDurationMinutes: quiz['duration'] as int,
        ),
      ),
    );

    if (completed == true) {
      _fetchQuizzes();
      _fetchAttemptedQuizzes();
    }
  }

  void _joinQuizWithCode(String code) {
    final quiz = _availableQuizzes.firstWhere(
      (q) => q['quizCode'].toString().trim().toLowerCase() == code.trim().toLowerCase(),
      orElse: () => {},
    );

    if (quiz.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid quiz code. Please check and try again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _startQuiz(quiz);
  }

  Future<void> _fetchAttemptedQuizzes() async {
    try {
      final response = await _apiClient.get(ApiUrls.getMyQuizAttempts);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _attemptedQuizzes = data.map((a) {
            final quiz = a['quizId'] ?? {};
            final points = quiz['points'] ?? 1;
            return {
              'id': a['_id'],
              'quizId': quiz['_id'] ?? '',
              'duration': quiz['duration'] ?? 0,
              'title': quiz['title'] ?? 'Unknown Quiz',
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
      } else {
        setState(() => _isLoadingAttempts = false);
      }
    } catch (e) {
      setState(() => _isLoadingAttempts = false);
    }
  }

  String _formatDuration(dynamic seconds) {
    if (seconds == null) return '0:00';
    final int sec = seconds is int ? seconds : int.tryParse(seconds.toString()) ?? 0;
    final int minutes = sec ~/ 60;
    final int remainingSec = sec % 60;
    return '${minutes}:${remainingSec.toString().padLeft(2, '0')}';
  }

  void _showAttemptDetailsDialog(Map<String, dynamic> attempt) {
    final score = attempt['score'] as int;
    final total = attempt['total'] as int;
    final percentage = total > 0 ? (score / total) * 100 : 0.0;
    final isPassed = percentage >= 50.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0C24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status:", style: TextStyle(color: Colors.white70)),
                Text(
                  isPassed ? "PASSED" : "FAILED",
                  style: TextStyle(
                    color: isPassed ? const Color(0xFF00FFCC) : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Score:", style: TextStyle(color: Colors.white70)),
                Text(
                  "$score / $total points",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Percentage:", style: TextStyle(color: Colors.white70)),
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: isPassed ? const Color(0xFF00FFCC) : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Correct Answers:", style: TextStyle(color: Colors.white70)),
                Text(
                  "${attempt['correct']} / ${attempt['totalQuestions']}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Time Taken:", style: TextStyle(color: Colors.white70)),
                Text(
                  attempt['timeTaken'] as String,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Attempt Date:", style: TextStyle(color: Colors.white70)),
                Text(
                  attempt['date'] as String,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (attempt['certificateUrl'] != null) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    _downloadCertificate(attempt['certificateUrl'] as String);
                  },
                  icon: const Icon(Icons.workspace_premium, color: Colors.white),
                  label: const Text("Download Certificate"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _downloadCertificate(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open certificate download link")),
        );
      }
    } catch (e) {
      debugPrint("Error launching url: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _fetchQuizzes() async {
    try {
      final response = await _apiClient.get(ApiUrls.getQuizzes);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _availableQuizzes = data.map((q) => {
            'id': q['_id'],
            'title': q['title'] ?? 'Unknown Quiz',
            'description': q['description'] ?? '',
            'questions': q['totalQuestions'] ?? 0,
            'time': '${q['duration'] ?? 0} mins',
            'duration': q['duration'] ?? 0,
            'difficulty': q['level'] ?? 'Beginner',
            'points': q['points'] ?? 0,
            'quizCode': q['quizCode'] ?? '',
          }).toList();
          _isLoadingQuizzes = false;
        });
      } else {
        setState(() => _isLoadingQuizzes = false);
      }
    } catch (e) {
      setState(() => _isLoadingQuizzes = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showJoinQuizDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
          ),
          title: Text(
            'Join Quiz with Code',
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the quiz code provided by your instructor',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight3),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Enter quiz code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                Navigator.pop(context);
                if (code.isNotEmpty) {
                  _joinQuizWithCode(code);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                ),
              ),
              child: Text(
                'Join Quiz',
                style: TextStyle(fontSize: AppSizer.deviceSp14),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth5,
                vertical: AppSizer.deviceHeight2,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: AppSizer.deviceWidth1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CodersAdda Quizzes',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Text(
                    'Test your programming skills',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Join Quiz Card
            Container(
              margin: EdgeInsets.all(AppSizer.deviceWidth5),
              padding: EdgeInsets.all(AppSizer.deviceWidth5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor.withOpacity(0.9),
                    AppColors.accentColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: AppSizer.deviceWidth3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Quiz Using Quiz Code',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'Enter code to attempt quiz',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth3),
                  ElevatedButton(
                    onPressed: _showJoinQuizDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth6,
                        vertical: AppSizer.deviceHeight1_5,
                      ),
                    ),
                    child: Text(
                      'Join Now',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
           Container(
  margin: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth5),
  decoration: BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
  ),
  child: TabBar(
    controller: _tabController,
    labelColor: AppColors.primaryColor,
    unselectedLabelColor: AppColors.onSurfaceVariant,
    indicator: BoxDecoration(
      color: AppColors.cardColor,
      borderRadius: BorderRadius.circular(AppSizer.deviceWidth2_5),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorColor: Colors.transparent, // Yeh line add karen
    labelStyle: TextStyle(
      fontSize: AppSizer.deviceSp14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: AppSizer.deviceSp14,
      fontWeight: FontWeight.w500,
    ),
    tabs: const [
      Tab(text: 'Available Quizzes'),
      Tab(text: 'Attempted Quizzes'),
    ],
  ),
),

            SizedBox(height: AppSizer.deviceHeight2),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Available Quizzes Tab
                  _buildAvailableQuizzesTab(),

                  // Attempted Quizzes Tab
                  _buildAttemptedQuizzesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableQuizzesTab() {
    if (_isLoadingQuizzes) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_availableQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: AppSizer.deviceSp60,
              color: AppColors.outline,
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            Text(
              'No Quizzes Available',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth5),
      itemCount: _availableQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = _availableQuizzes[index];
        return Container(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: AppSizer.deviceWidth2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
              onTap: () {
                _startQuiz(quiz);
              },
              child: Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth5),
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
                              fontSize: AppSizer.deviceSp18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer.deviceWidth3,
                            vertical: AppSizer.deviceHeight0_5,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(quiz['difficulty'] as String),
                            borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                          ),
                          child: Text(
                            quiz['difficulty'] as String,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      quiz['description'] as String,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Row(
                      children: [
                        _buildQuizInfo(
                          Icons.quiz_outlined,
                          '${quiz['questions']} Qs',
                        ),
                        SizedBox(width: AppSizer.deviceWidth4),
                        _buildQuizInfo(
                          Icons.timer_outlined,
                          quiz['time'] as String,
                        ),
                        SizedBox(width: AppSizer.deviceWidth4),
                        _buildQuizInfo(
                          Icons.emoji_events_outlined,
                          '${quiz['points']} pts',
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    ElevatedButton(
                      onPressed: () {
                        _startQuiz(quiz);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, AppSizer.deviceHeight6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                        ),
                      ),
                      child: Text(
                        'Start Quiz',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildAttemptedQuizzesTab() {
    if (_isLoadingAttempts) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_attemptedQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: AppSizer.deviceSp60,
              color: AppColors.outline,
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            Text(
              'No Attempted Quizzes',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'Attempt some quizzes to see them here',
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth5),
      itemCount: _attemptedQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = _attemptedQuizzes[index];
        final score = quiz['score'] as int;
        final totalQuestions = quiz['totalQuestions'] as int;
        final correctAnswers = quiz['correct'] as int;
        final percentage = (score / (quiz['total'] as int)) * 100;

        return Container(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: AppSizer.deviceWidth2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSizer.deviceWidth5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quiz['title'] as String,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth3,
                        vertical: AppSizer.deviceHeight0_5,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(percentage),
                        borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                      ),
                      child: Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(percentage)),
                  borderRadius: BorderRadius.circular(AppSizer.deviceWidth1),
                  minHeight: AppSizer.deviceHeight1,
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAttemptedInfo(
                      Icons.check_circle_outline,
                      '$correctAnswers/$totalQuestions Correct',
                      AppColors.successColor,
                    ),
                    _buildAttemptedInfo(
                      Icons.timer_outlined,
                      quiz['timeTaken'] as String,
                      AppColors.primaryColor,
                    ),
                    _buildAttemptedInfo(
                      Icons.calendar_today_outlined,
                      quiz['date'] as String,
                      AppColors.accentColor,
                    ),
                  ],
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showAttemptDetailsDialog(quiz);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side: BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                          ),
                          padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(fontSize: AppSizer.deviceSp14),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizer.deviceWidth3),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _startQuiz({
                            'id': quiz['quizId'],
                            'title': quiz['title'],
                            'duration': quiz['duration'],
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceVariant,
                          foregroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                          ),
                          padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                        ),
                        child: Text(
                          'Re-attempt',
                          style: TextStyle(fontSize: AppSizer.deviceSp14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSizer.deviceSp18,
          color: AppColors.onSurfaceVariant,
        ),
        SizedBox(width: AppSizer.deviceWidth1),
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptedInfo(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppSizer.deviceSp18,
          color: color,
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.successColor;
      case 'intermediate':
        return AppColors.accentColor;
      case 'advanced':
        return AppColors.errorColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.successColor;
    if (percentage >= 60) return AppColors.accentColor;
    return AppColors.errorColor;
  }
}