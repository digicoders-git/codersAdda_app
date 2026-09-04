import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/job_application_viewmodel.dart';
import 'package:intl/intl.dart';

class MyApplicationsPage extends StatefulWidget {
  @override
  _MyApplicationsPageState createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobApplicationViewModel>(context, listen: false).fetchMyApplications();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied': return Colors.blue;
      case 'Under Review': return AppColors.logoOrange;
      case 'Shortlisted': return AppColors.logoNavy;
      case 'Interview Scheduled': return Colors.deepPurple;
      case 'Selected': return AppColors.logoGreen;
      case 'Rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _confirmWithdrawal(BuildContext context, String applicationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Withdraw Application'),
        content: Text('Are you sure you want to withdraw this application? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final viewModel = Provider.of<JobApplicationViewModel>(context, listen: false);
              final success = await viewModel.withdrawApplication(applicationId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application withdrawn successfully.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to withdraw')));
              }
            },
            child: Text('Withdraw', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B1033)),
      ),
      body: Consumer<JobApplicationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.myApplications.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (viewModel.myApplications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind_outlined, size: 20.w, color: Colors.grey.shade300),
                  SizedBox(height: 2.h),
                  Text('No Applications Found', style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  SizedBox(height: 1.h),
                  Text('Apply for jobs to see them here.', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () => viewModel.fetchMyApplications(),
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: viewModel.myApplications.length,
              itemBuilder: (context, index) {
                final app = viewModel.myApplications[index];
                final job = app['jobId'];
                final status = app['status'] ?? 'Unknown';
                
                return Card(
                  margin: EdgeInsets.only(bottom: 3.h),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                job != null ? (job['jobTitle'] ?? 'Unknown Job') : 'Unknown Job',
                                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 13.sp),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Icon(Icons.business, size: 4.w, color: Colors.grey.shade600),
                            SizedBox(width: 1.5.w),
                            Text(
                              job != null ? (job['companyName'] ?? 'Unknown Company') : 'Unknown Company',
                              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 4.w, color: Colors.grey.shade500),
                            SizedBox(width: 1.5.w),
                            Text(
                              'Applied on: ${app['createdAt'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(app['createdAt'])) : 'N/A'}',
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        if (status == 'Applied') ...[
                          Divider(height: 3.h, color: Colors.grey.shade200),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () => _confirmWithdrawal(context, app['_id']),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              ),
                              child: Text('Withdraw', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
                            ),
                          )
                        ],
                        if (app['HRNotes'] != null && app['HRNotes'].toString().isNotEmpty) ...[
                          SizedBox(height: 1.5.h),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.message, size: 4.w, color: Colors.blue.shade700),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'Message from HR: ${app['HRNotes']}',
                                    style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade900),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                        if (app['interviewDate'] != null) ...[
                          SizedBox(height: 1.5.h),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: AppColors.logoNavy,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.logoNavy),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.event, size: 4.w, color: AppColors.logoNavy),
                                    SizedBox(width: 2.w),
                                    Text('Interview Scheduled', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.logoNavy)),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(app['interviewDate']))}', style: TextStyle(fontSize: 13.sp, color: AppColors.logoNavy)),
                                if (app['interviewTime'] != null) Text('Time: ${app['interviewTime']}', style: TextStyle(fontSize: 13.sp, color: AppColors.logoNavy)),
                                if (app['interviewMode'] != null) Text('Mode: ${app['interviewMode']}', style: TextStyle(fontSize: 13.sp, color: AppColors.logoNavy)),
                              ],
                            ),
                          )
                        ],
                        if (app['statusTimeline'] != null && app['statusTimeline'].length > 0) ...[
                          SizedBox(height: 2.h),
                          Text('Status Timeline', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          SizedBox(height: 1.h),
                          ...List.generate(app['statusTimeline'].length, (tIndex) {
                            final t = app['statusTimeline'][tIndex];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Icon(Icons.circle, size: 3.w, color: AppColors.primaryColor),
                                      if (tIndex != app['statusTimeline'].length - 1)
                                        Container(width: 2, height: 3.h, color: Colors.grey.shade300),
                                    ],
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['status'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                                        if (t['message'] != null) Text(t['message'], style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                                        if (t['updatedAt'] != null) Text(DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(t['updatedAt'])), style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
