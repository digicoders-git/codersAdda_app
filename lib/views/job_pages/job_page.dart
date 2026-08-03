import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:coders_adda_app/veiw_model/job_viewmodel.dart';
import 'package:coders_adda_app/views/job_pages/single_job_detailed_page.dart';
import 'package:coders_adda_app/views/job_pages/my_applications_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';



class JobsPage extends StatefulWidget {
  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final JobsViewModel viewModel = JobsViewModel();
  late Razorpay _razorpay;
  final _storage = const FlutterSecureStorage();
  List<String> _savedJobIds = [];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadSavedJobIds();
  }

  Future<void> _loadSavedJobIds() async {
    try {
      final savedData = await _storage.read(key: 'saved_job_ids');
      if (savedData != null) {
        setState(() {
          _savedJobIds = List<String>.from(jsonDecode(savedData));
        });
      }
    } catch (e) {
      debugPrint("Error loading saved job ids: $e");
    }
  }

  Future<void> _toggleSaveJob(JobDetail job) async {
    final isSaved = _savedJobIds.contains(job.id);
    
    // Load full saved jobs list
    final savedJobsData = await _storage.read(key: 'saved_jobs_list');
    List<dynamic> savedList = [];
    if (savedJobsData != null) {
      savedList = jsonDecode(savedJobsData);
    }

    if (isSaved) {
      // Remove
      setState(() {
        _savedJobIds.remove(job.id);
      });
      savedList.removeWhere((item) => item['id'] == job.id);
      _showSnackBar('${job.jobTitle} removed from saved list', Colors.grey);
    } else {
      // Add
      setState(() {
        _savedJobIds.add(job.id);
      });
      savedList.add({
        'id': job.id,
        'title': job.jobTitle,
        'company': job.companyName,
        'location': job.location,
        'savedDate': 'Today',
        'salary': job.salaryPackage,
        'experience': job.requiredExperience,
      });
      _showSnackBar('${job.jobTitle} saved successfully', Colors.green);
    }

    await _storage.write(key: 'saved_job_ids', value: jsonEncode(_savedJobIds));
    await _storage.write(key: 'saved_jobs_list', value: jsonEncode(savedList));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (viewModel.purchasingJobId != null) {
      viewModel.verifyJobPayment(
        viewModel.purchasingJobId!,
        response, 
        onSuccess: (msg) => _showSnackBar(msg, Colors.green),
        onError: (msg) => _showSnackBar(msg, Colors.red),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    viewModel.clearPaymentState();
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
      value: viewModel,
      child: Consumer<JobsViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: AppColors.primaryColor,
                  elevation: 0,
                  title: Text(
                    'Jobs Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizer.deviceSp20,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.assignment_ind_outlined, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyApplicationsPage(),
                          ),
                        );
                      },
                      tooltip: 'My Applications',
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => viewModel.fetchJobs(refresh: true),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Search and Filter Section
                    _buildSearchFilterSection(context, viewModel),
                    
                    // Jobs List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.fetchJobs(refresh: true),
                        child: (viewModel.isLoading && viewModel.allJobs.isEmpty)
                            ? const SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: 500, // Sufficient height for centering
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              )
                            : (viewModel.error != null && viewModel.allJobs.isEmpty)
                                ? SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: 500,
                                      child: Center(child: Text(viewModel.error!)),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                                    child: Column(
                                      children: [
                                        ...viewModel.filteredJobs.map<Widget>((JobDetail job) => _buildJobCard(job, context, viewModel)).toList(),
                                        
                                        // No results message
                                        if (viewModel.filteredJobs.isEmpty && !viewModel.isLoading)
                                          Container(
                                            padding: EdgeInsets.all(AppSizer.deviceWidth8),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.search_off,
                                                  size: AppSizer.deviceSp48,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: AppSizer.deviceHeight2),
                                                Text(
                                                  'No jobs found',
                                                  style: TextStyle(
                                                    fontSize: AppSizer.deviceSp16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        
                                        // Pagination Loader
                                        if (viewModel.isLoading && viewModel.allJobs.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.all(AppSizer.deviceHeight2),
                                            child: const Center(child: CircularProgressIndicator()),
                                          ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
              // Full Screen Loader for Payments/Unlocks
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
                            const Text('Processing Transaction...', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSearchFilterSection(BuildContext context, JobsViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => viewModel.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search jobs by title, skills, company...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizer.deviceWidth4,
                  vertical: AppSizer.deviceHeight2,
                ),
                suffixIcon: viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => viewModel.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Filter Row
          Row(
            children: [
              // Experience Filter
              Expanded(
                child: _buildFilterDropdown(
                  value: viewModel.selectedExperience,
                  items: ['All Levels', ...viewModel.availableExperiences],
                  hint: 'Experience',
                  onChanged: (value) => viewModel.setSelectedExperience(value!),
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth2),
              
              // Filter Button
              Container(
                decoration: BoxDecoration(
                  color: viewModel.hasActiveFilters ? AppColors.primaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: viewModel.hasActiveFilters ? Colors.white : Colors.grey,
                  ),
                  onPressed: () => _showAdvancedFilterDialog(context, viewModel),
                ),
              ),
            ],
          ),
          
          // Active Filters Chips
          if (viewModel.hasActiveFilters) ...[
            SizedBox(height: AppSizer.deviceHeight2),
            _buildActiveFiltersChips(viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth2),
      child: DropdownButton<String>(
        value: value.isEmpty ? null : value,
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
        hint: Text(
          hint,
          style: TextStyle(fontSize: AppSizer.deviceSp14, color: Colors.grey),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: AppSizer.deviceSp12),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (newValue) => onChanged(newValue ?? ''),
      ),
    );
  }

  Widget _buildActiveFiltersChips(JobsViewModel viewModel) {
    return Wrap(
      spacing: AppSizer.deviceWidth2,
      runSpacing: AppSizer.deviceHeight1,
      children: [
        if (viewModel.searchQuery.isNotEmpty)
          _buildFilterChip(
            label: 'Search: "${viewModel.searchQuery}"',
            onRemove: () => viewModel.setSearchQuery(''),
          ),
        if (viewModel.selectedExperience.isNotEmpty && viewModel.selectedExperience != 'All Levels')
          _buildFilterChip(
            label: 'Exp: ${viewModel.selectedExperience}',
            onRemove: () => viewModel.setSelectedExperience(''),
          ),
        if (viewModel.selectedSkills.isNotEmpty)
          ...viewModel.selectedSkills.map((skill) => _buildFilterChip(
            label: 'Skill: $skill',
            onRemove: () => viewModel.removeSelectedSkill(skill),
          )).toList(),
        
        // Clear All Button
        if (viewModel.hasActiveFilters)
          InkWell(
            onTap: viewModel.clearAllFilters,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight1,
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: AppSizer.deviceSp12, color: Colors.red),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: AppSizer.deviceSp12),
      ),
      deleteIcon: Icon(Icons.close, size: AppSizer.deviceSp14),
      onDeleted: onRemove,
      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
void _showAdvancedFilterDialog(BuildContext context, JobsViewModel viewModel) {
  final allCategories = viewModel.availableJobCategories;
  final allWorkTypes = viewModel.availableJobTypes;
  final allPriceTypes = ['All', 'free', 'paid'];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets + EdgeInsets.all(20),
          duration: Duration(milliseconds: 100),
          child: MediaQuery.removeViewInsets(
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            context: context,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Row(
                            children: [
                              Icon(Icons.filter_list, color: AppColors.primaryColor),
                              SizedBox(width: AppSizer.deviceWidth2),
                              Text(
                                'Advanced Filters',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizer.deviceHeight4),
                          
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // Work Type Filter
                                  Text(
                                    'Filter by Work Type:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppSizer.deviceSp14,
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight1),
                                  Wrap(
                                    spacing: 8.0,
                                    children: allWorkTypes.map((type) {
                                      final isSelected = viewModel.selectedWorkType == type;
                                      return ChoiceChip(
                                        label: Text(type),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            viewModel.setSelectedWorkType(selected ? type : '');
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight2),

                                  // Price Type Filter
                                  Text(
                                    'Filter by Price Type:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppSizer.deviceSp14,
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight1),
                                  Wrap(
                                    spacing: 8.0,
                                    children: allPriceTypes.map((type) {
                                      final isSelected = viewModel.selectedPriceType == type;
                                      return ChoiceChip(
                                        label: Text(type),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            viewModel.setSelectedPriceType(selected ? type : '');
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Buttons
                          SizedBox(height: AppSizer.deviceHeight4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              TextButton(
                                onPressed: () {
                                  viewModel.clearAllFilters();
                                  Navigator.pop(context);
                                },
                                child: Text('Reset'),
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Apply Filters'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
 

 Widget _buildJobCard(JobDetail job, BuildContext context, JobsViewModel viewModel) {
  final canApply = viewModel.canApplyForJob(job.id);
  
  return Card(
    margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () => _navigateToJobDetails(context, job),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Title and Premium Badge
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ) ,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.jobCategory,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Premium Lock Badge
              if (!canApply)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppSizer.deviceWidth1),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: AppSizer.deviceSp12, color: Colors.white),
                        SizedBox(width: AppSizer.deviceWidth1),
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Key Details Row
          Row(
            children: [
              _buildDetailItem(Icons.location_on, job.location),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.work_outline, job.workType),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.timeline, job.requiredExperience),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Salary and Openings Row
          Row(
            children: [
              _buildDetailItem(Icons.currency_rupee, job.salaryPackage),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.people, '${job.numberOfOpenings} Openings'),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.calendar_today, 'Posted: ${job.createdAt.split('T')[0]}'),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Skills Section
          Text(
            'Required Skills:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizer.deviceSp16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Wrap(
            spacing: AppSizer.deviceWidth2,
            runSpacing: AppSizer.deviceHeight1,
            children: job.requiredSkills.map((skill) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight1,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
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
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Company Details Section (NEW)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizer.deviceSp14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                
                 // Company Name
                _buildHiddenDetailItem(
                  Icons.business,
                  'Company: ${job.locked ? _hideMiddleCharacters(job.companyName) : job.companyName}',
                ),
                SizedBox(height: AppSizer.deviceHeight1),
                
                // Company Email
                if (job.contactEmail != null) ...[
                  _buildHiddenDetailItem(
                    Icons.email,
                    'Email: ${job.locked ? _hideMiddleCharacters(job.contactEmail!) : job.contactEmail!}',
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                ],
                
                // Company Mobile
                if (job.companyMobile != null) ...[
                  _buildHiddenDetailItem(
                    Icons.phone,
                    'Mobile: ${job.locked ? _hideMiddleCharacters(job.companyMobile!) : job.companyMobile!}',
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                ],
                
                // Company Website
                if (job.companyWebsite != null) ...[
                  _buildHiddenDetailItem(
                    Icons.language,
                    'Website: ${job.locked ? _hideMiddleCharacters(job.companyWebsite!.replaceAll('https://', '').replaceAll('http://', '')) : job.companyWebsite!}',
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
           Row(
            children: [
               Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _toggleSaveJob(job);
                  },
                  icon: Icon(_savedJobIds.contains(job.id) ? Icons.bookmark : Icons.bookmark_border, size: AppSizer.deviceSp16),
                  label: Text(
                    _savedJobIds.contains(job.id) ? 'Saved' : 'Save',
                    style: TextStyle(fontSize: AppSizer.deviceSp16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth1),
              // Show button based on priceType and CompanyIsHide
              if (job.priceType == 'free')
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final profileViewModel = context.read<ProfileViewModel>();
                      viewModel.handleJobUnlock(
                        job, 
                        profileViewModel,
                        onSuccess: (msg) {
                          _showSnackBar(msg, Colors.green);
                          _navigateToJobDetails(context, job);
                        },
                        onError: (msg) => _showSnackBar(msg, Colors.red),
                        onPaymentRequired: (orderResponse) => _startPayment(orderResponse),
                      );
                    },
                    icon: Icon(
                      viewModel.purchasingJobId == job.id ? Icons.hourglass_empty : Icons.check_circle_outline,
                      size: AppSizer.deviceSp16,
                    ),
                    label: Text(
                      viewModel.purchasingJobId == job.id ? 'Processing...' : 'Free Enroll',
                      style: TextStyle(fontSize: AppSizer.deviceSp16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )

              else if (!job.locked)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _navigateToJobDetails(context, job),
                    icon: Icon(Icons.visibility, size: AppSizer.deviceSp16),
                    label: Text(
                      'View Details',
                      style: TextStyle(fontSize: AppSizer.deviceSp16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (job.companyIsHide || job.priceType == 'paid')
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _showUnlockDialog(context, job.jobTitle, job, () {
                        final profileViewModel = context.read<ProfileViewModel>();
                        viewModel.handleJobUnlock(
                          job, 
                          profileViewModel,
                          onSuccess: (msg) {
                            _showSnackBar(msg, Colors.green);
                            _navigateToJobDetails(context, job);
                          },
                          onError: (msg) => _showSnackBar(msg, Colors.red),
                          onPaymentRequired: (orderResponse) => _startPayment(orderResponse),
                        );
                      });
                    },
                    icon: Icon(
                      viewModel.purchasingJobId == job.id ? Icons.hourglass_empty : Icons.lock_open,
                      size: AppSizer.deviceSp16,
                    ),
                    label: Text(
                      viewModel.purchasingJobId == job.id ? 'Processing...' : 'Unlock Now',
                      style: TextStyle(fontSize: AppSizer.deviceSp16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
    ),
  );
}

// Helper function to hide middle characters for all sensitive data
String _hideMiddleCharacters(String text) {
  if (text.length <= 2) {
    return text; // Return as is if too short
  }
  
  // For email addresses - hide both username and domain
  if (text.contains('@')) {
    final parts = text.split('@');
    if (parts.length == 2) {
      final username = parts[0];
      final domainParts = parts[1].split('.');
      
      String hiddenUsername;
      if (username.length <= 2) {
        hiddenUsername = username;
      } else {
        hiddenUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
      }
      
      // Hide domain name too (except TLD)
      if (domainParts.length >= 2) {
        final domainName = domainParts[0];
        final tld = domainParts.sublist(1).join('.');
        
        String hiddenDomainName;
        if (domainName.length <= 2) {
          hiddenDomainName = domainName;
        } else {
          hiddenDomainName = '${domainName[0]}${'*' * (domainName.length - 2)}${domainName[domainName.length - 1]}';
        }
        
        return '$hiddenUsername@$hiddenDomainName.$tld';
      }
    }
  }
  
  // For phone numbers
  if (text.contains('+')) {
    if (text.length <= 4) {
      return text;
    }
    return '${text.substring(0, 3)}${'*' * (text.length - 4)}${text.substring(text.length - 1)}';
  }
  
  // For website URLs - remove protocol and hide domain
  if (text.contains('://')) {
    final uri = Uri.tryParse(text);
    if (uri != null) {
      final host = uri.host;
      if (host.contains('.')) {
        final hostParts = host.split('.');
        if (hostParts.length >= 2) {
          final domainName = hostParts[0];
          final tld = hostParts.sublist(1).join('.');
          
          String hiddenDomainName;
          if (domainName.length <= 2) {
            hiddenDomainName = domainName;
          } else {
            hiddenDomainName = '${domainName[0]}${'*' * (domainName.length - 2)}${domainName[domainName.length - 1]}';
          }
          
          return '$hiddenDomainName.$tld';
        }
      }
    }
  }
  
  // For regular text (company name, etc.)
  return '${text[0]}${'*' * (text.length - 2)}${text[text.length - 1]}';
}

// Updated detail item for hidden text
Widget _buildHiddenDetailItem(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        size: AppSizer.deviceSp18,
        color: Colors.grey[600],
      ),
      SizedBox(width: AppSizer.deviceWidth2),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizer.deviceSp16,
            color: Colors.grey[600],
          ),
          SizedBox(width: AppSizer.deviceWidth1),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

 void _showUnlockDialog(BuildContext context, String jobTitle, JobDetail job, VoidCallback onApply) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Unlock Job Details'),
      content: Text('Are you sure you want to unlock the details for $jobTitle?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context); // Dialog close karo
            onApply(); // Job apply logic execute karo
          },
          child: Text('Unlock Now'),
        ),
      ],
    ),
  );
}

void _navigateToJobDetails(BuildContext context, JobDetail job) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => JobDetailsPage(job: job),
    ),
  );
}

  void _showSubscriptionPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          SizedBox(width: AppSizer.deviceWidth2),
          Text('Upgrade to Premium'),
        ],
      ),
      content: Text('You have used all your free job applications. Subscribe to our premium plan to apply for unlimited jobs.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Maybe Later'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _navigateToSubscriptionPage(context);
          },
          child: Text('Upgrade Now'),
        ),
      ],
    ),
  );
}

void _navigateToSubscriptionPage(BuildContext context) {
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (context) => SubscriptionPage())
  );
}

  void _showSaveConfirmation(BuildContext context, String jobTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$jobTitle saved to your list'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      ),
    );
  }
}