import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/test_program_pages/test_instructions_page.dart';

class JoinTestQuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> availableQuizzes;
  final List<Map<String, dynamic>> attemptedQuizzes;
  final bool isQuiz;
  final Function(Map<String, dynamic>)? onStartDirectly;

  const JoinTestQuizPage({
    super.key,
    required this.availableQuizzes,
    required this.attemptedQuizzes,
    this.isQuiz = false,
    this.onStartDirectly,
  });

  @override
  State<JoinTestQuizPage> createState() => _JoinTestQuizPageState();
}

class _JoinTestQuizPageState extends State<JoinTestQuizPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verifyAndJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid ${widget.isQuiz ? 'quiz' : 'test'} code."),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Look for matching test/quiz by testCode or quizCode
    final targetQuiz = widget.availableQuizzes.firstWhere(
      (q) {
        final code1 = (q['quizCode'] ?? '').toString().trim().toLowerCase();
        final code2 = (q['testCode'] ?? '').toString().trim().toLowerCase();
        final input = code.toLowerCase();
        return code1 == input || code2 == input;
      },
      orElse: () => {},
    );

    setState(() => _isVerifying = false);

    if (targetQuiz.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid ${widget.isQuiz ? 'quiz' : 'test'} code. Please check and try again."),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final targetId = targetQuiz['id'] ?? targetQuiz['quizId'];
    final bool hasAttempted = widget.attemptedQuizzes.any((a) => a['quizId'] == targetId);
    if (hasAttempted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You have already attempted this ${widget.isQuiz ? 'quiz' : 'test'}."),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }

    DateTime? scheduledTime;
    if (targetQuiz['scheduledStartTime'] != null) {
      scheduledTime = DateTime.tryParse(targetQuiz['scheduledStartTime'].toString())?.toLocal();
    }

    if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = scheduledTime.hour > 12 ? scheduledTime.hour - 12 : (scheduledTime.hour == 0 ? 12 : scheduledTime.hour);
      final ampm = scheduledTime.hour >= 12 ? 'PM' : 'AM';
      final minute = scheduledTime.minute.toString().padLeft(2, '0');
      final formatted = '${scheduledTime.day} ${months[scheduledTime.month - 1]} ${scheduledTime.year}, ${hour.toString().padLeft(2, '0')}:$minute $ampm';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.isQuiz ? 'Quiz' : 'Test'} hasn't started yet. Starts on: $formatted"),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // Open Test Instructions
    final completed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestInstructionsPage(
          quiz: targetQuiz,
          isQuiz: widget.isQuiz,
        ),
      ),
    );

    if (completed == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String subjectName = widget.isQuiz ? 'Quiz' : 'Test';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'Join $subjectName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizer.deviceSp22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B1033),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight0_5),
            Text(
              'Enter the code to join the $subjectName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // Center Graphic with glowing card & confetti
            Stack(
              alignment: Alignment.center,
              children: [
                // Confetti dots
                Positioned(
                  top: 10,
                  left: 30,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 35,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 45,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Main card
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0033CC).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF0033CC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0033CC).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '</>',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // Input card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$subjectName Code',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1033),
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B1033),
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.event_note_rounded, color: Color(0xFF0033CC), size: 24),
                      hintText: 'Enter code (e.g. CA123)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: AppSizer.deviceSp13,
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0033CC), width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight2_5),

            // Why Join by Code card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Join by Code?',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1033),
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1_5),
                  _buildBenefitItem('Access instructor-created ${widget.isQuiz ? "quizzes" : "tests"}'),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildBenefitItem('Quick and easy'),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildBenefitItem('Start instantly'),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),
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
            height: 52,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyAndJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0033CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Join Now',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth2),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        SizedBox(width: AppSizer.deviceWidth2_5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizer.deviceSp13,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
