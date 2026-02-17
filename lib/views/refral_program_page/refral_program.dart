// import 'package:flutter/material.dart';
// import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
// import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

// class RefralProgram extends StatefulWidget {
//   const RefralProgram({super.key});

//   @override
//   State<RefralProgram> createState() => _RefralProgramState();
// }

// class _RefralProgramState extends State<RefralProgram> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _collegeController = TextEditingController();
//   final TextEditingController _courseController = TextEditingController();

//   bool _isRegistered = false;
//   String _referralCode = "CAD2024AMB9876";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           _isRegistered ? 'Campus Ambassador' : 'Join Ambassador Program',
//           style: TextStyle(
//             fontSize: AppSizer.deviceSp18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: AppColors.accentColor,
//         foregroundColor: AppColors.backgroundColor,
//       ),
//       body: _isRegistered ? _buildAmbassadorDashboard() : _buildRegistrationForm(),
//     );
//   }

//   Widget _buildRegistrationForm() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(AppSizer.deviceWidth4),
//       child: Column(
//         children: [
//           // Header Section
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(AppSizer.deviceWidth6),
//             margin: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.primaryColor, AppColors.accentColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.people_alt_rounded,
//                   size: AppSizer.deviceSp48,
//                   color: AppColors.backgroundColor,
//                 ),
//                 SizedBox(height: AppSizer.deviceHeight2),
//                 Text(
//                   'Become a Campus Ambassador',
//                   style: TextStyle(
//                     fontSize: AppSizer.deviceSp20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.backgroundColor,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: AppSizer.deviceHeight1),
//                 Text(
//                   'Represent CodersAdda in your college & earn exciting rewards!',
//                   style: TextStyle(
//                     fontSize: AppSizer.deviceSp16,
//                     color: AppColors.backgroundColor,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),

//           // Benefits Cards
//           Container(
//             height: AppSizer.deviceHeight16,
//             margin: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _buildBenefitCard('🎁', 'Cash Rewards', 'Earn up to ₹10,000'),
//                 _buildBenefitCard('🏆', 'Certification', 'Get official certificate'),
//                // _buildBenefitCard('💼', 'Internship', 'Priority internship access'),
//                 _buildBenefitCard('📚', 'Free Courses', 'Access premium courses'),
//               ],
//             ),
//           ),

//           // Registration Form
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(AppSizer.deviceWidth6),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Personal Details',
//                       style: TextStyle(
//                         fontSize: AppSizer.deviceSp18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textColor,
//                       ),
//                     ),
//                     SizedBox(height: AppSizer.deviceHeight3),

//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Full Name',
//                         prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
//                     ),
//                     SizedBox(height: AppSizer.deviceHeight2),

//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email Address',
//                         prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value!.isEmpty) return 'Please enter your email';
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
//                           return 'Enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: AppSizer.deviceHeight2),

//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: InputDecoration(
//                         labelText: 'Phone Number',
//                         prefixIcon: Icon(Icons.phone, color: AppColors.primaryColor),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       keyboardType: TextInputType.phone,
//                       validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
//                     ),
//                     SizedBox(height: AppSizer.deviceHeight2),

//                     TextFormField(
//                       controller: _collegeController,
//                       decoration: InputDecoration(
//                         labelText: 'College Name',
//                         prefixIcon: Icon(Icons.school, color: AppColors.primaryColor),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       validator: (value) => value!.isEmpty ? 'Please enter your college name' : null,
//                     ),
//                     SizedBox(height: AppSizer.deviceHeight2),

//                     TextFormField(
//                       controller: _courseController,
//                       decoration: InputDecoration(
//                         labelText: 'Course/Stream',
//                         prefixIcon: Icon(Icons.menu_book, color: AppColors.primaryColor),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.primaryColor),
//                         ),
//                       ),
//                       validator: (value) => value!.isEmpty ? 'Please enter your course' : null,
//                     ),
//                     SizedBox(height: AppSizer.deviceHeight4),

//                     SizedBox(
//                       width: double.infinity,
//                       height: AppSizer.deviceHeight7,
//                       child: ElevatedButton(
//                         onPressed: _submitForm,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryColor,
//                           foregroundColor: AppColors.backgroundColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: Text(
//                           'Become Ambassador',
//                           style: TextStyle(
//                             fontSize: AppSizer.deviceSp16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAmbassadorDashboard() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(AppSizer.deviceWidth4),
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(AppSizer.deviceWidth6),
//             margin: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.primaryColor, AppColors.accentColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.verified,
//                   size: AppSizer.deviceSp48,
//                   color: AppColors.backgroundColor,
//                 ),
//                 SizedBox(height: AppSizer.deviceHeight2),
//                 Text(
//                   'Welcome Ambassador!',
//                   style: TextStyle(
//                     fontSize: AppSizer.deviceSp20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.backgroundColor,
//                   ),
//                 ),
//                 SizedBox(height: AppSizer.deviceHeight1),
//                 Text(
//                   'Start referring and earn amazing rewards',
//                   style: TextStyle(
//                     fontSize: AppSizer.deviceSp14,
//                     color: AppColors.backgroundColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(AppSizer.deviceWidth6),
//               child: Column(
//                 children: [
//                   Text(
//                     'Your Referral Code',
//                     style: TextStyle(
//                       fontSize: AppSizer.deviceSp16,
//                       color: AppColors.onSurfaceVariant,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight2),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: AppSizer.deviceWidth6,
//                       vertical: AppSizer.deviceHeight2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.primaryColor),
//                     ),
//                     child: Text(
//                       _referralCode,
//                       style: TextStyle(
//                         fontSize: AppSizer.deviceSp24,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primaryColor,
//                         letterSpacing: 2,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight2),
//                   Text(
//                     'Share this code with your friends',
//                     style: TextStyle(
//                       fontSize: AppSizer.deviceSp14,
//                       color: AppColors.onSurfaceVariant,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight3),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: _shareReferralCode,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryColor,
//                             foregroundColor: AppColors.backgroundColor,
//                             padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
//                           ),
//                           icon: Icon(Icons.share),
//                           label: Text('Share Code'),
//                         ),
//                       ),
//                       SizedBox(width: AppSizer.deviceWidth2),
//                       IconButton(
//                         onPressed: _copyReferralCode,
//                         icon: Icon(Icons.copy, color: AppColors.primaryColor),
//                         style: IconButton.styleFrom(
//                           backgroundColor: AppColors.primaryColor.withOpacity(0.1),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: AppSizer.deviceHeight4),
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(AppSizer.deviceWidth6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Your Rewards',
//                     style: TextStyle(
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight3),
//                   _buildRewardItem('👥', 'Per Referral', '₹200 cashback'),
//                   _buildRewardItem('💰', 'Total Earned', '₹0'),
//                   _buildRewardItem('🎯', 'Successful Referrals', '0'),
//                   _buildRewardItem('🏆', 'Ambassador Level', 'Bronze'),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: AppSizer.deviceHeight4),

//           // How it Works
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(AppSizer.deviceWidth6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'How it Works',
//                     style: TextStyle(
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight3),
//                   _buildStepItem('1', 'Share your referral code with friends'),
//                   _buildStepItem('2', 'Friends sign up using your code'),
//                   _buildStepItem('3', 'They purchase any course or subscription'),
//                   _buildStepItem('4', 'You get ₹200 cashback per successful referral'),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitCard(String emoji, String title, String subtitle) {
//     return Container(
//       width: AppSizer.deviceWidth35,
//       margin: EdgeInsets.only(right: AppSizer.deviceWidth2),
//       padding: EdgeInsets.all(AppSizer.deviceWidth4),
//       decoration: BoxDecoration(
//         color: AppColors.primaryColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
//         border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(emoji, style: TextStyle(fontSize: AppSizer.deviceSp20)),
//           SizedBox(height: AppSizer.deviceHeight1),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: AppSizer.deviceSp14,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryColor,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: AppSizer.deviceHeight0_5),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: AppSizer.deviceSp12,
//               color: AppColors.onSurfaceVariant,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRewardItem(String emoji, String title, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
//       child: Row(
//         children: [
//           Text(emoji, style: TextStyle(fontSize: AppSizer.deviceSp20)),
//           SizedBox(width: AppSizer.deviceWidth3),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: AppSizer.deviceSp16,
//                 color: AppColors.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: AppSizer.deviceSp16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepItem(String step, String description) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: AppSizer.deviceWidth8,
//             height: AppSizer.deviceWidth8,
//             decoration: BoxDecoration(
//               color: AppColors.primaryColor,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 step,
//                 style: TextStyle(
//                   color: AppColors.backgroundColor,
//                   fontSize: AppSizer.deviceSp12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: AppSizer.deviceWidth3),
//           Expanded(
//             child: Text(
//               description,
//               style: TextStyle(
//                 fontSize: AppSizer.deviceSp14,
//                 color: AppColors.textColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Form is valid, show success and navigate to dashboard
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Application Submitted!'),
//           content: Text('Welcome to CodersAdda Campus Ambassador Program! Your referral code is $_referralCode'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 setState(() {
//                   _isRegistered = true;
//                 });
//               },
//               child: Text('Get Started'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   void _shareReferralCode() {
//     // Implement share functionality
//     print('Sharing referral code: $_referralCode');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Referral code copied to clipboard!'),
//         backgroundColor: AppColors.primaryColor,
//       ),
//     );
//   }

//   void _copyReferralCode() {
//     // Implement copy to clipboard
//     print('Copied referral code: $_referralCode');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Referral code copied to clipboard!'),
//         backgroundColor: AppColors.primaryColor,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _collegeController.dispose();
//     _courseController.dispose();
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class RefralProgram extends StatefulWidget {
  const RefralProgram({super.key});

  @override
  State<RefralProgram> createState() => _RefralProgramState();
}

class _RefralProgramState extends State<RefralProgram> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  bool _isRegistered = false;
  String _referralCode = "CAD2024AMB9876";
  int _successfulReferrals = 0;
  double _totalEarned = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          _isRegistered ? 'Campus Ambassador' : 'Join Ambassador Program',
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isRegistered ? _buildAmbassadorDashboard() : _buildRegistrationForm(),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth6),
            margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                
                Text(
                  'Become a Campus Ambassador',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                Text(
                  'Represent CodersAdda in your college & earn exciting rewards!',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Benefits Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: AppSizer.deviceWidth3,
            mainAxisSpacing: AppSizer.deviceHeight2,
            padding: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
            children: [
              _buildBenefitCard('💸', 'Cash Rewards', 'Earn up to ₹10,000', Colors.orange),
              _buildBenefitCard('🏆', 'Certification', 'Official certificate', Colors.blue),
              _buildBenefitCard('📚', 'Free Courses', 'Premium access', Colors.green),
              _buildBenefitCard('🚀', 'Growth', 'Build your network', Colors.purple),
            ],
          ),

          // Registration Form
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: AppColors.primaryColor.withOpacity(0.2),
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth6),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSizer.deviceWidth2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1,
                            color: AppColors.primaryColor,
                            size: AppSizer.deviceSp20,
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth3),
                        Text(
                          'Personal Details',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight3),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    SizedBox(height: AppSizer.deviceHeight3),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizer.deviceHeight3),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_iphone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    SizedBox(height: AppSizer.deviceHeight3),

                    _buildTextField(
                      controller: _collegeController,
                      label: 'College Name',
                      icon: Icons.school_outlined,
                      validator: (value) => value!.isEmpty ? 'Please enter your college name' : null,
                    ),
                    SizedBox(height: AppSizer.deviceHeight3),

                    _buildTextField(
                      controller: _courseController,
                      label: 'Course/Stream',
                      icon: Icons.menu_book_outlined,
                      validator: (value) => value!.isEmpty ? 'Please enter your course' : null,
                    ),
                    SizedBox(height: AppSizer.deviceHeight6),

                    SizedBox(
                      width: double.infinity,
                      height: AppSizer.deviceHeight7,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          shadowColor: AppColors.primaryColor.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded, size: AppSizer.deviceSp18),
                            SizedBox(width: AppSizer.deviceWidth2),
                            Text(
                              'Become Ambassador',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbassadorDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth6),
            margin: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    size: AppSizer.deviceSp30,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Ambassador!',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        'Start referring and earn amazing rewards',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Referral Code Card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: AppColors.primaryColor.withOpacity(0.2),
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_2_rounded, color: AppColors.primaryColor),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Text(
                        'Your Referral Code',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight3),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth6,
                      vertical: AppSizer.deviceHeight3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor.withOpacity(0.1), AppColors.accentColor.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        _referralCode,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  Text(
                    'Share this code with your friends',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight4),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareReferralCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: Icon(Icons.share_rounded, size: AppSizer.deviceSp18),
                          label: Text(
                            'Share Code',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: IconButton(
                          onPressed: _copyReferralCode,
                          icon: Icon(Icons.copy_rounded, color: AppColors.primaryColor),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppSizer.deviceHeight4),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: AppSizer.deviceWidth3,
            mainAxisSpacing: AppSizer.deviceHeight3,
            padding: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
            children: [
              _buildStatCard('Total Earned', '₹$_totalEarned', '💰', Colors.green),
              _buildStatCard('Successful Referrals', '$_successfulReferrals', '👥', Colors.blue),
              _buildStatCard('Pending Rewards', '₹${_successfulReferrals * 200}', '⏳', Colors.orange),
              _buildStatCard('Ambassador Level', 'Bronze', '🏆', Colors.purple),
            ],
          ),

          // How it Works
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: AppColors.primaryColor.withOpacity(0.2),
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.leaderboard_rounded, color: AppColors.primaryColor),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Text(
                        'How it Works',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight4),
                  _buildStepItem('1', 'Share your unique referral code with friends'),
                  _buildStepItem('2', 'Friends sign up on CodersAdda using your code'),
                  _buildStepItem('3', 'They purchase any course or subscription'),
                  _buildStepItem('4', 'You get ₹200 cashback per successful referral'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String emoji, String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: AppSizer.deviceSp24)),
          SizedBox(height: AppSizer.deviceHeight2),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppSizer.deviceSp11,
              color: AppColors.onSurfaceVariant,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: AppSizer.deviceSp20)),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp11,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: EdgeInsets.only(right: AppSizer.deviceWidth2),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColors.primaryColor.withOpacity(0.3), width: 1),
            ),
          ),
          child: Icon(icon, color: AppColors.primaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth4,
          vertical: AppSizer.deviceHeight1,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildStepItem(String step, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizer.deviceWidth8,
            height: AppSizer.deviceWidth8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizer.deviceSp12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth4),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: AppColors.textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, show success and navigate to dashboard
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration_rounded, color: AppColors.primaryColor),
              SizedBox(width: AppSizer.deviceWidth2),
              Text('Application Submitted!'),
            ],
          ),
          content: Text(
            'Welcome to CodersAdda Campus Ambassador Program! Your referral code is $_referralCode',
            style: TextStyle(fontSize: AppSizer.deviceSp14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isRegistered = true;
                });
              },
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _shareReferralCode() {
    // Implement share functionality
    print('Sharing referral code: $_referralCode');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code shared successfully!'),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _copyReferralCode() {
    // Implement copy to clipboard
    print('Copied referral code: $_referralCode');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code copied to clipboard!'),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    super.dispose();
  }
}