import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/application_submitted_page.dart';

class JoinAmbassadorPage extends StatefulWidget {
  final bool isReapplying;

  const JoinAmbassadorPage({super.key, this.isReapplying = false});

  @override
  State<JoinAmbassadorPage> createState() => _JoinAmbassadorPageState();
}

class _JoinAmbassadorPageState extends State<JoinAmbassadorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  final ApiClient _apiClient = ApiClient();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      final user = profileVM.user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.mobile;
        _collegeController.text = user.college;
        _courseController.text = user.course;
      } else {
        profileVM.fetchUserProfile().then((_) {
          final u = profileVM.user;
          if (u != null && mounted) {
            setState(() {
              _nameController.text = u.name;
              _emailController.text = u.email;
              _phoneController.text = u.mobile;
              _collegeController.text = u.college;
              _courseController.text = u.course;
            });
          }
        });
      }
    });
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

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> data = {
        "fullName": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "collegeName": _collegeController.text.trim(),
        "courseStream": _courseController.text.trim(),
      };

      final response = await _apiClient.post(ApiUrls.applyAmbassador, data);

      setState(() => _isSubmitting = false);

      if (response != null && response['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationSubmittedPage(initialData: response),
          ),
        );
      } else {
        final msg = response?['message'] ?? 'Failed to submit application.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            // Top Hero Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052FF).withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Become a',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0B1033),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Campus\nAmbassador',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0052FF),
                                  height: 1.15,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceHeight1),
                            Text(
                              'Represent CodersAdda in your college & earn exciting rewards!',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth2),
                      // 3D Megaphone student image
                      SizedBox(
                        width: 105,
                        height: 105,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/ambassador_hero.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFEFF6FF),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFF0052FF),
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizer.deviceHeight2),

                  // 3 Feature Badges Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildPillBadge(
                          icon: Icons.groups_rounded,
                          label: 'Build Your\nNetwork',
                          color: const Color(0xFF0052FF),
                          bgColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Expanded(
                        child: _buildPillBadge(
                          icon: Icons.card_giftcard_rounded,
                          label: 'Earn\nRewards',
                          color: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFFFBEB),
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Expanded(
                        child: _buildPillBadge(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Get\nCertificate',
                          color: const Color(0xFF10B981),
                          bgColor: const Color(0xFFECFDF5),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizer.deviceHeight2),

                  // Quote Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Center(
                      child: Text(
                        '“Be the voice of CodersAdda on your campus!”',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0033CC),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight2_5),

            // Form Section Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4_5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF0052FF),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth2_5),
                        Text(
                          'Personal Details',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B1033),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),

                    // Full Name
                    _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your full name' : null,
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),

                    // Email Address
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(val.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),

                    // Phone Number
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your 10-digit mobile number',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your phone number';
                        if (val.trim().length < 10) return 'Enter a valid 10-digit number';
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),

                    // College Name
                    _buildInputField(
                      controller: _collegeController,
                      label: 'College Name',
                      hint: 'Enter your college name',
                      icon: Icons.school_outlined,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your college name' : null,
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),

                    // Course / Stream
                    _buildInputField(
                      controller: _courseController,
                      label: 'Course / Stream',
                      hint: 'Select your course (e.g. B.Tech CS, BCA)',
                      icon: Icons.menu_book_rounded,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your course / stream' : null,
                    ),

                    SizedBox(height: AppSizer.deviceHeight3),

                    // Apply Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Apply Now',
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
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizer.deviceSp10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B1033),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0B1033),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0052FF), size: 20),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: AppSizer.deviceSp12,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
