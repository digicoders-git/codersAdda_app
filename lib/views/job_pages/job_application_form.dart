import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/veiw_model/job_application_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class JobApplicationForm extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;

  const JobApplicationForm({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
  }) : super(key: key);

  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Section 1 : Personal Information
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String gender = 'Male';

  // Section 2 : Professional Information
  final TextEditingController currentJobTitleController = TextEditingController();
  String experienceType = 'Fresher';
  final TextEditingController totalExperienceController = TextEditingController();
  final TextEditingController currentCompanyController = TextEditingController();
  final TextEditingController currentSalaryController = TextEditingController();
  final TextEditingController expectedSalaryController = TextEditingController();
  final TextEditingController noticePeriodController = TextEditingController();

  // Section 3 : Education
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController passingYearController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();

  // Section 4 : Key Skills
  List<String> selectedSkills = [];
  final TextEditingController customSkillController = TextEditingController();
  final List<String> availableSkills = [
    'PHP', 'Laravel', 'Flutter', 'React', 'Node.js', 'MongoDB', 
    'MySQL', 'JavaScript', 'HTML', 'CSS', 'Bootstrap', 'Python', 
    'Java', 'C++', 'Git', 'REST API'
  ];

  // Section 9 : Declaration
  bool isDeclared = false;

  // Section 5 : Professional Links
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController gitHubController = TextEditingController();
  final TextEditingController portfolioController = TextEditingController();

  // Section 6 : Preferences
  final TextEditingController preferredLocationController = TextEditingController();
  String workType = 'Full-time';
  String relocate = 'Yes';

  // Section 7 : Cover Letter
  final TextEditingController coverLetterController = TextEditingController();

  // Section 8 : Resume Upload
  File? resumeFile;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data from SharedPreferences and Profile
    _loadSavedFormData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<ProfileViewModel>(context, listen: false).user;
      if (profile != null) {
        if (fullNameController.text.isEmpty) fullNameController.text = profile.name ?? '';
        if (emailController.text.isEmpty) emailController.text = profile.email ?? '';
        if (mobileController.text.isEmpty) mobileController.text = profile.mobile ?? '';
      }
    });
  }

  Future<void> _loadSavedFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullNameController.text = prefs.getString('job_fullName') ?? '';
      emailController.text = prefs.getString('job_email') ?? '';
      mobileController.text = prefs.getString('job_mobile') ?? '';
      cityController.text = prefs.getString('job_city') ?? '';
      stateController.text = prefs.getString('job_state') ?? '';
      dobController.text = prefs.getString('job_dob') ?? '';
      gender = prefs.getString('job_gender') ?? 'Male';
      
      currentJobTitleController.text = prefs.getString('job_currentJobTitle') ?? '';
      experienceType = prefs.getString('job_experience') ?? 'Fresher';
      totalExperienceController.text = prefs.getString('job_totalExperience') ?? '';
      currentCompanyController.text = prefs.getString('job_currentCompany') ?? '';
      currentSalaryController.text = prefs.getString('job_currentSalary') ?? '';
      expectedSalaryController.text = prefs.getString('job_expectedSalary') ?? '';
      noticePeriodController.text = prefs.getString('job_noticePeriod') ?? '';
      
      qualificationController.text = prefs.getString('job_qualification') ?? '';
      collegeController.text = prefs.getString('job_college') ?? '';
      passingYearController.text = prefs.getString('job_passingYear') ?? '';
      percentageController.text = prefs.getString('job_percentage') ?? '';
      
      String skillsStr = prefs.getString('job_skills') ?? '';
      if (skillsStr.isNotEmpty) {
        selectedSkills = skillsStr.split(',');
      }
      
      linkedInController.text = prefs.getString('job_linkedIn') ?? '';
      gitHubController.text = prefs.getString('job_gitHub') ?? '';
      portfolioController.text = prefs.getString('job_portfolio') ?? '';
      
      preferredLocationController.text = prefs.getString('job_preferredLocation') ?? '';
      workType = prefs.getString('job_workType') ?? 'Full-time';
      relocate = prefs.getString('job_relocate') ?? 'Yes';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('job_fullName', fullNameController.text.trim());
    await prefs.setString('job_email', emailController.text.trim());
    await prefs.setString('job_mobile', mobileController.text.trim());
    await prefs.setString('job_city', cityController.text.trim());
    await prefs.setString('job_state', stateController.text.trim());
    await prefs.setString('job_dob', dobController.text.trim());
    await prefs.setString('job_gender', gender);
    
    await prefs.setString('job_currentJobTitle', currentJobTitleController.text.trim());
    await prefs.setString('job_experience', experienceType);
    await prefs.setString('job_totalExperience', totalExperienceController.text.trim());
    await prefs.setString('job_currentCompany', currentCompanyController.text.trim());
    await prefs.setString('job_currentSalary', currentSalaryController.text.trim());
    await prefs.setString('job_expectedSalary', expectedSalaryController.text.trim());
    await prefs.setString('job_noticePeriod', noticePeriodController.text.trim());
    
    await prefs.setString('job_qualification', qualificationController.text.trim());
    await prefs.setString('job_college', collegeController.text.trim());
    await prefs.setString('job_passingYear', passingYearController.text.trim());
    await prefs.setString('job_percentage', percentageController.text.trim());
    
    await prefs.setString('job_skills', selectedSkills.join(','));
    
    await prefs.setString('job_linkedIn', linkedInController.text.trim());
    await prefs.setString('job_gitHub', gitHubController.text.trim());
    await prefs.setString('job_portfolio', portfolioController.text.trim());
    
    await prefs.setString('job_preferredLocation', preferredLocationController.text.trim());
    await prefs.setString('job_workType', workType);
    await prefs.setString('job_relocate', relocate);
  }

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) { // 5MB
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File size exceeds 5 MB. Please upload a smaller file.')),
        );
        return;
      }
      setState(() {
        resumeFile = file;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields correctly.')),
      );
      return;
    }

    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one skill.')),
      );
      return;
    }

    if (resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload your resume (PDF/DOC/DOCX).')),
      );
      return;
    }

    if (!isDeclared) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please check the declaration box.')),
      );
      return;
    }

    final formData = {
      'fullName': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'mobile': mobileController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'dob': dobController.text.trim(),
      'gender': gender,
      'currentJobTitle': currentJobTitleController.text.trim(),
      'experience': experienceType,
      'totalExperience': totalExperienceController.text.trim(),
      'currentCompany': currentCompanyController.text.trim(),
      'currentSalary': currentSalaryController.text.trim(),
      'expectedSalary': expectedSalaryController.text.trim(),
      'noticePeriod': noticePeriodController.text.trim(),
      'qualification': qualificationController.text.trim(),
      'college': collegeController.text.trim(),
      'passingYear': passingYearController.text.trim(),
      'percentage': percentageController.text.trim(),
      'skills': selectedSkills.join(','),
      'linkedIn': linkedInController.text.trim(),
      'gitHub': gitHubController.text.trim(),
      'portfolio': portfolioController.text.trim(),
      'preferredLocation': preferredLocationController.text.trim(),
      'workType': workType,
      'relocate': relocate,
      'coverLetter': coverLetterController.text.trim(),
    };

    final viewModel = Provider.of<JobApplicationViewModel>(context, listen: false);
    final success = await viewModel.submitApplication(widget.jobId, formData, resumeFile!.path);

    if (success) {
      await _saveFormData();
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Success!'),
            ],
          ),
          content: Text('Your application has been submitted successfully.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Go back to Job Details and pass true
              },
              child: Text('Go Back to Job'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to apply.')),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem(value: item, child: Text(item, style: TextStyle(fontSize: 15.sp)));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Apply for ${widget.jobTitle}', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Consumer<JobApplicationViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(5.w),
              children: [
                // Info Banner
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business_center, color: AppColors.primaryColor, size: 6.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'You are applying to ${widget.companyName}. Please complete your profile for better chances.',
                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 2.h),

                // 1. Personal Information
                _buildSectionHeader('1. Personal Information'),
                _buildTextField(controller: fullNameController, label: 'Full Name', isRequired: true),
                _buildTextField(controller: emailController, label: 'Email Address', isRequired: true, keyboardType: TextInputType.emailAddress),
                _buildTextField(controller: mobileController, label: 'Mobile Number', isRequired: true, keyboardType: TextInputType.phone),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: cityController, label: 'Current City', isRequired: true)),
                    SizedBox(width: 3.w),
                    Expanded(child: _buildTextField(controller: stateController, label: 'State', isRequired: true)),
                  ],
                ),
                Row(
                  children: [
                     Expanded(
                       child: TextFormField(
                         controller: dobController,
                         keyboardType: TextInputType.number,
                         inputFormatters: [DateInputFormatter()],
                         decoration: InputDecoration(
                           labelText: 'Date of Birth (DD/MM/YYYY)',
                           hintText: 'DD/MM/YYYY',
                           prefixIcon: Icon(Icons.cake_outlined),
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                           focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(10),
                             borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
                           ),
                         ),
                       ),
                     ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Gender', 
                        value: gender, 
                        items: ['Male', 'Female', 'Other'], 
                        onChanged: (v) => setState(() => gender = v!)
                      )
                    ),
                  ],
                ),

                // 2. Professional Information
                _buildSectionHeader('2. Professional Information'),
                _buildDropdown(
                  label: 'Experience Level', 
                  value: experienceType, 
                  items: ['Fresher', 'Experienced'], 
                  onChanged: (v) => setState(() => experienceType = v!)
                ),
                if (experienceType == 'Experienced') ...[
                  _buildTextField(controller: currentJobTitleController, label: 'Current Job Title'),
                  _buildTextField(controller: totalExperienceController, label: 'Total Experience (e.g., 2 Years)'),
                  _buildTextField(controller: currentCompanyController, label: 'Current Company'),
                  _buildTextField(controller: currentSalaryController, label: 'Current Salary (LPA)', keyboardType: TextInputType.number),
                  _buildTextField(controller: noticePeriodController, label: 'Notice Period (Days)', keyboardType: TextInputType.number),
                ],
                _buildTextField(controller: expectedSalaryController, label: 'Expected Salary (LPA)', keyboardType: TextInputType.number),

                // 3. Education
                _buildSectionHeader('3. Education'),
                _buildTextField(controller: qualificationController, label: 'Highest Qualification (e.g. B.Tech)', isRequired: true),
                _buildTextField(controller: collegeController, label: 'College / University Name', isRequired: true),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: passingYearController, label: 'Passing Year', keyboardType: TextInputType.number)),
                    SizedBox(width: 3.w),
                    Expanded(child: _buildTextField(controller: percentageController, label: 'Percentage / CGPA')),
                  ],
                ),

                // 4. Key Skills
                _buildSectionHeader('4. Key Skills *'),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: availableSkills.map((skill) {
                    final isSelected = selectedSkills.contains(skill);
                    return ChoiceChip(
                      label: Text(skill),
                      selected: isSelected,
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSkills.add(skill);
                          } else {
                            selectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: customSkillController,
                        label: 'Add Custom Skill',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    ElevatedButton(
                      onPressed: () {
                        final skill = customSkillController.text.trim();
                        if (skill.isNotEmpty && !selectedSkills.contains(skill) && !availableSkills.contains(skill)) {
                          setState(() {
                            availableSkills.add(skill);
                            selectedSkills.add(skill);
                            customSkillController.clear();
                          });
                        }
                      },
                      child: Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                // 5. Professional Links
                _buildSectionHeader('5. Professional Links'),
                _buildTextField(controller: linkedInController, label: 'LinkedIn Profile URL'),
                _buildTextField(controller: gitHubController, label: 'GitHub Profile URL'),
                _buildTextField(controller: portfolioController, label: 'Portfolio Website URL'),

                // 6. Preferences
                _buildSectionHeader('6. Preferences'),
                _buildTextField(controller: preferredLocationController, label: 'Preferred Job Location(s)'),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Work Type', 
                        value: workType, 
                        items: ['Full-time', 'Part-time', 'Contract', 'Internship'], 
                        onChanged: (v) => setState(() => workType = v!)
                      )
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Willing to Relocate?', 
                        value: relocate, 
                        items: ['Yes', 'No'], 
                        onChanged: (v) => setState(() => relocate = v!)
                      )
                    ),
                  ],
                ),

                // 7. Cover Letter
                _buildSectionHeader('7. Cover Letter'),
                _buildTextField(
                  controller: coverLetterController, 
                  label: 'Why should we hire you? (Optional)', 
                  maxLines: 4
                ),

                // 8. Resume Upload
                _buildSectionHeader('8. Upload Resume'),
                GestureDetector(
                  onTap: _pickResume,
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.upload_file, size: 10.w, color: resumeFile == null ? Colors.grey : AppColors.primaryColor),
                        SizedBox(height: 1.h),
                        Text(
                          resumeFile == null ? 'Tap to upload Resume (PDF/DOC)' : 'Selected: ${resumeFile!.path.split('/').last}',
                          style: TextStyle(fontSize: 15.sp, color: resumeFile == null ? Colors.grey.shade600 : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // 9. Declaration
                _buildSectionHeader('9. Declaration'),
                CheckboxListTile(
                  title: Text(
                    'I confirm that the information provided is accurate and I understand that any false information may lead to the rejection of my application.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                  ),
                  value: isDeclared,
                  onChanged: (val) {
                    setState(() {
                      isDeclared = val ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 5.h),

                // 10. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Application', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Auto-formats date as user types: 04042007 → 04/04/2007
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');

    if (digits.length > 8) {
      return oldValue; // Max 8 digits
    }

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
