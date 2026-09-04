import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class AmbassadorHowItWorksPage extends StatelessWidget {
  const AmbassadorHowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'num': '1',
        'title': 'Share Your Code',
        'desc': 'Share your unique referral code with your friends.',
        'icon': Icons.share_rounded,
      },
      {
        'num': '2',
        'title': 'Friends Sign Up',
        'desc': 'Your friends sign up on CodersAdda using your code.',
        'icon': Icons.person_add_alt_1_rounded,
      },
      {
        'num': '3',
        'title': 'They Purchase',
        'desc': 'They purchase any course or subscription.',
        'icon': Icons.shopping_cart_outlined,
      },
      {
        'num': '4',
        'title': 'You Earn Rewards',
        'desc': 'You get ₹200 cashback per successful referral.',
        'icon': Icons.currency_rupee_rounded,
      },
    ];

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
          horizontal: AppSizer.deviceWidth5,
          vertical: AppSizer.deviceHeight2_5,
        ),
        child: Column(
          children: [
            SizedBox(height: AppSizer.deviceHeight1),

            // Vertical Stepper
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator column
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0052FF),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                step['num'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizer.deviceSp14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(0xFFCBD5E1),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: AppSizer.deviceWidth4),

                      // Step Content Card
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizer.deviceHeight3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step Icon bubble
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                                ),
                                child: Icon(
                                  step['icon'] as IconData,
                                  color: const Color(0xFF0052FF),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: AppSizer.deviceWidth3_5),

                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['title'] as String,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0B1033),
                                      ),
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight0_5),
                                    Text(
                                      step['desc'] as String,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp13,
                                        color: Colors.grey.shade600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: AppSizer.deviceHeight4),

            // Impact Card Banner at bottom
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052FF).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🎁', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth3_5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'More Learners. Bigger Impact!',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0033CC),
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),
                        Text(
                          'Help your friends grow, and grow your rewards together.',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),
          ],
        ),
      ),
    );
  }
}
