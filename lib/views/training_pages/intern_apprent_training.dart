// import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

// class InternApprentTrainingPage extends StatelessWidget {
//   const InternApprentTrainingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'Internship / Apprenticeship',
//           style: TextStyle(
//             color: AppColors.textColor,
//             fontSize: AppSizer.deviceSp20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: AppColors.cardColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.textColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(AppSizer.deviceWidth4),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Section
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(AppSizer.deviceWidth4),
//               decoration: BoxDecoration(
//                 color: AppColors.accentColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '6 Months Professional Program',
//                     style: TextStyle(
//                       color: AppColors.accentColor,
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight1),
//                   Text(
//                     'Gain real-world experience with industry projects and professional mentorship',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                       fontSize: AppSizer.deviceSp14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             SizedBox(height: AppSizer.deviceHeight4),
            
//             // Duration & Location
//             Row(
//               children: [
//                 _buildInfoItem(
//                   Icons.calendar_today,
//                   '6 Months',
//                   'Duration',
//                 ),
//                 SizedBox(width: AppSizer.deviceWidth4),
//                 _buildInfoItem(
//                   Icons.location_on,
//                   'Remote & On-site',
//                   'Mode',
//                 ),
//               ],
//             ),
            
//             SizedBox(height: AppSizer.deviceHeight4),
            
//             // Program Highlights
//             Text(
//               'Program Highlights',
//               style: TextStyle(
//                 color: AppColors.textColor,
//                 fontSize: AppSizer.deviceSp18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: AppSizer.deviceHeight2),
//             _buildHighlightItem('Real client projects'),
//             _buildHighlightItem('Professional mentorship'),
//             _buildHighlightItem('Industry exposure'),
//             _buildHighlightItem('Stipend opportunity'),
//             _buildHighlightItem('Job placement support'),
            
//             SizedBox(height: AppSizer.deviceHeight4),
            
//             // Learning Outcomes
//             Text(
//               'What You Will Learn',
//               style: TextStyle(
//                 color: AppColors.textColor,
//                 fontSize: AppSizer.deviceSp18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: AppSizer.deviceHeight2),
//             _buildLearningItem('Professional code practices & architecture'),
//             _buildLearningItem('Team collaboration & Agile methodology'),
//             _buildLearningItem('Client communication & project management'),
//             _buildLearningItem('Advanced Flutter concepts & optimization'),
//             _buildLearningItem('Deployment & maintenance best practices'),
            
//             SizedBox(height: AppSizer.deviceHeight4),
            
//             // Apply Button
//             Container(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Apply logic
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.buttonColor,
//                   padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Apply Now',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: AppSizer.deviceSp16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoItem(IconData icon, String title, String subtitle) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(AppSizer.deviceWidth3),
//         decoration: BoxDecoration(
//           color: AppColors.surfaceVariant,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: AppColors.accentColor, size: AppSizer.deviceSp24),
//             SizedBox(height: AppSizer.deviceHeight1),
//             Text(
//               title,
//               style: TextStyle(
//                 color: AppColors.textColor,
//                 fontSize: AppSizer.deviceSp14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 color: AppColors.onSurfaceVariant,
//                 fontSize: AppSizer.deviceSp12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHighlightItem(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.work,
//             color: AppColors.primaryColor,
//             size: AppSizer.deviceSp16,
//           ),
//           SizedBox(width: AppSizer.deviceWidth2),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: AppColors.textColor,
//                 fontSize: AppSizer.deviceSp14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLearningItem(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.rocket_launch,
//             color: AppColors.successColor,
//             size: AppSizer.deviceSp16,
//           ),
//           SizedBox(width: AppSizer.deviceWidth2),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: AppColors.textColor,
//                 fontSize: AppSizer.deviceSp14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

  
// }


import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class InternApprentTrainingPage extends StatelessWidget {
  const InternApprentTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Internship / Apprenticeship',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: AppSizer.deviceHeight12, // extra space for fixed button
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '6 Months Internship / Apprenticeship',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'Start your professional journey with real-world projects, mentorship, and career support.',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: AppSizer.deviceSp14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Duration & Mode
                  Row(
                    children: [
                      _buildInfoItem(Icons.calendar_today, '6 Months', 'Duration'),
                      SizedBox(width: AppSizer.deviceWidth4),
                      _buildInfoItem(Icons.location_on, 'Online / On-site', 'Mode'),
                    ],
                  ),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Program Overview
                  Text(
                    'Program Overview',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  Text(
                    'This 6-month professional internship/apprenticeship program helps students gain practical experience, understand corporate workflow, and work on live industry projects with expert mentorship and placement assistance.',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: AppSizer.deviceSp14,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Key Highlights
                  Text(
                    'Key Highlights',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildHighlightItem('Work on Real Client Projects'),
                  _buildHighlightItem('1-to-1 Mentorship from Industry Experts'),
                  _buildHighlightItem('Option for Stipend-Based Internship'),
                  _buildHighlightItem('Placement Assistance after Completion'),
                  _buildHighlightItem('Certificate Recognized by Industry'),
                  _buildHighlightItem('Live Project Report and Experience Letter'),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Technologies Available
                  Text(
                    'Technologies You Can Choose',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildTechChipList(),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Learning Outcomes
                  Text(
                    'What You Will Learn',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildLearningItem('Professional code practices & architecture'),
                  _buildLearningItem('Team collaboration using Git & Agile tools'),
                  _buildLearningItem('Real-time client project workflow'),
                  _buildLearningItem('Debugging, optimization & deployment'),
                  _buildLearningItem('Communication & reporting skills'),
                  _buildLearningItem('Career guidance & interview preparation'),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Fee Structure
                  Text(
                    'Program Fee Structure',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildFeeTable(),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Contact Section
                  Text(
                    'Contact & Registration',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildContactCard(),

                  SizedBox(height: AppSizer.deviceHeight8),
                ],
              ),
            ),
          ),

          // Fixed Bottom Button
          Positioned(
  left: AppSizer.deviceWidth4,
  right: AppSizer.deviceWidth4,
  bottom: AppSizer.deviceHeight2,
  child: Container(
    width: double.infinity,
    child: Row(
      children: [
        // Enroll Now Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Application Submitted'),
                  content: Text(
                    'Thank you for applying for the Internship / Apprenticeship program!\n\nOur team will contact you shortly for the next steps.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              shadowColor: AppColors.primaryColor.withOpacity(0.3),
            ),
            child: Text(
              'Enroll Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        SizedBox(width: 10), // Space between buttons
        
        // Call Now Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Add your call functionality here
              // For example: launch("tel:+1234567890");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor, // You can change color
              padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              shadowColor: AppColors.accentColor.withOpacity(0.3),
            ),
            child: Text(
              'Call Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSizer.deviceWidth3),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: AppSizer.deviceSp24),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: AppSizer.deviceSp14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: AppSizer.deviceSp12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.workspace_premium, color: AppColors.accentColor, size: AppSizer.deviceSp16),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textColor, fontSize: AppSizer.deviceSp14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppColors.successColor, size: AppSizer.deviceSp16),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textColor, fontSize: AppSizer.deviceSp14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChipList() {
    final techs = [
      'Python / Django',
      'Java / Spring',
      'PHP / Laravel',
      'MERN Stack',
      'Flutter / Android',
      'AI / ML / Data Science',
      'Embedded Systems',
      'AutoCAD / Mechanical',
    ];
    return Wrap(
      spacing: AppSizer.deviceWidth2,
      runSpacing: AppSizer.deviceHeight1_5,
      children: techs.map((tech) {
        return Chip(
          backgroundColor: AppColors.cardColor,
          label: Text(
            tech,
            style: TextStyle(color: AppColors.textColor, fontSize: AppSizer.deviceSp13),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeeTable() {
    final feeMap = {
      'IT / CS Programs': '₹30,000 /-',
      'Mechanical / Civil Programs': '₹30,000 /-',
      'AI / ML / Advanced Domains': '₹30,000 /-',
    };
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth3),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: feeMap.entries.map((e) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: TextStyle(color: AppColors.textColor, fontSize: AppSizer.deviceSp14)),
                Text(
                  e.value,
                  style: TextStyle(color: AppColors.primaryColor, fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For Queries & Registration:',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: AppSizer.deviceSp15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            '📞 +91-9140967607 | +91-6394296293 | +91-9198483820',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: AppSizer.deviceSp14),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            '🏢 2nd Floor, B-36, Sector O, CMS School Road, Ram Ram Bank Chauraha, Aliganj, Lucknow, UP - 226024',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: AppSizer.deviceSp14),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            '🌐 Online Registration: https://thedigicoders.com/Home/Registration',
            style: TextStyle(color: AppColors.primaryColor, fontSize: AppSizer.deviceSp14),
          ),
        ],
      ),
    );
  }
}
