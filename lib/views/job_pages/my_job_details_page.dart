import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class MyJobDetailsPage extends StatefulWidget {
  const MyJobDetailsPage({super.key});

  @override
  State<MyJobDetailsPage> createState() => _MyJobDetailsPageState();
}

class _MyJobDetailsPageState extends State<MyJobDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data for applied jobs
  final List<AppliedJob> _appliedJobs = [
    AppliedJob(
      id: '1',
      title: 'Senior Flutter Developer',
      company: 'TechCorp Inc.',
      location: 'Remote',
      appliedDate: '15 Dec 2023',
      status: ApplicationStatus.underReview,
      salary: '₹12-18 LPA',
    ),
    AppliedJob(
      id: '2',
      title: 'Junior Flutter Developer',
      company: 'StartUp Solutions',
      location: 'Noida',
      appliedDate: '12 Dec 2023',
      status: ApplicationStatus.shortlisted,
      salary: '₹6-8 LPA',
    ),
    AppliedJob(
      id: '3',
      title: 'Android Engineer',
      company: 'MobileFirst',
      location: 'Bangalore',
      appliedDate: '10 Dec 2023',
      status: ApplicationStatus.rejected,
      salary: '₹15-20 LPA',
    ),
  ];

  // Demo data for saved jobs
  final List<SavedJob> _savedJobs = [
    SavedJob(
      id: '1',
      title: 'Flutter Team Lead',
      company: 'Enterprise Tech',
      location: 'Delhi',
      savedDate: '20 Dec 2023',
      salary: '₹20-25 LPA',
      experience: '5-8 years',
    ),
    SavedJob(
      id: '2',
      title: 'iOS Developer',
      company: 'Apple Solutions',
      location: 'Remote',
      savedDate: '18 Dec 2023',
      salary: '₹18-22 LPA',
      experience: '3-6 years',
    ),
    SavedJob(
      id: '3',
      title: 'Full Stack Developer',
      company: 'WebTech Solutions',
      location: 'Lucknow',
      savedDate: '15 Dec 2023',
      salary: '₹10-15 LPA',
      experience: '2-4 years',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Jobs',
          style: TextStyle(
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: AppSizer.deviceSp16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: AppSizer.deviceSp16,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: AppSizer.deviceSp18),
                  SizedBox(width: AppSizer.deviceWidth2),
                  Text('Unlocked Jobs'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark, size: AppSizer.deviceSp18),
                  SizedBox(width: AppSizer.deviceWidth2),
                  Text('Saved Jobs'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Applied Jobs Tab
          _buildAppliedJobsTab(),
          
          // Saved Jobs Tab
          _buildSavedJobsTab(),
        ],
      ),
    );
  }

  Widget _buildAppliedJobsTab() {
    if (_appliedJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send,
        title: 'No Applications Yet',
        description: 'You haven\'t applied to any jobs yet. Start applying to see your applications here.',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          // Statistics Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth1),
            margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     AppColors.primaryColor.withOpacity(0.1),
              //     AppColors.primaryColor.withOpacity(0.05),
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              //borderRadius: BorderRadius.circular(12),
              //border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Applied',
                  _appliedJobs.length.toString(),
                  //Icons.send,
                ),
                _buildStatItem(
                  'Under Review',
                  _appliedJobs.where((job) => job.status == ApplicationStatus.underReview).length.toString(),
                  //Icons.schedule,
                ),
                _buildStatItem(
                  'Shortlisted',
                  _appliedJobs.where((job) => job.status == ApplicationStatus.shortlisted).length.toString(),
                  //Icons.thumb_up,
                ),
              ],
            ),
          ),

          // Applied Jobs List
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _appliedJobs.length,
            separatorBuilder: (context, index) => SizedBox(height: AppSizer.deviceHeight2),
            itemBuilder: (context, index) {
              final job = _appliedJobs[index];
              return _buildAppliedJobCard(job);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedJobsTab() {
    if (_savedJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: 'No Saved Jobs',
        description: 'Save interesting jobs to apply later. They will appear here.',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          // Info Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            margin: EdgeInsets.only(bottom: AppSizer.deviceHeight4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: AppSizer.deviceSp20),
                SizedBox(width: AppSizer.deviceWidth3),
                Expanded(
                  child: Text(
                    'You have ${_savedJobs.length} saved jobs. Apply before they expire!',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: AppSizer.deviceSp14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Saved Jobs List
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _savedJobs.length,
            separatorBuilder: (context, index) => SizedBox(height: AppSizer.deviceHeight2),
            itemBuilder: (context, index) {
              final job = _savedJobs[index];
              return _buildSavedJobCard(job);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedJobCard(AppliedJob job) {
    Color statusColor = _getStatusColor(job.status);
    IconData statusIcon = _getStatusIcon(job.status);
    //String statusText = _getStatusText(job.status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        '${job.company} • ${job.location}',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: AppSizer.deviceSp14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: AppSizer.deviceWidth3,
                //     vertical: AppSizer.deviceHeight1,
                //   ),
                //   decoration: BoxDecoration(
                //     color: statusColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(color: statusColor.withOpacity(0.3)),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(statusIcon, color: statusColor, size: AppSizer.deviceSp14),
                //       SizedBox(width: AppSizer.deviceWidth1),
                //       Text(
                //         statusText,
                //         style: TextStyle(
                //           color: statusColor,
                //           fontSize: AppSizer.deviceSp12,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              children: [
                _buildJobDetailItem(Icons.currency_rupee, job.salary),
                SizedBox(width: AppSizer.deviceWidth4),
                _buildJobDetailItem(Icons.calendar_today, 'Unlocked: ${job.appliedDate}'),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewJobDetails(job.id);
                    },
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                // Expanded(
                //   child: FilledButton(
                //     onPressed: () {
                //       _withdrawApplication(job.id);
                //     },
                //     style: FilledButton.styleFrom(
                //       backgroundColor: Colors.grey,
                //     ),
                //     child: Text('Withdraw'),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedJobCard(SavedJob job) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        '${job.company} • ${job.location}',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: AppSizer.deviceSp14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark, color: AppColors.primaryColor),
                  onPressed: () {
                    _removeFromSaved(job.id);
                  },
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              children: [
                _buildJobDetailItem(Icons.currency_rupee, job.salary),
                SizedBox(width: AppSizer.deviceWidth4),
                _buildJobDetailItem(Icons.work, job.experience),
                SizedBox(width: AppSizer.deviceWidth4),
                _buildJobDetailItem(Icons.calendar_today, 'Saved: ${job.savedDate}'),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewJobDetails(job.id);
                    },
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      _applyToJob(job.id);
                    },
                    child: Text('Apply Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizer.deviceSp14, color: AppColors.onSurfaceVariant),
        SizedBox(width: AppSizer.deviceWidth1),
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        // Container(
        //   padding: EdgeInsets.all(AppSizer.deviceWidth3),
        //   decoration: BoxDecoration(
        //     color: AppColors.primaryColor.withOpacity(0.1),
        //     shape: BoxShape.circle,
        //   ),
        //   //child: Icon(icon, color: AppColors.primaryColor, size: AppSizer.deviceSp20),
        // ),
        // SizedBox(height: AppSizer.deviceHeight1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp13,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String description}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizer.deviceWidth6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSizer.deviceSp40,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight4),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight4),
            FilledButton(
              onPressed: () {
                // Navigate to jobs page
              },
              child: Text('Browse Jobs'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.underReview:
        return Colors.orange;
      case ApplicationStatus.shortlisted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.underReview:
        return Icons.schedule;
      case ApplicationStatus.shortlisted:
        return Icons.thumb_up;
      case ApplicationStatus.rejected:
        return Icons.thumb_down;
      default:
        return Icons.info;
    }
  }

  // String _getStatusText(ApplicationStatus status) {
  //   switch (status) {
  //     case ApplicationStatus.underReview:
  //       return 'Under Review';
  //     case ApplicationStatus.shortlisted:
  //       return 'Shortlisted';
  //     case ApplicationStatus.rejected:
  //       return 'Rejected';
  //     default:
  //       return 'Pending';
  //   }
  // }

  void _viewJobDetails(String jobId) {
    // Navigate to job details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening job details...')),
    );
  }

  void _withdrawApplication(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Withdraw Application'),
        content: Text('Are you sure you want to withdraw your application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Application withdrawn successfully')),
              );
            },
            child: Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _removeFromSaved(String jobId) {
    setState(() {
      _savedJobs.removeWhere((job) => job.id == jobId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Job removed from saved')),
    );
  }

  void _applyToJob(String jobId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applying to job...')),
    );
  }
}

enum ApplicationStatus {
  underReview,
  shortlisted,
  rejected,
}

class AppliedJob {
  final String id;
  final String title;
  final String company;
  final String location;
  final String appliedDate;
  final ApplicationStatus status;
  final String salary;

  AppliedJob({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.appliedDate,
    required this.status,
    required this.salary,
  });
}

class SavedJob {
  final String id;
  final String title;
  final String company;
  final String location;
  final String savedDate;
  final String salary;
  final String experience;

  SavedJob({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.savedDate,
    required this.salary,
    required this.experience,
  });
}