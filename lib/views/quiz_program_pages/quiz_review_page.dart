import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class QuizReviewPage extends StatelessWidget {
  final List<dynamic> questions;
  final Map<int, String> userAnswers;

  const QuizReviewPage({
    Key? key,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C24),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Quiz Review",
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final String qText = question['question'] ?? 'No Question Text';
          final Map<String, dynamic> options = question['options'] ?? {};
          final String correctOption = question['correctAnswer'] ?? '';
          final String? selectedOption = userAnswers[index];

          final bool isCorrect = selectedOption == correctOption;
          final bool isUnattempted = selectedOption == null;

          return Card(
            color: Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Q${index + 1}. ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizer.deviceSp16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          qText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizer.deviceSp16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isUnattempted)
                        const Icon(Icons.help_outline, color: Colors.grey)
                      else if (isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green)
                      else
                        const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...['a', 'b', 'c', 'd'].map((key) {
                    if (!options.containsKey(key)) return const SizedBox.shrink();
                    final optionText = options[key];
                    final bool isThisCorrect = key == correctOption;
                    final bool isThisSelected = key == selectedOption;

                    Color boxColor = Colors.transparent;
                    Color borderColor = Colors.white30;
                    Color textColor = Colors.white70;

                    if (isThisCorrect) {
                      boxColor = Colors.green.withOpacity(0.2);
                      borderColor = Colors.green;
                      textColor = Colors.green;
                    } else if (isThisSelected && !isThisCorrect) {
                      boxColor = Colors.red.withOpacity(0.2);
                      borderColor = Colors.red;
                      textColor = Colors.red;
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: boxColor,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${key.toUpperCase()}. ",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              optionText.toString(),
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          if (isThisCorrect)
                            const Icon(Icons.check, color: Colors.green, size: 20)
                          else if (isThisSelected)
                            const Icon(Icons.close, color: Colors.red, size: 20)
                        ],
                      ),
                    );
                  }).toList()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
