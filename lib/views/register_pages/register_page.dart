import 'package:coders_adda_app/veiw_model/register_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              "Student Registration",
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizer.deviceWidth6),
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizer.deviceWidth6),
                  margin: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        size: AppSizer.deviceSp48,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: AppSizer.deviceHeight2),
                      Text(
                        "Join Coders Adda",
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        "Register with your details to get started",
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp14,
                          color: AppColors.onSurfaceVariant,
                          //textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Registration Form
                Container(
                  padding: EdgeInsets.all(AppSizer.deviceWidth6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        Text(
                          "Full Name",
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        TextFormField(
                          controller: viewModel.nameController,
                          decoration: InputDecoration(
                            hintText: "Enter your full name",
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          style: TextStyle(fontSize: AppSizer.deviceSp14),
                          validator: (value) =>
                              value!.isEmpty ? "Please enter your name" : null,
                        ),
                        
                        SizedBox(height: AppSizer.deviceHeight4),
                        
                        // Email Field
                        Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        TextFormField(
                          controller: viewModel.emailController,
                          decoration: InputDecoration(
                            hintText: "Enter your email address",
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: AppSizer.deviceSp14),
                          validator: (value) {
                            if (value!.isEmpty) return "Please enter your email";
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                                .hasMatch(value)) return "Enter a valid email address";
                            return null;
                          },
                        ),
                        
                        SizedBox(height: AppSizer.deviceHeight6),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: AppSizer.deviceHeight7,
                          child: ElevatedButton(
                            onPressed: () => viewModel.submitForm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: viewModel.isLoading
                                ? SizedBox(
                                    height: AppSizer.deviceSp20,
                                    width: AppSizer.deviceSp20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Register Now",
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        SizedBox(height: AppSizer.deviceHeight3),
                        
                        // Terms Text
                        Text(
                          "By registering, you agree to our Terms of Service and Privacy Policy",
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: AppColors.onSurfaceVariant,
                            //textAlign: TextAlign.center,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }
}