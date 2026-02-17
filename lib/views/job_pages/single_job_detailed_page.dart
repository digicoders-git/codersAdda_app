import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsPage extends StatelessWidget {
  final JobDetail job;

  const JobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Back Button and Job Image
          SliverAppBar(
            expandedHeight: AppSizer.deviceHeight20,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.8),
                      AppColors.primaryColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Company Logo/Image placeholder
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.work_outline,
                          size: AppSizer.deviceSp80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            
          ),

          // Job Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title and Company
                  _buildHeaderSection(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Quick Stats
                  _buildQuickStats(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Job Description
                  _buildSectionTitle('Job Description'),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildDescription(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Skills Required
                  _buildSectionTitle('Skills Required'),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildSkills(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Job Details
                  _buildSectionTitle('Job Details'),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildJobDetails(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // About Company
                  _buildSectionTitle('About Company'),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildCompanyDetails(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  SizedBox(height: AppSizer.deviceHeight2),
                  _buildContactInfo(),
                  SizedBox(height: AppSizer.deviceHeight8),
                ],
              ),
            ),
          ),
        ],
      ),

      // Apply Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -2),
              blurRadius: 4,
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            // Save Button
            // Expanded(
            //   flex: 1,
            //   child: OutlinedButton.icon(
            //     onPressed: () => _showSaveConfirmation(context),
            //     icon: Icon(Icons.bookmark_border),
            //     label: Text('Save'),
            //     style: OutlinedButton.styleFrom(
            //       padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
            //     ),
            //   ),
            // ),
            // SizedBox(width: AppSizer.deviceWidth3),

            // Apply Button
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () => _showApplyDialog(context),
                icon: Icon(Icons.send),
                label: Text(
                  'Apply Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.title,
          style: TextStyle(
            fontSize: AppSizer.deviceSp24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          job.company,
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        Row(
          children: [
            Icon(Icons.location_on, size: AppSizer.deviceSp16, color: Colors.grey),
            SizedBox(width: AppSizer.deviceWidth1),
            Text(
              job.location,
              style: TextStyle(fontSize: AppSizer.deviceSp14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Experience', job.experience, Icons.timeline),
          _buildStatItem('Job Type', job.jobType, Icons.work_outline),
          _buildStatItem('Openings', '${job.totalOpenings}', Icons.people),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: AppSizer.deviceSp20, color: AppColors.primaryColor),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizer.deviceSp18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        job.description,
        style: TextStyle(
          fontSize: AppSizer.deviceSp14,
          height: 1.5,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSkills() {
    return Wrap(
      spacing: AppSizer.deviceWidth2,
      runSpacing: AppSizer.deviceHeight2,
      children: job.skills.map((skill) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth4,
          vertical: AppSizer.deviceHeight1,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          skill,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildJobDetails() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(2),
        },
        children: [
          _buildTableRow('Position', job.position),
          _buildTableRow('Salary', job.salary),
          _buildTableRow('Experience', job.experience),
          _buildTableRow('Job Type', job.jobType),
          _buildTableRow('Openings', '${job.totalOpenings} positions'),
          _buildTableRow('Posted On', job.addedDate),
          _buildTableRow('Last Date', job.lastDate),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyDetails() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.company,
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          Text(
            job.companyAddress,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          InkWell(
            onTap: () => _launchURL(job.companyWebsite),
            child: Text(
              job.companyWebsite,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: AppColors.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildContactItem(Icons.email, job.companyEmail, () => _launchURL('mailto:${job.companyEmail}')),
          SizedBox(height: AppSizer.deviceHeight2),
          _buildContactItem(Icons.phone, job.companyMobile, () => _launchURL('tel:${job.companyMobile}')),
          SizedBox(height: AppSizer.deviceHeight2),
          _buildContactItem(Icons.language, job.companyWebsite, () => _launchURL(job.companyWebsite)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: AppSizer.deviceSp20, color: AppColors.primaryColor),
          SizedBox(width: AppSizer.deviceWidth3),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: AppSizer.deviceSp14, color: Colors.grey),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply for ${job.title} at ${job.company}?'),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'Make sure your profile is complete before applying.',
              style: TextStyle(fontSize: AppSizer.deviceSp12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _submitApplication(context);
            },
            child: Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  void _submitApplication(BuildContext context) {
    // Handle application submission logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application submitted for ${job.title}'),
        action: SnackBarAction(
          label: 'View Status',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSaveConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${job.title} saved to your list'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      ),
    );
  }

  void _shareJob(BuildContext context) {
    // Implement share functionality
    final String shareText = 'Check out this job: ${job.title} at ${job.company} - ${job.applyLink}';
    // You can use share_plus package for better sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share link copied to clipboard')),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}