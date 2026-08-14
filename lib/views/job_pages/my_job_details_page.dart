import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/job_pages/single_job_detailed_page.dart';
import 'package:coders_adda_app/views/job_pages/job_page.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/job_application_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/my_learning_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class MyJobDetailsPage extends StatefulWidget {
  const MyJobDetailsPage({super.key});

  @override
  State<MyJobDetailsPage> createState() => _MyJobDetailsPageState();
}

class _MyJobDetailsPageState extends State<MyJobDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;



  final _storage = const FlutterSecureStorage();
  List<SavedJob> _savedJobs = [];
  bool _isLoadingSaved = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    try {
      final data = await _storage.read(key: 'saved_jobs_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        setState(() {
          _savedJobs = decoded.map((item) => SavedJob(
            id: item['id'] ?? '',
            title: item['title'] ?? '',
            company: item['company'] ?? '',
            location: item['location'] ?? '',
            savedDate: item['savedDate'] ?? 'Today',
            salary: item['salary'] ?? '',
            experience: item['experience'] ?? '',
          )).toList();
        });
      } else {
        // Fallback demo data
        setState(() {
          _savedJobs = [
            SavedJob(
              id: 'demo_1',
              title: 'Flutter Team Lead',
              company: 'Enterprise Tech',
              location: 'Delhi',
              savedDate: '20 Dec 2023',
              salary: '₹20-25 LPA',
              experience: '5-8 years',
            ),
          ];
        });
      }
    } catch (e) {
      debugPrint('Error loading saved jobs: $e');
    } finally {
      setState(() {
        _isLoadingSaved = false;
      });
    }
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
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
                  Icon(Icons.lock_open, size: AppSizer.deviceSp18),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text('Unlocked'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: AppSizer.deviceSp18),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text('Applied'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark, size: AppSizer.deviceSp18),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text('Saved'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUnlockedJobsTab(),
          _buildAppliedJobsTab(),
          _buildSavedJobsTab(),
        ],
      ),
    );
  }


  
  Widget _buildUnlockedJobsTab() {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        final unlockedJobs = profileVM.user?.purchaseJobs ?? [];
        
        if (unlockedJobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.lock_open,
            title: 'No Unlocked Jobs',
            description: 'You haven\'t unlocked any jobs yet.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          itemCount: unlockedJobs.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSizer.deviceHeight2),
          itemBuilder: (context, index) {
            final job = unlockedJobs[index];
            
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
                                job['jobTitle'] ?? 'Unknown Job',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight1),
                              Text(
                                '${job['companyName'] ?? ''} • ${job['location'] ?? ''}',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: AppSizer.deviceSp14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Wrap(
                      spacing: AppSizer.deviceWidth4,
                      runSpacing: AppSizer.deviceHeight1,
                      children: [
                        _buildJobDetailItem(Icons.currency_rupee, job['salaryPackage']?.toString() ?? ''),
                        _buildJobDetailItem(Icons.work, job['requiredExperience'] ?? ''),
                        _buildJobDetailItem(Icons.location_city, job['workType'] ?? ''),
                        _buildJobDetailItem(Icons.category, job['jobCategory'] ?? ''),
                        _buildJobDetailItem(Icons.people, '${job['numberOfOpenings'] ?? '0'} Openings'),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final detail = JobDetail.fromJson(job).copyWith(hasApplied: false, companyIsHide: false, locked: false);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsPage(job: detail)));
                            },
                            child: Text('View Full Details'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }


  Widget _buildAppliedJobsTab() {
    return Consumer<JobApplicationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        final applications = viewModel.myApplications;
        
        if (applications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.send,
            title: 'No Applications Yet',
            description: 'You haven\'t applied to any jobs yet.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          itemCount: applications.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSizer.deviceHeight2),
          itemBuilder: (context, index) {
            final app = applications[index];
            final job = app['jobId'];
            final statusStr = app['status'] ?? 'Unknown';
            
            ApplicationStatus mappedStatus;
            switch(statusStr) {
              case 'Shortlisted': mappedStatus = ApplicationStatus.shortlisted; break;
              case 'Under Review': mappedStatus = ApplicationStatus.underReview; break;
              case 'Rejected': mappedStatus = ApplicationStatus.rejected; break;
              case 'Selected': mappedStatus = ApplicationStatus.shortlisted; break;
              default: mappedStatus = ApplicationStatus.applied; break;
            }
            
            Color statusColor = _getStatusColor(mappedStatus);
            IconData statusIcon = _getStatusIcon(mappedStatus);
            String statusText = statusStr;

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
                                job != null ? (job['jobTitle'] ?? 'Unknown Job') : 'Unknown Job',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight1),
                              Text(
                                job != null ? '${job['companyName'] ?? ''} • ${job['location'] ?? ''}' : '',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: AppSizer.deviceSp14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer.deviceWidth3,
                            vertical: AppSizer.deviceHeight1,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusColor, size: AppSizer.deviceSp14),
                              SizedBox(width: AppSizer.deviceWidth1),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: AppSizer.deviceSp12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Row(
                      children: [
                        _buildJobDetailItem(Icons.currency_rupee, job != null ? (job['salaryPackage']?.toString() ?? '') : ''),
                        SizedBox(width: AppSizer.deviceWidth4),
                        _buildJobDetailItem(Icons.work, job != null ? (job['requiredExperience'] ?? '') : ''),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (job != null) {
                                final detail = JobDetail.fromJson(job).copyWith(hasApplied: true);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsPage(job: detail)));
                              }
                            },
                            child: Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
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
                      _viewJobDetails(job);
                    },
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      _viewJobDetails(job);
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => JobsPage()));
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

  void _viewJobDetails(dynamic jobData) async {
    String jobId = '';
    String title = 'Job Details';
    String company = '';
    String location = '';
    String salary = '';
    String experience = '';

    if (jobData is AppliedJob) {
      jobId = jobData.id;
      title = jobData.title;
      company = jobData.company;
      location = jobData.location;
      salary = jobData.salary;
    } else if (jobData is SavedJob) {
      jobId = jobData.id;
      title = jobData.title;
      company = jobData.company;
      location = jobData.location;
      salary = jobData.salary;
      experience = jobData.experience;
    } else if (jobData is String) {
      jobId = jobData;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    JobDetail? jobDetail;

    try {
      if (jobId.isNotEmpty && !jobId.startsWith('demo') && jobId.length > 5) {
        final response = await ApiClient().get('${ApiUrls.getJobsV3}/$jobId');
        if (response != null && response['success'] == true && response['data'] != null) {
          jobDetail = JobDetail.fromJson(response['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching job details: $e');
    }

    if (mounted) {
      Navigator.pop(context); // Close loading indicator
    }

    jobDetail ??= JobDetail(
      id: jobId,
      jobTitle: title.isNotEmpty ? title : 'Software Developer',
      jobCategory: 'Development',
      location: location.isNotEmpty ? location : 'Remote',
      salaryPackage: salary.isNotEmpty ? salary : 'Disclosed on Application',
      requiredExperience: experience.isNotEmpty ? experience : '0-2 Years',
      workType: 'Full-Time',
      numberOfOpenings: 1,
      requiredSkills: ['Flutter', 'Dart'],
      jobDescription: 'Job details for $title at $company.\n\nKey Responsibilities:\n- Work with modern mobile technology stack.\n- Design and build responsive Flutter applications.\n- Collaborate with team members to deliver features.',
      companyName: company.isNotEmpty ? company : 'Tech Solutions',
      companyMobile: null,
      companyWebsite: null,
      contactEmail: null,
      fullAddress: location,
      jobStatus: 'Active',
      price: 0,
      priceType: 'free',
      createdAt: '',
      updatedAt: '',
      companyIsHide: false,
      locked: false,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailsPage(job: jobDetail!),
        ),
      );
    }
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

  void _removeFromSaved(String jobId) async {
    setState(() {
      _savedJobs.removeWhere((job) => job.id == jobId);
    });

    final List<Map<String, String>> serializableList = _savedJobs.map((item) => {
      'id': item.id,
      'title': item.title,
      'company': item.company,
      'location': item.location,
      'savedDate': item.savedDate,
      'salary': item.salary,
      'experience': item.experience,
    }).toList();

    await _storage.write(key: 'saved_jobs_list', value: jsonEncode(serializableList));

    final List<String> savedIds = _savedJobs.map((item) => item.id).toList();
    await _storage.write(key: 'saved_job_ids', value: jsonEncode(savedIds));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job removed from saved')),
    );
  }

  void _applyToJob(String jobId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applying to job...')),
    );
  }
}

enum ApplicationStatus {
  applied,
  pending,
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