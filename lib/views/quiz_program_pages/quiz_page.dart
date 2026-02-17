import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showJoinQuizDialog() {
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
                Navigator.pop(context);
                // Add your join quiz logic here
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
    final List<Map<String, dynamic>> availableQuizzes = [
      {
        'title': 'Flutter Basics',
        'description': 'Test your Flutter fundamentals',
        'questions': 20,
        'time': '30 mins',
        'difficulty': 'Beginner',
        'points': 100,
      },
      {
        'title': 'Dart Programming',
        'description': 'Advanced Dart concepts and features',
        'questions': 25,
        'time': '45 mins',
        'difficulty': 'Intermediate',
        'points': 150,
      },
      {
        'title': 'API Integration',
        'description': 'REST APIs and HTTP in Flutter',
        'questions': 15,
        'time': '25 mins',
        'difficulty': 'Intermediate',
        'points': 120,
      },
      {
        'title': 'State Management',
        'description': 'Bloc, Provider, and Riverpod',
        'questions': 30,
        'time': '60 mins',
        'difficulty': 'Advanced',
        'points': 200,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth5),
      itemCount: availableQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = availableQuizzes[index];
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
                // Navigate to quiz details or start quiz
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
                        // Start quiz
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
    final List<Map<String, dynamic>> attemptedQuizzes = [
      {
        'title': 'Flutter Basics',
        'score': 85,
        'total': 100,
        'date': '2024-01-15',
        'timeTaken': '25:30',
        'correct': 17,
        'totalQuestions': 20,
      },
      {
        'title': 'Dart Programming',
        'score': 72,
        'total': 100,
        'date': '2024-01-10',
        'timeTaken': '38:15',
        'correct': 18,
        'totalQuestions': 25,
      },
      {
        'title': 'Widget Mastery',
        'score': 90,
        'total': 100,
        'date': '2024-01-05',
        'timeTaken': '28:45',
        'correct': 27,
        'totalQuestions': 30,
      },
    ];

    if (attemptedQuizzes.isEmpty) {
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
      itemCount: attemptedQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = attemptedQuizzes[index];
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
                        '$score%',
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
                          // View detailed results
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
                          // Retake quiz
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