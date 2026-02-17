import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import '../../models/technology_model.dart';

class SummerTrainingPage extends StatefulWidget {
  final List<Technology> technologies;

  const SummerTrainingPage({super.key, required this.technologies});

  @override
  State<SummerTrainingPage> createState() => _SummerTrainingPageState();
}

class _SummerTrainingPageState extends State<SummerTrainingPage> {
  Technology? _selectedTechnology;
  final Map<String, List<Technology>> _categorizedTech = {};

  // Brochure-derived data (from Lucknow Brochure 2026)
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

    // Simulated enroll logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enrollment Successful!'),
        content: Text(
          'You have successfully enrolled in ${_selectedTechnology!.name} Summer Training Program.\n\n'
          'Duration: $_duration\n'
          'Mode: $_mode\n\n'
          'Fee: ${_feeStructure[_selectedTechnology!.name] ?? "Contact for fee details"}\n\n'
          'Our team will contact you soon. For queries call: ${_contactNumbers.first}',
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
          'Summer Training Program',
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
          // Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: AppSizer.deviceHeight12, // Extra padding for button space
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section (Brochure highlight)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '45 Days Intensive Training',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'Job-oriented training in latest technologies. Available in Lucknow, Kanpur & Online.',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: AppSizer.deviceSp14,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight2),
                        Wrap(
                          spacing: AppSizer.deviceWidth3,
                          runSpacing: AppSizer.deviceHeight1,
                          children: [
                            _infoChip(Icons.calendar_today, _duration),
                            _infoChip(Icons.computer, 'Latest Technologies'),
                            _infoChip(Icons.location_on, _mode),
                            _infoChip(
                              Icons.workspace_premium,
                              'Certificate & Support',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // Fees Overview
                  Text(
                    'Fee Structure (sample)',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildFeeGrid(),

                  SizedBox(height: AppSizer.deviceHeight4),

                  // What you will learn
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
                  Container(
                    width: double.infinity,
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
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'Online Registration: https://thedigicoders.com/Home/Registration',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: AppSizer.deviceSp14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: AppSizer.deviceHeight8,
                  ), // Extra space for the fixed button
                ],
              ),
            ),
          ),

          // Fixed Button at Bottom
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
                  // Call Now Button (Accent Color)
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      //_callNow
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

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      backgroundColor: AppColors.cardColor,
      avatar: Icon(
        icon,
        size: AppSizer.deviceSp14,
        color: AppColors.primaryColor,
      ),
      label: Text(text, style: TextStyle(fontSize: AppSizer.deviceSp12)),
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
                    color: AppColors.primaryColor,
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

  Widget _buildTechnologyCategory(
    String categoryName,
    List<Technology> technologies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: AppSizer.deviceSp16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        Wrap(
          spacing: AppSizer.deviceWidth2,
          runSpacing: AppSizer.deviceHeight2,
          children: technologies.map((tech) {
            final isSelected = _selectedTechnology?.id == tech.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedTechnology = tech),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizer.deviceWidth4,
                  vertical: AppSizer.deviceHeight1_5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.cardColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.outline,
                    width: 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tech.icon,
                      style: TextStyle(fontSize: AppSizer.deviceSp16),
                    ),
                    SizedBox(width: AppSizer.deviceWidth1),
                    Text(
                      tech.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textColor,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // If user didn't provide technologies, show popular chips from brochure
  Widget _buildPopularTechChips() {
    final popular = [
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
      children: popular.map((name) {
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
              color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : AppColors.outline,
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
}
