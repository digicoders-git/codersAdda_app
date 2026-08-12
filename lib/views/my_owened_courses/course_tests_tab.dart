import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/views/quiz_program_pages/play_quiz_page.dart';

class CourseTestsTab extends StatefulWidget {
  final String courseId;

  const CourseTestsTab({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseTestsTab> createState() => _CourseTestsTabState();
}

class _CourseTestsTabState extends State<CourseTestsTab> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tests = [];

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    try {
      final response = await _apiClient.get('${ApiUrls.getQuizzes}?courseId=${widget.courseId}&type=Test');
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        if (mounted) {
          setState(() {
            _tests = data.map((q) => {
                  'id': q['_id'],
                  'title': q['title'] ?? 'Unknown Test',
                  'description': q['description'] ?? '',
                  'questions': q['totalQuestions'] ?? 0,
                  'time': '${q['duration'] ?? 0} mins',
                  'duration': q['duration'] ?? 0,
                  'difficulty': q['level'] ?? 'Beginner',
                  'points': q['points'] ?? 0,
                  'quizCode': q['quizCode'] ?? '',
                  'scheduledStartTime': q['scheduledStartTime'],
                }).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return Colors.green;
      case 'medium':
      case 'intermediate':
        return Colors.orange;
      case 'hard':
      case 'advanced':
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  Widget _buildTestInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: AppSizer.deviceSp16, color: AppColors.onSurfaceVariant),
        SizedBox(width: AppSizer.deviceWidth1),
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _startTest(Map<String, dynamic> test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayQuizPage(
          quizId: test['id'] as String,
          quizTitle: test['title'] as String,
          totalDurationMinutes: test['duration'] as int? ?? 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: AppSizer.deviceSp60,
              color: AppColors.outline,
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            Text(
              'No Tests Available for this Course',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: _tests.length,
      itemBuilder: (context, index) {
        final test = _tests[index];
        DateTime? scheduledTime;
        if (test['scheduledStartTime'] != null) {
          scheduledTime = DateTime.tryParse(test['scheduledStartTime'] as String);
        }
        
        final bool isLocked = scheduledTime != null && scheduledTime.isAfter(DateTime.now());
        
        String lockText = "Start Test";
        if (isLocked) {
          lockText = "Starts on: ${scheduledTime!.day}/${scheduledTime.month}/${scheduledTime.year} ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}";
        }

        return Container(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
            border: Border.all(color: AppColors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
              onTap: isLocked ? null : () {
                _startTest(test);
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
                            test['title'] as String,
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
                            color: _getDifficultyColor(test['difficulty'] as String),
                            borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                          ),
                          child: Text(
                            test['difficulty'] as String,
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
                      test['description'] as String,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Row(
                      children: [
                        _buildTestInfo(
                          Icons.quiz_outlined,
                          '${test['questions']} Qs',
                        ),
                        SizedBox(width: AppSizer.deviceWidth4),
                        _buildTestInfo(
                          Icons.timer_outlined,
                          test['time'] as String,
                        ),
                        SizedBox(width: AppSizer.deviceWidth4),
                        _buildTestInfo(
                          Icons.emoji_events_outlined,
                          '${test['points']} pts',
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    ElevatedButton(
                      onPressed: isLocked ? null : () {
                        _startTest(test);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLocked ? Colors.grey[700] : AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, AppSizer.deviceHeight6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLocked) ...[
                            const Icon(Icons.lock_clock, size: 18),
                            SizedBox(width: AppSizer.deviceWidth2),
                          ],
                          Text(
                            lockText,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
}
