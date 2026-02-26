import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/veiw_model/job_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class JobDetailsPage extends StatefulWidget {
  final JobDetail job;

  const JobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Razorpay _razorpay;
  final JobsViewModel _viewModel = JobsViewModel();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_viewModel.purchasingJobId != null) {
      _viewModel.verifyJobPayment(
        _viewModel.purchasingJobId!,
        response, 
        onSuccess: (msg) => _showSnackBar(msg, Colors.green),
        onError: (msg) => _showSnackBar(msg, Colors.red),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _viewModel.clearPaymentState();
    _showSnackBar('Payment Failed: ${response.message}', Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External Wallet: ${response.walletName}', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  void _startPayment(Map<String, dynamic> orderResponse) {
    final profile = context.read<ProfileViewModel>().user;
    var options = {
      'key': orderResponse['key'],
      'amount': orderResponse['amount'],
      'name': 'Coders Adda',
      'order_id': orderResponse['orderId'],
      'description': 'Job Unlock Payment',
      'prefill': {
        'contact': profile?.mobile ?? '',
        'email': profile?.email ?? '',
        'name': profile?.name ?? ''
      },
      'theme': {'color': '#2196F3'}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar('Error launching Razorpay: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<JobsViewModel>(
        builder: (context, viewModel, child) {
          // Find the latest job status from ViewModel if available
          final currentJobInList = viewModel.allJobs.firstWhere(
            (j) => j.id == widget.job.id,
            orElse: () => widget.job,
          );
          
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: CustomScrollView(
                  slivers: [
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderSection(currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight4),
                            _buildQuickStats(currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight4),
                            _buildSectionTitle('Job Description'),
                            SizedBox(height: AppSizer.deviceHeight2),
                            _buildDescription(currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight4),
                            _buildSectionTitle('Skills Required'),
                            SizedBox(height: AppSizer.deviceHeight2),
                            _buildSkills(currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight4),
                            _buildSectionTitle('Job Details'),
                            SizedBox(height: AppSizer.deviceHeight2),
                            _buildJobDetails(currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight4),
                            _buildSectionTitle('About Company'),
                            SizedBox(height: AppSizer.deviceHeight2),
                            _buildCompanyDetails(context, currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight4),
                            _buildSectionTitle('Contact Information'),
                            SizedBox(height: AppSizer.deviceHeight2),
                            _buildContactInfo(context, currentJobInList),
                            SizedBox(height: AppSizer.deviceHeight8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: currentJobInList.locked && !viewModel.isProcessingPayment
                              ? () => _showApplyDialog(context, viewModel, currentJobInList) 
                              : null,
                          icon: Icon(viewModel.purchasingJobId == currentJobInList.id 
                              ? Icons.hourglass_empty 
                              : (currentJobInList.locked ? (currentJobInList.priceType == 'free' ? Icons.check_circle_outline : Icons.lock_open) : Icons.check)),
                          label: Text(
                            viewModel.purchasingJobId == currentJobInList.id 
                                ? 'Processing...' 
                                : (currentJobInList.locked ? (currentJobInList.priceType == 'free' ? 'Free Enroll' : 'Unlock Now') : 'Already Unlocked'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: !currentJobInList.locked ? Colors.grey : (currentJobInList.priceType == 'free' ? Colors.green : AppColors.primaryColor),
                            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Full screen loader overlay
              if (viewModel.isProcessingPayment)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(height: AppSizer.deviceHeight2),
                            const Text('Processing...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(JobDetail job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.jobTitle,
          style: TextStyle(
            fontSize: AppSizer.deviceSp24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          job.companyName,
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

  Widget _buildQuickStats(JobDetail job) {
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
          _buildStatItem('Experience', job.requiredExperience, Icons.timeline),
          _buildStatItem('Job Type', job.workType, Icons.work_outline),
          _buildStatItem('Openings', '${job.numberOfOpenings}', Icons.people),
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

  Widget _buildDescription(JobDetail job) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        job.jobDescription,
        style: TextStyle(
          fontSize: AppSizer.deviceSp14,
          height: 1.5,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSkills(JobDetail job) {
    return Wrap(
      spacing: AppSizer.deviceWidth2,
      runSpacing: AppSizer.deviceHeight2,
      children: job.requiredSkills.map((skill) => Container(
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

  Widget _buildJobDetails(JobDetail job) {
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
          _buildTableRow('Category', job.jobCategory),
          _buildTableRow('Salary', job.salaryPackage),
          _buildTableRow('Experience', job.requiredExperience),
          _buildTableRow('Job Type', job.workType),
          _buildTableRow('Openings', '${job.numberOfOpenings} positions'),
          _buildTableRow('Posted On', job.createdAt.split('T')[0]),
          _buildTableRow('Status', job.jobStatus),
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

  Widget _buildCompanyDetails(BuildContext context, JobDetail job) {
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
            job.companyIsHide ? _hideMiddleCharacters(job.companyName) : job.companyName,
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          if (job.fullAddress != null)
            Text(
              job.fullAddress!,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: Colors.grey[700],
              ),
            ),
          SizedBox(height: AppSizer.deviceHeight2),
          if (job.companyWebsite != null)
            InkWell(
              onTap: () => _launchURL(job.companyWebsite!, context),
              child: Text(
                job.companyIsHide ? _hideMiddleCharacters(job.companyWebsite!.replaceAll('https://', '').replaceAll('http://', '')) : job.companyWebsite!,
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

  Widget _buildContactInfo(BuildContext context, JobDetail job) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (job.contactEmail != null)
            _buildContactItem(Icons.email, job.companyIsHide ? _hideMiddleCharacters(job.contactEmail!) : job.contactEmail!, () => _launchURL('mailto:${job.contactEmail}', context)),
          SizedBox(height: AppSizer.deviceHeight2),
          if (job.companyMobile != null)
            _buildContactItem(Icons.phone, job.companyIsHide ? _hideMiddleCharacters(job.companyMobile!) : job.companyMobile!, () => _launchURL('tel:${job.companyMobile}', context)),
          SizedBox(height: AppSizer.deviceHeight2),
          if (job.companyWebsite != null)
            _buildContactItem(Icons.language, job.companyIsHide ? _hideMiddleCharacters(job.companyWebsite!.replaceAll('https://', '').replaceAll('http://', '')) : job.companyWebsite!, () => _launchURL(job.companyWebsite!, context)),
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

  String _hideMiddleCharacters(String text) {
    if (text.length <= 2) return text;
    if (text.contains('@')) {
      final parts = text.split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domainParts = parts[1].split('.');
        String hiddenUsername = username.length <= 2 ? username : '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
        if (domainParts.length >= 2) {
          final domainName = domainParts[0];
          final tld = domainParts.sublist(1).join('.');
          String hiddenDomainName = domainName.length <= 2 ? domainName : '${domainName[0]}${'*' * (domainName.length - 2)}${domainName[domainName.length - 1]}';
          return '$hiddenUsername@$hiddenDomainName.$tld';
        }
      }
    }
    return '${text[0]}${'*' * (text.length - 2)}${text[text.length - 1]}';
  }

  void _showApplyDialog(BuildContext context, JobsViewModel viewModel, JobDetail job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.priceType == 'free' ? 'Enroll for Job' : 'Unlock Job Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to ${job.priceType == 'free' ? 'enroll for' : 'unlock'} ${job.jobTitle} at ${job.companyName}?'),
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
              final profileViewModel = context.read<ProfileViewModel>();
              viewModel.handleJobUnlock(
                job, 
                profileViewModel,
                onSuccess: (msg) => _showSnackBar(msg, Colors.green),
                onError: (msg) => _showSnackBar(msg, Colors.red),
                onPaymentRequired: (orderResponse) => _startPayment(orderResponse),
              );
            },
            child: Text(job.priceType == 'free' ? 'Enroll Now' : 'Unlock Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }
}