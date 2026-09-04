import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/quiz_program_pages/play_quiz_page.dart';

class TestInstructionsPage extends StatelessWidget {
  final Map<String, dynamic> quiz;
  final bool isQuiz;

  const TestInstructionsPage({
    super.key,
    required this.quiz,
    this.isQuiz = false,
  });

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
    if (t.contains('c++') || t.contains('cpp') || t.contains('c programming')) {
      return Icons.code;
    } else if (t.contains('python')) {
      return Icons.terminal;
    } else if (t.contains('data structure') || t.contains('dsa') || t.contains('algorithm')) {
      return Icons.layers;
    } else if (t.contains('web') || t.contains('html') || t.contains('css') || t.contains('react')) {
      return Icons.language;
    } else if (t.contains('java')) {
      return Icons.coffee;
    }
    return Icons.psychology;
  }

  @override
  Widget build(BuildContext context) {
    final String title = quiz['title'] ?? (isQuiz ? 'Daily Quiz' : 'General Test');
    final String level = quiz['difficulty'] ?? quiz['level'] ?? 'Beginner';
    final int questionsCount = quiz['questions'] ?? quiz['totalQuestions'] ?? 10;
    final int durationMinutes = quiz['duration'] ?? 15;
    final int points = quiz['points'] ?? (questionsCount * 1);
    final String scheduledStartTime = quiz['scheduledStartTime']?.toString() ?? '';

    String formattedStartTime = 'Immediate / Anytime';
    if (scheduledStartTime.isNotEmpty) {
      final parsedDate = DateTime.tryParse(scheduledStartTime)?.toLocal();
      if (parsedDate != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final hour = parsedDate.hour > 12 ? parsedDate.hour - 12 : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
        final ampm = parsedDate.hour >= 12 ? 'PM' : 'AM';
        final minute = parsedDate.minute.toString().padLeft(2, '0');
        formattedStartTime = '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}, ${hour.toString().padLeft(2, '0')}:$minute $ampm';
      }
    }

    final Color badgeColor = _getLevelColor(level);
    final Color badgeBgColor = _getLevelBgColor(level);

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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth4,
          vertical: AppSizer.deviceHeight2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Test Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
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
                      size: 30,
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth3_5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B1033),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: badgeColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight2),

            Text(
              "Read the instructions carefully before starting the ${isQuiz ? 'quiz' : 'test'}.",
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight2),

            // Metadata Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.calendar_month_outlined, 'Start Time', formattedStartTime),
                  _buildDivider(),
                  _buildInfoRow(Icons.timer_outlined, 'Duration', '$durationMinutes Minutes'),
                  _buildDivider(),
                  _buildInfoRow(Icons.help_outline_rounded, 'Total Questions', '$questionsCount Questions'),
                  _buildDivider(),
                  _buildInfoRow(Icons.emoji_events_outlined, 'Total Marks', '$points Points'),
                  _buildDivider(),
                  _buildInfoRow(Icons.description_outlined, 'Question Type', 'Multiple Choice (MCQ)'),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight2_5),

            // Instructions Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0033CC).withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1033),
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildInstructionItem('1', 'Read each question carefully.'),
                  _buildInstructionItem('2', 'You cannot change your answer after submission.'),
                  _buildInstructionItem('3', 'Make sure you have a stable internet connection.'),
                  _buildInstructionItem('4', 'Click on "Start ${isQuiz ? 'Quiz' : 'Test'}" when you are ready.'),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight4),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth4,
          vertical: AppSizer.deviceHeight2,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final targetId = quiz['id'] ?? quiz['quizId'];
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayQuizPage(
                      quizId: targetId.toString(),
                      quizTitle: title,
                      totalDurationMinutes: durationMinutes,
                    ),
                  ),
                );
                if (result == true) {
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0033CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start ${isQuiz ? 'Quiz' : 'Test'}',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth2),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF0033CC)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizer.deviceSp13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B1033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(
              fontSize: AppSizer.deviceSp13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0033CC),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                color: const Color(0xFF334155),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
