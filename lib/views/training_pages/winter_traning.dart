// import 'package:flutter/material.dart';
// import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
// import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
// import '../../models/technology_model.dart';

// class WinterTrainingPage extends StatefulWidget {
//   final List<Technology> technologies;

//   const WinterTrainingPage({super.key, required this.technologies});

//   @override
//   State<WinterTrainingPage> createState() => _WinterTrainingPageState();
// }

// class _WinterTrainingPageState extends State<WinterTrainingPage> {
//   Technology? _selectedTechnology;
//   final Map<String, List<Technology>> _categorizedTech = {};

//   @override
//   void initState() {
//     super.initState();
//     _categorizeTechnologies();
//   }

//   void _categorizeTechnologies() {
//     for (var tech in widget.technologies) {
//       if (!_categorizedTech.containsKey(tech.category)) {
//         _categorizedTech[tech.category] = [];
//       }
//       _categorizedTech[tech.category]!.add(tech);
//     }
//   }

//   void _enrollNow() {
//     if (_selectedTechnology == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select a technology to enroll'),
//           backgroundColor: AppColors.errorColor,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Enrollment Successful!'),
//         content: Text(
//           'You have successfully enrolled in ${_selectedTechnology!.name} Winter Training Program.\n\n'
//           'Duration: 45 Days\n'
//           'Mode: Online & Offline\n\n'
//           'Our team will contact you soon.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'Winter Training Program',
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
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: EdgeInsets.only(bottom: AppSizer.deviceHeight12),
//             child: Padding(
//               padding: EdgeInsets.all(AppSizer.deviceWidth4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(AppSizer.deviceWidth4),
//                     decoration: BoxDecoration(
//                       color: AppColors.accentColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '45 Days Winter Training',
//                           style: TextStyle(
//                             color: AppColors.accentColor,
//                             fontSize: AppSizer.deviceSp18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: AppSizer.deviceHeight1),
//                         Text(
//                           'Hands-on projects & industry exposure to master your preferred technology',
//                           style: TextStyle(
//                             color: AppColors.textColor,
//                             fontSize: AppSizer.deviceSp14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: AppSizer.deviceHeight4),

//                   // Duration & Mode
//                   Row(
//                     children: [
//                       _buildInfoItem(Icons.calendar_today, '45 Days', 'Duration'),
//                       SizedBox(width: AppSizer.deviceWidth4),
//                       _buildInfoItem(Icons.location_on, 'Online & Offline', 'Mode'),
//                     ],
//                   ),

//                   SizedBox(height: AppSizer.deviceHeight4),

//                   // Select Technology
//                   Text(
//                     'Select Your Technology',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight2),
//                   Text(
//                     'Choose the technology you want to learn during the 45-day Winter program',
//                     style: TextStyle(
//                       color: AppColors.onSurfaceVariant,
//                       fontSize: AppSizer.deviceSp14,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight4),

//                   // Technologies by Category
//                   if (_categorizedTech.containsKey('mobile')) ...[
//                     _buildTechnologyCategory('Mobile Development', _categorizedTech['mobile']!),
//                     SizedBox(height: AppSizer.deviceHeight3),
//                   ],
//                   if (_categorizedTech.containsKey('web')) ...[
//                     _buildTechnologyCategory('Web Development', _categorizedTech['web']!),
//                     SizedBox(height: AppSizer.deviceHeight3),
//                   ],
//                   if (_categorizedTech.containsKey('design')) ...[
//                     _buildTechnologyCategory('Design', _categorizedTech['design']!),
//                     SizedBox(height: AppSizer.deviceHeight3),
//                   ],
//                   if (_categorizedTech.containsKey('marketing')) ...[
//                     _buildTechnologyCategory('Digital Marketing', _categorizedTech['marketing']!),
//                     SizedBox(height: AppSizer.deviceHeight3),
//                   ],

//                   SizedBox(height: AppSizer.deviceHeight4),

//                   // Program Content
//                   Text(
//                     'What You Will Learn',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight2),
//                   _buildContentItem('Fundamentals & Core Concepts'),
//                   _buildContentItem('Hands-on Projects & Real Applications'),
//                   _buildContentItem('Industry Best Practices'),
//                   _buildContentItem('Portfolio Building'),
//                   _buildContentItem('Certificate of Completion'),

//                   SizedBox(height: AppSizer.deviceHeight4),

//                   // Program Benefits
//                   Text(
//                     'Program Benefits',
//                     style: TextStyle(
//                       color: AppColors.textColor,
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight2),
//                   _buildBenefitItem('Industry recognized certificate'),
//                   _buildBenefitItem('Hands-on project experience'),
//                   _buildBenefitItem('Mentorship from experts'),
//                   _buildBenefitItem('Placement assistance'),
//                   _buildBenefitItem('Lifetime access to learning materials'),

//                   SizedBox(height: AppSizer.deviceHeight8),
//                 ],
//               ),
//             ),
//           ),

//           Positioned(
//             left: AppSizer.deviceWidth4,
//             right: AppSizer.deviceWidth4,
//             bottom: AppSizer.deviceHeight2,
//             child: ElevatedButton(
//               onPressed: _enrollNow,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.buttonColor,
//                 padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'Enroll Now - 45 Days Winter Program',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: AppSizer.deviceSp16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
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

//   Widget _buildTechnologyCategory(String categoryName, List<Technology> technologies) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           categoryName,
//           style: TextStyle(
//             color: AppColors.textColor,
//             fontSize: AppSizer.deviceSp16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: AppSizer.deviceHeight2),
//         Wrap(
//           spacing: AppSizer.deviceWidth2,
//           runSpacing: AppSizer.deviceHeight2,
//           children: technologies.map((tech) {
//             final isSelected = _selectedTechnology?.id == tech.id;
//             return GestureDetector(
//               onTap: () => setState(() => _selectedTechnology = tech),
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: AppSizer.deviceWidth4,
//                   vertical: AppSizer.deviceHeight1_5,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.accentColor : AppColors.cardColor,
//                   borderRadius: BorderRadius.circular(25),
//                   border: Border.all(
//                     color: isSelected ? AppColors.accentColor : AppColors.outline,
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(tech.icon, style: TextStyle(fontSize: AppSizer.deviceSp16)),
//                     SizedBox(width: AppSizer.deviceWidth1),
//                     Text(
//                       tech.name,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : AppColors.textColor,
//                         fontSize: AppSizer.deviceSp14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildContentItem(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.check_circle, color: AppColors.successColor, size: AppSizer.deviceSp16),
//           SizedBox(width: AppSizer.deviceWidth2),
//           Expanded(
//             child: Text(text, style: TextStyle(color: AppColors.textColor, fontSize: AppSizer.deviceSp14)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitItem(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.star, color: AppColors.accentColor, size: AppSizer.deviceSp16),
//           SizedBox(width: AppSizer.deviceWidth2),
//           Expanded(
//             child: Text(text, style: TextStyle(color: AppColors.textColor, fontSize: AppSizer.deviceSp14)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import '../../models/technology_model.dart';

class WinterTrainingPage extends StatefulWidget {
  final List<Technology> technologies;

  const WinterTrainingPage({super.key, required this.technologies});

  @override
  State<WinterTrainingPage> createState() => _WinterTrainingPageState();
}

class _WinterTrainingPageState extends State<WinterTrainingPage> {
  Technology? _selectedTechnology;
  final Map<String, List<Technology>> _categorizedTech = {};

  // Same details as Summer Training (from brochure)
  final String _duration = '45 Days (can be 30 / 60 days)';
  final String _mode = 'Online & Offline';
  final Map<String, String> _feeStructure = {
    'Python': '7,000/-',
    'ASP.NET': '7,000/-',
    'Java': '7,000/-',
    'PHP': '7,000/-',
    'Android': '7,000/-',
    'MERN': '8,000/-',
    'Embedded with IoT': '8,000/-',
    'CAD/AutoCAD/Mechanical': '8,000/-',
    'AI/ML': '8,000/-',
  };

  final List<String> _whatYouWillLearn = [
    'Foundation course: HTML, CSS, JavaScript, DB (MySQL)',
    'Python Programming & Django (DB connectivity, Web API)',
    'Core Java programming, JDBC + Servlet, JSP',
    'PHP programming & DB connectivity',
    'Android: Core Java & XML, Firebase, API integration',
    'MERN stack: MongoDB, Express, React, Node, API',
    'Embedded systems: Embedded C, PCB design, IoT projects',
    'AI/ML: Numpy, Pandas, Matplotlib, Data Science frameworks',
    'Project Work (Live Project + Project Report)',
    'Certificate & Lifetime Technical Support',
  ];

  final List<String> _extraCurricular = [
    'Resume Building',
    'LinkedIn Profile Assistance',
    'Personality Development',
    'Git & GitHub / Version Control',
    'Live Server & Hosting',
    'Recorded Lectures for Revision',
    'Weekly Online Tests & Sunday Workshops',
    'Mock Interviews & Placement Support',
  ];

  final List<String> _contactNumbers = [
    '+91-9140967607',
    '+91-6394296293',
    '+91-6394296293',
    '+91-8081329320',
    '+91-9198483820',
    '0522-4235604',
  ];

  final String _officeAddress =
      '2nd Floor, B-36, Sector O, CMS School Road, Ram Ram Bank Chauraha, Aliganj, Lucknow, UP, 226024';

  @override
  void initState() {
    super.initState();
    _categorizeTechnologies();
  }

  void _categorizeTechnologies() {
    for (var tech in widget.technologies) {
      if (!_categorizedTech.containsKey(tech.category)) {
        _categorizedTech[tech.category] = [];
      }
      _categorizedTech[tech.category]!.add(tech);
    }
  }

  void _enrollNow() {
    if (_selectedTechnology == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a technology to enroll'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enrollment Successful!'),
        content: Text(
          'You have successfully enrolled in ${_selectedTechnology!.name} Winter Training Program.\n\n'
          'Duration: $_duration\n'
          'Mode: $_mode\n\n'
          'Fee: ${_feeStructure[_selectedTechnology!.name] ?? "Contact for fee details"}\n\n'
          'Our team will contact you soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Winter Training Program',
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
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: AppSizer.deviceHeight12),
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
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '45 Days Winter Training',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'Gain hands-on experience and boost your skills this winter with live projects & expert mentorship.',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: AppSizer.deviceSp14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight3),

                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today,
                        _duration,
                        'Duration',
                      ),
                      SizedBox(width: AppSizer.deviceWidth4),
                      _buildInfoItem(Icons.location_on, _mode, 'Mode'),
                    ],
                  ),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Fee Structure
                  Text(
                    'Fee Structure',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildFeeGrid(),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // What You Will Learn
                  Text(
                    'What You Will Learn',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  ..._whatYouWillLearn
                      .map((s) => _buildContentItem(s))
                      .toList(),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Extra Curricular
                  Text(
                    'Extra Curricular & Support',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  ..._extraCurricular.map((s) => _buildBenefitItem(s)).toList(),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Technologies
                  // Text(
                  //   'Select Your Technology',
                  //   style: TextStyle(
                  //     color: AppColors.textColor,
                  //     fontSize: AppSizer.deviceSp18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: AppSizer.deviceHeight2),
                  // _buildPopularTechChips(),

                  // SizedBox(height: AppSizer.deviceHeight4),

                  // Selected Technology
                  // if (_selectedTechnology != null) ...[
                  //   Container(
                  //     width: double.infinity,
                  //     padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.accentColor.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: AppColors.accentColor),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Text(_selectedTechnology!.icon, style: TextStyle(fontSize: AppSizer.deviceSp18)),
                  //         SizedBox(width: AppSizer.deviceWidth3),
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 'Selected Technology',
                  //                 style: TextStyle(
                  //                   color: AppColors.onSurfaceVariant,
                  //                   fontSize: AppSizer.deviceSp12,
                  //                 ),
                  //               ),
                  //               Text(
                  //                 _selectedTechnology!.name,
                  //                 style: TextStyle(
                  //                   color: AppColors.textColor,
                  //                   fontSize: AppSizer.deviceSp16,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //               SizedBox(height: AppSizer.deviceHeight1),
                  //               Text(
                  //                 'Fee: ${_feeStructure[_selectedTechnology!.name] ?? 'Contact for fee'}',
                  //                 style: TextStyle(
                  //                   color: AppColors.onSurfaceVariant,
                  //                   fontSize: AppSizer.deviceSp12,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         IconButton(
                  //           onPressed: () => setState(() => _selectedTechnology = null),
                  //           icon: Icon(Icons.close, color: AppColors.errorColor),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //   SizedBox(height: AppSizer.deviceHeight4),
                  // ],

                  // Contact Info
                  Container(
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact & Registration',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: AppSizer.deviceSp16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight2),
                        Text(
                          'Call / WhatsApp: ${_contactNumbers.join('  |  ')}',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: AppSizer.deviceSp14,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'Office: $_officeAddress',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: AppSizer.deviceSp14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight8),
                ],
              ),
            ),
          ),

          // Enroll Button
          Positioned(
            left: AppSizer.deviceWidth4,
            right: AppSizer.deviceWidth4,
            bottom: AppSizer.deviceHeight2,
            child: Container(
              width: double.infinity,
              child: Row(
                children: [
                  // Enroll Now Button (Primary Color)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enrollNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizer.deviceHeight2,
                        ),
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
                  /*
        void _callNow() async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: '+1234567890', // यहाँ अपना phone number डालें
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    // Handle error - show dialog or snackbar
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cannot make call'),
        content: Text('Unable to launch phone app. Please check your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
        */
                  // Call Now Button (Accent Color)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      // _callNow
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizer.deviceHeight2,
                        ),
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
            Icon(icon, color: AppColors.accentColor, size: AppSizer.deviceSp24),
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

  Widget _buildFeeGrid() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth3),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: _feeStructure.entries.map((e) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.key,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  e.value,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.successColor,
            size: AppSizer.deviceSp16,
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: AppSizer.deviceSp14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.star,
            color: AppColors.accentColor,
            size: AppSizer.deviceSp16,
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: AppSizer.deviceSp14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTechChips() {
    final techList = [
      'Python',
      'ASP.NET',
      'Java',
      'PHP',
      'Android',
      'MERN',
      'Embedded with IoT',
      'AI/ML',
      'CAD/AutoCAD',
    ];
    return Wrap(
      spacing: AppSizer.deviceWidth2,
      runSpacing: AppSizer.deviceHeight2,
      children: techList.map((name) {
        final fakeTech = Technology(
          id: name,
          name: name,
          icon: '💻',
          category: 'popular',
        );
        final isSelected = _selectedTechnology?.id == fakeTech.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedTechnology = fakeTech),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizer.deviceWidth4,
              vertical: AppSizer.deviceHeight1_5,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentColor : AppColors.cardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppColors.accentColor : AppColors.outline,
                width: 1,
              ),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textColor,
                fontSize: AppSizer.deviceSp14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
