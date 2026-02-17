import 'dart:io';
import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatelessWidget {
  final UserProfile user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.initialized) {
          viewModel.initializeWithUser(user);
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _showDiscardDialog(context),
            ),
            actions: [
              TextButton(
                onPressed: viewModel.isLoading ? null : () => _saveProfile(context, viewModel),
                child: viewModel.isLoading 
                  ? SizedBox(
                      height: AppSizer.deviceSp16,
                      width: AppSizer.deviceSp16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            child: Column(
              children: [
                _buildProfilePhotoSection(context, viewModel),
                SizedBox(height: AppSizer.deviceHeight4),
                _buildPersonalInfoSection(viewModel),
                SizedBox(height: AppSizer.deviceHeight4),
                _buildEducationSection(viewModel),
                SizedBox(height: AppSizer.deviceHeight4),
                _buildSocialLinksSection(viewModel),
                SizedBox(height: AppSizer.deviceHeight4),
                _buildBioSection(viewModel),
                SizedBox(height: AppSizer.deviceHeight6),
                
                _buildBottomSaveButton(context, viewModel),
                SizedBox(height: AppSizer.deviceHeight2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSaveButton(BuildContext context, ProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSizer.deviceHeight7,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _saveProfile(context, viewModel),
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
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          SizedBox(
            width: double.infinity,
            height: AppSizer.deviceHeight6,
            child: OutlinedButton(
              onPressed: () => _showDiscardDialog(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.outline),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context, ProfileViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: AppSizer.deviceWidth25,
                  height: AppSizer.deviceWidth25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 3,
                    ),
                    image: DecorationImage(
                      image: viewModel.selectedImage != null
                          ? FileImage(viewModel.selectedImage!) as ImageProvider
                          : NetworkImage(user.profilePicture.isNotEmpty 
                              ? user.profilePicture 
                              : "https://via.placeholder.com/150"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: AppSizer.deviceWidth8,
                    height: AppSizer.deviceWidth8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white, size: AppSizer.deviceSp16),
                      onPressed: () => _showImagePicker(context, viewModel),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'Only Camera and Gallery uploads allowed',
              style: TextStyle(
                fontSize: AppSizer.deviceSp12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProfileViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            TextFormField(
              controller: viewModel.nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection(ProfileViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Education Details',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            TextFormField(
              controller: viewModel.collegeController,
              decoration: InputDecoration(
                labelText: 'College/University',
                prefixIcon: Icon(Icons.school, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.courseController,
              decoration: InputDecoration(
                labelText: 'Course/Degree',
                prefixIcon: Icon(Icons.menu_book, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: viewModel.semesterController,
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      prefixIcon: Icon(Icons.timeline, color: AppColors.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                Expanded(
                  child: TextFormField(
                    controller: viewModel.branchController,
                    decoration: InputDecoration(
                      labelText: 'Branch',
                      prefixIcon: Icon(Icons.account_tree, color: AppColors.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.technologyController,
              decoration: InputDecoration(
                labelText: 'Technologies (Comma separated)',
                prefixIcon: Icon(Icons.computer, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.skillsController,
              decoration: InputDecoration(
                labelText: 'Skills (Comma separated)',
                prefixIcon: Icon(Icons.auto_awesome, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection(ProfileViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Links',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            TextFormField(
              controller: viewModel.githubController,
              decoration: InputDecoration(
                labelText: 'GitHub Profile URL',
                prefixIcon: Icon(Icons.code, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.linkedinController,
              decoration: InputDecoration(
                labelText: 'LinkedIn Profile URL',
                prefixIcon: Icon(Icons.work, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.portfolioController,
              decoration: InputDecoration(
                labelText: 'Portfolio Website',
                prefixIcon: Icon(Icons.public, color: AppColors.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(ProfileViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            TextFormField(
              controller: viewModel.bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Bio/Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, viewModel);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppColors.primaryColor),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source, ProfileViewModel viewModel) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        viewModel.setSelectedImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _saveProfile(BuildContext context, ProfileViewModel viewModel) async {
    if (viewModel.nameController.text.isEmpty) {
      _showErrorDialog(context, 'Please enter your name');
      return;
    }

    if (viewModel.emailController.text.isEmpty) {
      _showErrorDialog(context, 'Please enter your email');
      return;
    }

    final success = await viewModel.updateUserProfile();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      _showErrorDialog(context, viewModel.errorMessage ?? 'Failed to update profile');
    }
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Changes?'),
        content: Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }
}