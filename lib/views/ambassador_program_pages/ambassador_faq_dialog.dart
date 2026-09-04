import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class AmbassadorFaqDialog {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizer.deviceWidth4,
                  vertical: AppSizer.deviceHeight1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B1033),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // FAQs List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  children: const [
                    _FaqItem(
                      question: 'What is the Campus Ambassador Program?',
                      answer:
                          'It is an initiative for college students to represent CodersAdda in their campus, help peers learn in-demand tech skills, and earn exciting cashback and perks.',
                    ),
                    _FaqItem(
                      question: 'How do I earn rewards?',
                      answer:
                          'Share your unique referral code with friends. When they sign up and purchase any course or subscription, you receive ₹200 cashback in your CodersAdda wallet!',
                    ),
                    _FaqItem(
                      question: 'When will my application be reviewed?',
                      answer:
                          'Our campus team usually reviews all applications within 24 to 48 working hours. You will receive an email and in-app notification once approved.',
                    ),
                    _FaqItem(
                      question: 'How do I withdraw my wallet earnings?',
                      answer:
                          'You can withdraw your wallet balance once it reaches ₹500 directly to your UPI ID or Bank Account via the "My Wallet" section.',
                    ),
                    _FaqItem(
                      question: 'Do I get an official certificate?',
                      answer:
                          'Yes! All active Campus Ambassadors receive a verified certificate of appreciation and letters of recommendation based on performance.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: (val) => setState(() => _expanded = val),
          title: Text(
            widget.question,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B1033),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
