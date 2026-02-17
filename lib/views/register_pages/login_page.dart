// import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
// import 'package:coders_adda_app/views/navigation_class.dart';
// import 'package:coders_adda_app/views/register_pages/register_page.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
// import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   bool _isOtpSent = false;

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => AuthViewModel(),
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         body: SafeArea(
//           child: Consumer<AuthViewModel>(
//             builder: (context, viewModel, child) {
//               return SingleChildScrollView(
//                 padding: EdgeInsets.all(AppSizer.deviceWidth6),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: AppSizer.deviceHeight2),

//                     // Skip Button at top right
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => MainNavigation(),
//                             ),
//                             (route) => false,
//                           );
//                         },
//                         child: Text(
//                           'Skip',
//                           style: TextStyle(
//                             color: AppColors.onSurfaceVariant,
//                             fontSize: AppSizer.deviceSp16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: AppSizer.deviceHeight2),

//                     // Header with Logo
//                     _buildHeader(),
//                     SizedBox(height: AppSizer.deviceHeight3),

//                     // Login Form
//                     _buildLoginForm(viewModel),
//                     SizedBox(height: AppSizer.deviceHeight4),

//                     // Error Message
//                     if (viewModel.errorMessage != null)
//                       _buildErrorMessage(viewModel.errorMessage!),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Center(
//       child: Column(
//         children: [
//           // Logo Container with shadow
//           Container(
//             width: AppSizer.deviceWidth25,
//             height: AppSizer.deviceWidth25,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 15,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.asset(
//                 "assets/images/codersaddalogo.png",
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           SizedBox(height: AppSizer.deviceHeight1),

//           // Welcome Text
//           Text(
//             'Welcome to',
//             style: TextStyle(
//               color: AppColors.textColor,
//               fontSize: AppSizer.deviceSp20,
//               fontWeight: FontWeight.w300,
//               letterSpacing: 0.5,
//             ),
//           ),

//           SizedBox(height: AppSizer.deviceHeight1),

//           // CodersAdda Text with gradient
//           ShaderMask(
//             shaderCallback: (bounds) {
//               return LinearGradient(
//                 colors: [AppColors.primaryColor, Color(0xFF6A11CB)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ).createShader(bounds);
//             },
//             child: Text(
//               'CodersAdda',
//               style: TextStyle(
//                 fontSize: AppSizer.deviceSp24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginForm(AuthViewModel viewModel) {
//     return Container(
//       padding: EdgeInsets.all(AppSizer.deviceWidth4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 20,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Phone Number Field
//             if (!_isOtpSent)
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextFormField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   style: TextStyle(
//                     fontSize: AppSizer.deviceSp16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   decoration: InputDecoration(
//                     labelText: 'Phone Number',
//                     labelStyle: TextStyle(
//                       color: AppColors.onSurfaceVariant,
//                       fontSize: AppSizer.deviceSp14,
//                     ),
//                     prefix: Text(
//                       '+91 ',
//                       style: TextStyle(
//                         color: AppColors.textColor,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     prefixIcon: Container(
//                       margin: EdgeInsets.only(right: 8),
//                       child: Icon(
//                         Icons.phone_android_rounded,
//                         color: AppColors.primaryColor,
//                         size: AppSizer.deviceSp20,
//                       ),
//                     ),
//                     prefixIconConstraints: BoxConstraints(
//                       minWidth: 40,
//                       minHeight: 20,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.grey.shade300,
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: AppColors.primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your phone number';
//                     }
//                     if (value.length != 10) {
//                       return 'Please enter a valid 10-digit number';
//                     }
//                     return null;
//                   },
//                 ),
//               ),

//             // OTP Field
//             if (_isOtpSent) ...[
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextFormField(
//                   controller: _otpController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(
//                     fontSize: AppSizer.deviceSp16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   decoration: InputDecoration(
//                     labelText: 'Enter OTP',
//                     labelStyle: TextStyle(
//                       color: AppColors.onSurfaceVariant,
//                       fontSize: AppSizer.deviceSp14,
//                     ),
//                     prefixIcon: Container(
//                       margin: EdgeInsets.only(right: 8),
//                       child: Icon(
//                         Icons.lock_outline_rounded,
//                         color: AppColors.primaryColor,
//                         size: AppSizer.deviceSp20,
//                       ),
//                     ),
//                     prefixIconConstraints: BoxConstraints(
//                       minWidth: 40,
//                       minHeight: 20,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.grey.shade300,
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: AppColors.primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter OTP';
//                     }
//                     if (value.length != 6) {
//                       return 'OTP must be 6 digits';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: AppSizer.deviceHeight2),
//               Container(
//                 padding: EdgeInsets.all(AppSizer.deviceWidth3),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.info_outline_rounded,
//                       color: AppColors.primaryColor,
//                       size: AppSizer.deviceSp16,
//                     ),
//                     SizedBox(width: AppSizer.deviceWidth2),
//                     Text(
//                       'OTP sent to +91 ${_phoneController.text}',
//                       style: TextStyle(
//                         color: AppColors.primaryColor,
//                         fontSize: AppSizer.deviceSp14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],

//             SizedBox(height: AppSizer.deviceHeight4),

//             // Login/Verify Button with gradient
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 gradient: LinearGradient(
//                   colors: [AppColors.primaryColor, AppColors.accentColor],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primaryColor.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: ElevatedButton(
//                 onPressed: viewModel.isLoading
//                     ? null
//                     : () => _handleLogin(viewModel),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   padding: EdgeInsets.symmetric(
//                     vertical: AppSizer.deviceHeight2_5,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: viewModel.isLoading
//                     ? SizedBox(
//                         height: AppSizer.deviceHeight2,
//                         width: AppSizer.deviceHeight2,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 3,
//                         ),
//                       )
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _isOtpSent
//                                 ? Icons.verified_rounded
//                                 : Icons.send_rounded,
//                             color: Colors.white,
//                             size: AppSizer.deviceSp18,
//                           ),
//                           SizedBox(width: AppSizer.deviceWidth2),
//                           Text(
//                             _isOtpSent ? 'Verify OTP' : 'Send OTP',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: AppSizer.deviceSp16,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//               ),
//             ),

//             if (_isOtpSent)
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isOtpSent = false;
//                     _otpController.clear();
//                     viewModel.resetVerification();
//                   });
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.arrow_back_rounded,
//                       color: AppColors.primaryColor,
//                       size: AppSizer.deviceSp16,
//                     ),
//                     SizedBox(width: AppSizer.deviceWidth1),
//                     Text(
//                       'Change Phone Number',
//                       style: TextStyle(
//                         color: AppColors.primaryColor,
//                         fontSize: AppSizer.deviceSp14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             SizedBox(height: AppSizer.deviceHeight4),

//             // Divider with "OR"
        //     Row(
        //       children: [
        //         Expanded(
        //           child: Divider(color: Colors.grey.shade300, thickness: 1),
        //         ),
        //         Padding(
        //           padding: EdgeInsets.symmetric(
        //             horizontal: AppSizer.deviceWidth4,
        //           ),
        //           child: Text(
        //             'OR',
        //             style: TextStyle(
        //               color: Colors.grey.shade600,
        //               fontSize: AppSizer.deviceSp14,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //         ),
        //         Expanded(
        //           child: Divider(color: Colors.grey.shade300, thickness: 1),
        //         ),
        //       ],
        //     ),

        //     SizedBox(height: AppSizer.deviceHeight4),

        //     // Google Login Button
        //     Container(
        //       width: double.infinity,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(12),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black12,
        //             blurRadius: 10,
        //             offset: Offset(0, 3),
        //           ),
        //         ],
        //       ),
        //       child: OutlinedButton.icon(
        //         onPressed: () {
        //           Navigator.pushReplacement(
        //             context,
        //             MaterialPageRoute(builder: (context) => RegisterPage()),
        //           );
        //         },
        //         style: OutlinedButton.styleFrom(
        //           side: BorderSide.none,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           padding: EdgeInsets.symmetric(
        //             vertical: AppSizer.deviceHeight2,
        //           ),
        //           backgroundColor: Colors.white,
        //         ),
        //         icon: Image.asset(
        //           "assets/images/googlelogo.png",
        //           height: AppSizer.deviceHeight3,
        //           width: AppSizer.deviceHeight3,
        //         ),
        //         label: Text(
        //           'Continue with Google',
        //           style: TextStyle(
        //             color: Colors.black87,
        //             fontSize: AppSizer.deviceSp16,
        //             fontWeight: FontWeight.w500,
        //           ),
        //         ),
        //       ),
        //     ),

           
        //   ],
        // ),
//       ),
//     );
//   }

//   Widget _buildErrorMessage(String message) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(AppSizer.deviceWidth4),
//       decoration: BoxDecoration(
//         color: Colors.red.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.error_outline_rounded,
//             color: Colors.red,
//             size: AppSizer.deviceSp18,
//           ),
//           SizedBox(width: AppSizer.deviceWidth2),
//           Expanded(
//             child: Text(
//               message,
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: AppSizer.deviceSp14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleLogin(AuthViewModel viewModel) async {
//     if (!_formKey.currentState!.validate()) return;

//     viewModel.clearError();

//     if (!_isOtpSent) {
//       final response = await viewModel.loginWithPhone(
//         _phoneController.text.trim(),
//       );

//       if (response.success && response.verificationId != null) {
//         setState(() {
//           _isOtpSent = true;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('OTP sent successfully'),
//             backgroundColor: AppColors.successColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       } else if (response.message != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message!),
//             backgroundColor: AppColors.errorColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } else {
//       final response = await viewModel.verifyOtp(_otpController.text.trim());

//       if (response.success) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => MainNavigation()),
//           (route) => false,
//         );
//       } else if (response.message != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message!),
//             backgroundColor: AppColors.errorColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
// }



import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/views/navigation_class.dart';
import 'package:coders_adda_app/views/register_pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _referralController = TextEditingController(); // Referral controller add karein
  final _formKey = GlobalKey<FormState>();
  
  // FocusNode add karein
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isOtpSent = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return GestureDetector(
                // Screen pe tap karte hi keyboard band karein
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizer.deviceWidth6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSizer.deviceHeight2),

                      // Skip Button at top right
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus(); // Keyboard band karein
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainNavigation(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: AppSizer.deviceSp16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppSizer.deviceHeight2),

                      // Header with Logo
                      _buildHeader(),
                      SizedBox(height: AppSizer.deviceHeight3),

                      // Login Form
                      _buildLoginForm(viewModel),
                      SizedBox(height: AppSizer.deviceHeight4),

                      // Error Message
                      if (viewModel.errorMessage != null)
                        _buildErrorMessage(viewModel.errorMessage!),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          // Your existing header code...
          Container(
            width: AppSizer.deviceWidth25,
            height: AppSizer.deviceWidth25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/codersaddalogo.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: AppSizer.deviceHeight1),

          Text(
            'Welcome to',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: AppSizer.deviceHeight1),

          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              'CodersAdda',
              style: TextStyle(
                fontSize: AppSizer.deviceSp24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Phone Number Field
            if (!_isOtpSent)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode, // FocusNode attach karein
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: AppSizer.deviceSp14,
                    ),
                    prefix: Text(
                      '+91 ',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: AppColors.primaryColor,
                        size: AppSizer.deviceSp20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
              ),
            
            if (!_isOtpSent) SizedBox(height: AppSizer.deviceHeight2),

            // Referral Code Field
            if (!_isOtpSent)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _referralController,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Referral Code (Optional)',
                    labelStyle: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: AppSizer.deviceSp14,
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.primaryColor,
                        size: AppSizer.deviceSp20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

            // OTP Field
            if (_isOtpSent) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _otpController,
                  focusNode: _otpFocusNode, // FocusNode attach karein
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    labelStyle: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: AppSizer.deviceSp14,
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primaryColor,
                        size: AppSizer.deviceSp20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight2),
              Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryColor,
                      size: AppSizer.deviceSp16,
                    ),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Text(
                      'OTP sent to +91 ${_phoneController.text}',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSizer.deviceHeight4),

            // Login/Verify Button with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.accentColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => _handleLogin(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizer.deviceHeight2_5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewModel.isLoading
                    ? SizedBox(
                        height: AppSizer.deviceHeight2,
                        width: AppSizer.deviceHeight2,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isOtpSent
                                ? Icons.verified_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: AppSizer.deviceSp18,
                          ),
                          SizedBox(width: AppSizer.deviceWidth2),
                          Text(
                            _isOtpSent ? 'Verify OTP' : 'Send OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppSizer.deviceSp16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            if (_isOtpSent)
              TextButton(
                onPressed: () {
                  // Keyboard band karein aur phone field pe focus le jayein
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isOtpSent = false;
                    _otpController.clear();
                    viewModel.resetVerification();
                  });
                  // Phone field pe focus le jayein
                  Future.delayed(Duration(milliseconds: 300), () {
                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primaryColor,
                      size: AppSizer.deviceSp16,
                    ),
                    SizedBox(width: AppSizer.deviceWidth1),
                    Text(
                      'Change Phone Number',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
SizedBox(height: AppSizer.deviceHeight2),
            // ... Rest of your existing code
             Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth4,
                  ),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),
              ],
            ),

            SizedBox(height: AppSizer.deviceHeight4),

            // Google Login Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizer.deviceHeight2,
                  ),
                  backgroundColor: Colors.white,
                ),
                icon: Image.asset(
                  "assets/images/googlelogo.png",
                  height: AppSizer.deviceHeight3,
                  width: AppSizer.deviceHeight3,
                ),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

           
          ],
        ),
          
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: AppSizer.deviceSp18,
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: AppSizer.deviceSp14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    viewModel.clearError();

    if (!_isOtpSent) {
      // Send OTP case - keyboard band karein
      FocusScope.of(context).unfocus();

      final response = await viewModel.requestOtp(
        _phoneController.text.trim(),
        referralCode: _referralController.text.trim(),
      );

      if (response.success && response.verificationId != null) {
        setState(() {
          _isOtpSent = true;
        });
        
        // OTP field pe automatically focus karein
        Future.delayed(Duration(milliseconds: 500), () {
          FocusScope.of(context).requestFocus(_otpFocusNode);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (response.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message!),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      // Verify OTP case - keyboard band karein
      FocusScope.of(context).unfocus();

      final response = await viewModel.verifyOtp(
        _phoneController.text.trim(),
        _otpController.text.trim(),
        referralCode: _referralController.text.trim(),
      );

      if (response.success) {
        // Fetch user profile after successful login
        if (mounted) {
          context.read<ProfileViewModel>().fetchUserProfile();
        }
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation()),
          (route) => false,
        );
      } else if (response.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message!),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // FocusNode dispose karein
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _referralController.dispose();
    super.dispose();
  }
}