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
import 'package:coders_adda_app/views/navigation_class.dart';



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
      _showSnackBar('${job.jobTitle} saved successfully', AppColors.logoGreen);
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
        onSuccess: (msg) => _showSnackBar(msg, AppColors.logoGreen),
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
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  title: Image.asset(
                    'assets/images/mainLogo.png',
                    height: AppSizer.deviceHeight10,
                    fit: BoxFit.contain,
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1033)),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainNavigation()),
                        );
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.assignment_ind_outlined, color: Color(0xFF0B1033)),
                      tooltip: 'My Applications',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyApplicationsPage(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF0B1033)),
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
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.search_off,
                                                  size: 64, // Reduced from AppSizer.deviceSp48
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: AppSizer.deviceHeight2),
                                                Text(
                                                  'No jobs found',
                                                  style: TextStyle(
                                                    fontSize: 16, // Fixed font size
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
      color: const Color(0xFFF9FAFB), // Very light grey background as per mockup
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              onChanged: (value) => viewModel.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search jobs by title, skills, company...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: AppSizer.deviceSp14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizer.deviceWidth4,
                  vertical: AppSizer.deviceHeight2,
                ),
                suffixIcon: viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
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
              SizedBox(width: AppSizer.deviceWidth3),
              
              // Filter Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: viewModel.hasActiveFilters ? const Color(0xFF0033CC) : Colors.grey.shade300),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    color: const Color(0xFF0033CC),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth3, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hint,
            style: TextStyle(fontSize: AppSizer.deviceSp10, color: Colors.grey.shade600),
          ),
          DropdownButton<String>(
            value: value.isEmpty ? null : value,
            isExpanded: true,
            isDense: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF172554)),
            hint: Text(
              'Select',
              style: TextStyle(fontSize: AppSizer.deviceSp14, color: const Color(0xFF0033CC), fontWeight: FontWeight.w600),
            ),
            items: items.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  style: TextStyle(fontSize: AppSizer.deviceSp14, color: const Color(0xFF0033CC), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newValue) => onChanged(newValue ?? ''),
          ),
        ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(AppSizer.deviceWidth4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.filter_list, color: const Color(0xFF172554)),
                                  SizedBox(width: AppSizer.deviceWidth2),
                                  Text(
                                    'Advanced Filters',
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF172554),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => Navigator.pop(context),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizer.deviceHeight3),
                          
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // Location Filter
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSizer.deviceSp13,
                                      color: const Color(0xFF172554),
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight1),
                                  Autocomplete<String>(
                                    optionsBuilder: (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      final locations = ['Noida', 'Gurugram', 'Delhi', 'Bengaluru', 'Pune', 'Hyderabad', 'Mumbai', 'Chennai', 'Remote'];
                                      return locations.where((String option) {
                                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                      });
                                    },
                                    onSelected: (String selection) {
                                      setState(() {
                                        viewModel.setSelectedLocation(selection);
                                      });
                                    },
                                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText: viewModel.selectedLocation.isEmpty ? 'Search Location' : viewModel.selectedLocation,
                                          hintStyle: TextStyle(color: Colors.grey.shade500),
                                          prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight2_5),

                                  // Skills Filter
                                  Text(
                                    'Skill',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSizer.deviceSp13,
                                      color: const Color(0xFF172554),
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight1),
                                  Autocomplete<String>(
                                    optionsBuilder: (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      final skills = ['Flutter', 'Dart', 'React', 'Node.js', 'Python', 'Java', 'Android', 'iOS', 'UI/UX', 'Figma', 'C++', 'JavaScript', 'SQL'];
                                      return skills.where((String option) {
                                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                      });
                                    },
                                    onSelected: (String selection) {
                                      setState(() {
                                        viewModel.addSelectedSkill(selection);
                                      });
                                    },
                                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText: 'Search Skills',
                                          hintStyle: TextStyle(color: Colors.grey.shade500),
                                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        ),
                                      );
                                    },
                                  ),
                                  if (viewModel.selectedSkills.isNotEmpty) ...[
                                    SizedBox(height: AppSizer.deviceHeight1),
                                    Wrap(
                                      spacing: 8.0,
                                      children: viewModel.selectedSkills.map((skill) {
                                        return Chip(
                                          label: Text(skill),
                                          onDeleted: () {
                                            setState(() {
                                              viewModel.removeSelectedSkill(skill);
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  SizedBox(height: AppSizer.deviceHeight2_5),

                                  // Work Type Filter
                                  Text(
                                    'Filter by Work Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSizer.deviceSp13,
                                      color: const Color(0xFF172554),
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight1),
                                  Row(
                                    children: [
                                      _buildCustomFilterButton('Work From Office', Icons.business, viewModel.selectedWorkType == 'Work From Office', () {
                                        setState(() { viewModel.setSelectedWorkType('Work From Office'); });
                                      }),
                                      SizedBox(width: AppSizer.deviceWidth2),
                                      _buildCustomFilterButton('Work From Home', Icons.home_outlined, viewModel.selectedWorkType == 'Work From Home', () {
                                        setState(() { viewModel.setSelectedWorkType('Work From Home'); });
                                      }),
                                      SizedBox(width: AppSizer.deviceWidth2),
                                      _buildCustomFilterButton('Hybrid', Icons.share, viewModel.selectedWorkType == 'Hybrid', () {
                                        setState(() { viewModel.setSelectedWorkType('Hybrid'); });
                                      }),
                                    ],
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight2_5),

                                  // Price Type Filter
                                  Text(
                                    'Filter by Price Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSizer.deviceSp13,
                                      color: const Color(0xFF172554),
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight1),
                                  Row(
                                    children: [
                                      _buildCustomFilterButton('All', Icons.apps, viewModel.selectedPriceType == 'All', () {
                                        setState(() { viewModel.setSelectedPriceType('All'); });
                                      }),
                                      SizedBox(width: AppSizer.deviceWidth2),
                                      _buildCustomFilterButton('Free', Icons.local_offer_outlined, viewModel.selectedPriceType == 'free', () {
                                        setState(() { viewModel.setSelectedPriceType('free'); });
                                      }),
                                      SizedBox(width: AppSizer.deviceWidth2),
                                      _buildCustomFilterButton('Paid', Icons.credit_card, viewModel.selectedPriceType == 'paid', () {
                                        setState(() { viewModel.setSelectedPriceType('paid'); });
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Buttons
                          SizedBox(height: AppSizer.deviceHeight3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Text('Cancel', style: TextStyle(color: const Color(0xFF172554), fontWeight: FontWeight.bold)),
                              ),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      viewModel.clearAllFilters();
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF0033CC)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    child: Text('Reset', style: TextStyle(color: const Color(0xFF0033CC), fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: AppSizer.deviceWidth2),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0033CC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
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

  Widget _buildCustomFilterButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0033CC) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF64748B), size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF172554),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 

 Widget _buildJobCard(JobDetail job, BuildContext context, JobsViewModel viewModel) {
  final canApply = viewModel.canApplyForJob(job.id);
  
  return Card(
    margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2_5),
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.05),
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: InkWell(
      onTap: () => _navigateToJobDetails(context, job),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Title and Category Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.jobTitle,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0033CC),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.jobCategory,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0033CC),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizer.deviceHeight2),
            
            // Key Details Rows
            Wrap(
              spacing: AppSizer.deviceWidth4,
              runSpacing: AppSizer.deviceHeight1,
              children: [
                _buildMockupDetailItem(Icons.location_on, job.location),
                _buildMockupDetailItem(Icons.business_center, job.workType),
                _buildMockupDetailItem(Icons.trending_up, job.requiredExperience),
                _buildMockupDetailItem(Icons.currency_rupee, job.salaryPackage),
                _buildMockupDetailItem(Icons.people, '${job.numberOfOpenings} Openings'),
                _buildMockupDetailItem(Icons.calendar_today, 'Posted: ${job.createdAt.split('T')[0]}'),
              ],
            ),
            
            SizedBox(height: AppSizer.deviceHeight2_5),
            
            // Skills Section
            Text(
              'Required Skills:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizer.deviceSp14,
                color: const Color(0xFF172554),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1_5),
            Wrap(
              spacing: AppSizer.deviceWidth2,
              runSpacing: AppSizer.deviceHeight1,
              children: job.requiredSkills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0033CC),
                  ),
                ),
              )).toList(),
            ),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            // Company Details Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0033CC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: AppSizer.deviceWidth3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizer.deviceSp14,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),
                        Text(
                          'Company: ${job.locked ? _hideMiddleCharacters(job.companyName) : job.companyName}',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _toggleSaveJob(job);
                    },
                    icon: Icon(
                      _savedJobIds.contains(job.id) ? Icons.bookmark : Icons.bookmark_border, 
                      size: 18,
                      color: const Color(0xFF0033CC),
                    ),
                    label: Text(
                      _savedJobIds.contains(job.id) ? 'Saved' : 'Save',
                      style: TextStyle(fontSize: AppSizer.deviceSp14, color: const Color(0xFF0033CC), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                      side: const BorderSide(color: Color(0xFF0033CC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),
                
                // Show button based on priceType and CompanyIsHide
                if (job.priceType == 'free')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final profileViewModel = context.read<ProfileViewModel>();
                        viewModel.handleJobUnlock(
                          job, 
                          profileViewModel,
                          onSuccess: (msg) {
                            _showSnackBar(msg, AppColors.logoGreen);
                            _navigateToJobDetails(context, job);
                          },
                          onError: (msg) => _showSnackBar(msg, Colors.red),
                          onPaymentRequired: (orderResponse) => _startPayment(orderResponse),
                        );
                      },
                      icon: Icon(
                        viewModel.purchasingJobId == job.id ? Icons.hourglass_empty : Icons.check_circle_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        viewModel.purchasingJobId == job.id ? 'Processing...' : 'Free Enroll',
                        style: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else if (!job.locked)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToJobDetails(context, job),
                      icon: const Icon(Icons.visibility, size: 18, color: Colors.white),
                      label: Text(
                        'View Details',
                        style: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0033CC),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else if (job.companyIsHide || job.priceType == 'paid')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showUnlockDialog(context, job.jobTitle, job, () {
                          final profileViewModel = context.read<ProfileViewModel>();
                          viewModel.handleJobUnlock(
                            job, 
                            profileViewModel,
                            onSuccess: (msg) {
                              _showSnackBar(msg, AppColors.logoGreen);
                              _navigateToJobDetails(context, job);
                            },
                            onError: (msg) => _showSnackBar(msg, Colors.red),
                            onPaymentRequired: (orderResponse) => _startPayment(orderResponse),
                          );
                        });
                      },
                      icon: Icon(
                        viewModel.purchasingJobId == job.id ? Icons.hourglass_empty : Icons.lock_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        viewModel.purchasingJobId == job.id ? 'Processing...' : 'Unlock Now',
                        style: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0033CC),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                        elevation: 0,
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

Widget _buildMockupDetailItem(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Colors.grey.shade600),
      SizedBox(width: AppSizer.deviceWidth1),
      Text(
        text,
        style: TextStyle(
          fontSize: AppSizer.deviceSp12,
          color: const Color(0xFF172554),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
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
          Icon(Icons.star, color: AppColors.logoOrange),
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