import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/job_pages/job_application_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/veiw_model/job_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/services/course_service.dart';

class JobDetailsPage extends StatefulWidget {
  final JobDetail job;

  const JobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Razorpay _razorpay;
  final JobsViewModel _viewModel = JobsViewModel();
  final TextEditingController _couponController = TextEditingController();
  final CourseService _courseService = CourseService();
  bool _isValidatingCoupon = false;
  String? _couponErrorMessage;
  double? _discountAmount;
  double? _finalAmount;
  bool _isCouponApplied = false;
  late bool _hasApplied;
  
  List<Map<String, dynamic>> _activeCoupons = [];
  bool _isLoadingCoupons = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveCoupons();
    _hasApplied = widget.job.hasApplied;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchActiveCoupons() async {
    try {
      final coupons = await _courseService.getActiveCoupons();
      if (mounted) {
        setState(() {
          _activeCoupons = coupons;
          _isLoadingCoupons = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCoupons = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_viewModel.purchasingJobId != null) {
      _viewModel.verifyJobPayment(
        _viewModel.purchasingJobId!,
        response, 
        onSuccess: (msg) => _showSnackBar(msg, AppColors.logoGreen),
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
                            color: AppColors.primaryColor,
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
                          onPressed: _hasApplied ? null : (viewModel.isProcessingPayment ? null : () async {
                            if (currentJobInList.locked) {
                              _showApplyDialog(context, viewModel, currentJobInList);
                            } else {
                              final applied = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobApplicationForm(
                                    jobId: currentJobInList.id,
                                    jobTitle: currentJobInList.jobTitle,
                                    companyName: currentJobInList.companyName,
                                  ),
                                ),
                              );
                              if (applied == true) {
                                setState(() {
                                  _hasApplied = true;
                                });
                              }
                            }
                          }),
                          icon: Icon(_hasApplied ? Icons.check_circle : (viewModel.purchasingJobId == currentJobInList.id 
                              ? Icons.hourglass_empty 
                              : (currentJobInList.locked ? (currentJobInList.priceType == 'free' ? Icons.check_circle_outline : Icons.lock_open) : Icons.send))),
                          label: Text(
                            _hasApplied ? 'Applied' : (viewModel.purchasingJobId == currentJobInList.id 
                                ? 'Processing...' 
                                : (currentJobInList.locked ? (currentJobInList.priceType == 'free' ? 'Free Enroll' : 'Unlock Now') : 'Apply Now')),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _hasApplied ? Colors.grey : (!currentJobInList.locked ? AppColors.primaryColor : (currentJobInList.priceType == 'free' ? AppColors.logoGreen : AppColors.primaryColor)),
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
          Row(
            children: [
              Icon(Icons.business, color: Colors.grey[600], size: AppSizer.deviceSp20),
              SizedBox(width: AppSizer.deviceWidth2),
              Expanded(
                child: Text(
                  job.locked ? _hideMiddleCharacters(job.companyName) : job.companyName,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          if (job.fullAddress != null || job.locked) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: AppSizer.deviceSp18),
                SizedBox(width: AppSizer.deviceWidth2),
                Expanded(
                  child: Text(
                    job.locked ? '************************' : job.fullAddress!,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
          ],
          if (job.companyWebsite != null || job.locked) ...[
            InkWell(
              onTap: job.locked ? null : () => _launchURL(job.companyWebsite!, context),
              child: Row(
                children: [
                  Icon(Icons.language, color: job.locked ? Colors.grey[600] : AppColors.primaryColor, size: AppSizer.deviceSp18),
                  SizedBox(width: AppSizer.deviceWidth2),
                  Expanded(
                    child: Text(
                      job.locked ? 'w***************' : job.companyWebsite!,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        color: job.locked ? Colors.grey[700] : AppColors.primaryColor,
                        decoration: job.locked ? TextDecoration.none : TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          if (job.contactEmail != null || job.locked)
            _buildContactItem(Icons.email, job.locked ? 'h********@****.com' : job.contactEmail!, job.locked ? null : () => _launchURL('mailto:${job.contactEmail}', context)),
          SizedBox(height: AppSizer.deviceHeight2),
          if (job.companyMobile != null || job.locked)
            _buildContactItem(Icons.phone, job.locked ? '+91 98*******' : job.companyMobile!, job.locked ? null : () => _launchURL('tel:${job.companyMobile}', context)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: AppSizer.deviceSp20, color: onTap == null ? Colors.grey[600] : AppColors.primaryColor),
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
    _couponController.clear();
    _couponErrorMessage = null;
    _isCouponApplied = false;
    _discountAmount = null;
    _finalAmount = null;

    final profileViewModel = context.read<ProfileViewModel>();
    final freeUnlocksUsed = profileViewModel.user?.freeJobUnlocksUsed ?? 0;
    final totalFreeUnlocks = viewModel.userTotalFreeJobsAllowed;
    final freeUnlocksLeft = totalFreeUnlocks - freeUnlocksUsed;
    final hasSubscription = totalFreeUnlocks > 0;
    final canUnlockFree = job.priceType == 'free' || (hasSubscription && freeUnlocksLeft > 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  canUnlockFree ? Icons.lock_open : Icons.payment,
                  color: canUnlockFree ? AppColors.logoGreen : AppColors.primaryColor,
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                Text(job.priceType == 'free' ? 'Enroll for Job' : 'Unlock Job Details'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${job.jobTitle} at ${job.companyName}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp14)),
                SizedBox(height: AppSizer.deviceHeight2),

                // Subscription / free unlock status
                if (job.priceType != 'free') ...[
                  if (hasSubscription) ...[
                    Container(
                      padding: EdgeInsets.all(AppSizer.deviceWidth3),
                      decoration: BoxDecoration(
                        color: freeUnlocksLeft > 0 ? AppColors.logoGreen : AppColors.logoOrange,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: freeUnlocksLeft > 0 ? AppColors.logoGreen : AppColors.logoOrange),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            freeUnlocksLeft > 0 ? Icons.verified : Icons.warning_amber_rounded,
                            color: freeUnlocksLeft > 0 ? AppColors.logoGreen : AppColors.logoOrange,
                            size: 20,
                          ),
                          SizedBox(width: AppSizer.deviceWidth2),
                          Expanded(
                            child: freeUnlocksLeft > 0
                              ? Text('✅ You have $freeUnlocksLeft free unlock(s) left from your subscription!\nThis job will be unlocked for FREE.',
                                  style: TextStyle(color: AppColors.logoGreen, fontSize: AppSizer.deviceSp13))
                              : Text('⚠️ Your free unlocks ($totalFreeUnlocks) are used up.\nPayment required to unlock.',
                                  style: TextStyle(color: AppColors.logoOrange, fontSize: AppSizer.deviceSp13)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(AppSizer.deviceWidth3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          SizedBox(width: AppSizer.deviceWidth2),
                          Expanded(
                            child: Text('💡 No active subscription. Buy a plan to get free job unlocks!',
                              style: TextStyle(color: Colors.blue.shade800, fontSize: AppSizer.deviceSp13)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight2),
                  ],

                  // Price & Coupon (only shown when payment is needed)
                  if (!canUnlockFree) ...[
                    if (job.price != null) ...[
                      Text('Price: ₹${job.price}', style: TextStyle(fontWeight: FontWeight.w500)),
                      if (_isCouponApplied) ...[
                        Text('Discount: -₹$_discountAmount', style: TextStyle(color: AppColors.logoGreen, fontWeight: FontWeight.bold)),
                        Text('Total: ₹$_finalAmount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp16)),
                      ],
                      SizedBox(height: AppSizer.deviceHeight2),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Coupon Code (Optional)',
                              hintText: 'Enter code',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.confirmation_number_outlined),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isValidatingCoupon ? null : () async {
                            final code = _couponController.text.trim();
                            if (code.isEmpty) return;
                            setDialogState(() { _isValidatingCoupon = true; _couponErrorMessage = null; });
                            try {
                              double amount = job.price?.toDouble() ?? 0;
                              final res = await _courseService.validateCoupon(code, amount);
                              if (res['success'] == true) {
                                setDialogState(() {
                                  _isCouponApplied = true;
                                  _discountAmount = (res['discountAmount'] as num).toDouble();
                                  _finalAmount = (res['finalAmount'] as num).toDouble();
                                });
                              } else {
                                setDialogState(() {
                                  _couponErrorMessage = res['message'] ?? 'Invalid coupon';
                                  _isCouponApplied = false;
                                });
                              }
                            } catch (e) {
                              setDialogState(() {
                                _couponErrorMessage = e.toString().replaceAll('Exception:', '').replaceAll('Error:', '').trim();
                                _isCouponApplied = false;
                              });
                            } finally {
                              setDialogState(() { _isValidatingCoupon = false; });
                            }
                          },
                          child: _isValidatingCoupon
                            ? SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Apply'),
                        ),
                      ],
                    ),
                    if (_couponErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_couponErrorMessage!, style: TextStyle(color: Colors.red, fontSize: AppSizer.deviceSp12)),
                      ),
                    if (!_isCouponApplied && _isLoadingCoupons)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      )
                    else if (!_isCouponApplied && _activeCoupons.isNotEmpty) ...[
                      SizedBox(height: AppSizer.deviceHeight2),
                      Text(
                        'Available Coupons:',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _activeCoupons.length,
                          separatorBuilder: (context, index) => SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final coupon = _activeCoupons[index];
                            return GestureDetector(
                              onTap: () async {
                                _couponController.text = coupon['code'];
                                final code = _couponController.text.trim();
                                if (code.isEmpty) return;
                                setDialogState(() { _isValidatingCoupon = true; _couponErrorMessage = null; });
                                try {
                                  double amount = job.price?.toDouble() ?? 0;
                                  final res = await _courseService.validateCoupon(code, amount);
                                  if (res['success'] == true) {
                                    setDialogState(() {
                                      _isCouponApplied = true;
                                      _discountAmount = (res['discountAmount'] as num).toDouble();
                                      _finalAmount = (res['finalAmount'] as num).toDouble();
                                    });
                                  } else {
                                    setDialogState(() {
                                      _couponErrorMessage = res['message'] ?? 'Invalid coupon';
                                      _isCouponApplied = false;
                                    });
                                  }
                                } catch (e) {
                                  setDialogState(() {
                                    _couponErrorMessage = e.toString().replaceAll('Exception:', '').replaceAll('Error:', '').trim();
                                    _isCouponApplied = false;
                                  });
                                } finally {
                                  setDialogState(() { _isValidatingCoupon = false; });
                                }
                              },
                              child: Container(
                                width: 160,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue.withOpacity(0.05),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      coupon['code'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: AppSizer.deviceSp13,
                                      ),
                                    ),
                                    if (coupon['discountPercent'] != null)
                                      Text(
                                        '${coupon['discountPercent']}% OFF',
                                        style: TextStyle(
                                          color: AppColors.logoGreen,
                                          fontSize: AppSizer.deviceSp11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (_isCouponApplied)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('🎉 Coupon Applied!', style: TextStyle(color: AppColors.logoGreen, fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp12)),
                      ),
                  ],
                ] else ...[
                  Text('This is a free job. Enroll now to view full details.'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: _isValidatingCoupon ? null : () async {
                  final coupon = _couponController.text.trim();
                  Navigator.pop(context);
                  
                  if (canUnlockFree) {
                    // Navigate directly to Application form, limit is deducted on submit!
                    final applied = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobApplicationForm(
                          jobId: job.id,
                          jobTitle: job.jobTitle,
                          companyName: job.companyName,
                        ),
                      ),
                    );
                    if (applied == true) {
                      setState(() {
                        _hasApplied = true;
                      });
                    }
                  } else {
                    // Need payment via Razorpay to unlock
                    viewModel.handleJobUnlock(
                      job,
                      profileViewModel,
                      couponCode: _isCouponApplied ? coupon : null,
                      onSuccess: (msg) async {
                        _showSnackBar(msg, AppColors.logoGreen);
                        // Navigate to Application form after payment success
                        final applied = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobApplicationForm(
                              jobId: job.id,
                              jobTitle: job.jobTitle,
                              companyName: job.companyName,
                            ),
                          ),
                        );
                        if (applied == true) {
                          setState(() {
                            _hasApplied = true;
                          });
                        }
                      },
                      onError: (msg) => _showSnackBar(msg, Colors.red),
                      onPaymentRequired: (orderResponse) => _startPayment(orderResponse),
                    );
                  }
                },
                icon: Icon(canUnlockFree ? Icons.lock_open : Icons.payment, size: 18),
                label: Text(
                  job.priceType == 'free'
                    ? 'Enroll Now'
                    : canUnlockFree
                      ? 'Apply Free'
                      : 'Pay & Apply'
                ),
              ),
            ],
          );
        }
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