import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/subscription_viewmodel.dart';
import 'package:coders_adda_app/views/subscription_pages/subscription_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionViewModel viewModel = SubscriptionViewModel();
  SubscriptionPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    if (viewModel.plans.isNotEmpty) {
      _selectedPlan = viewModel.plans.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1033),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Premium Plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<SubscriptionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              );
            }

            if (_selectedPlan == null && viewModel.plans.isNotEmpty) {
              _selectedPlan = viewModel.plans.first;
            }

            return Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header Section
                      _buildHeaderSection(),
                      
                      // Plans Section
                      _buildPlansSection(context, viewModel.plans),
                      
                      // Features Section
                      _buildFeaturesSection(),
                      
                      // Add extra space for the fixed button
                      SizedBox(height: AppSizer.deviceHeight12),
                    ],
                  ),
                ),
                
                // Fixed Bottom Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFixedSubscribeButton(context, viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizer.deviceWidth4,
        vertical: AppSizer.deviceHeight1_5,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(AppSizer.deviceWidth2),
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0033CC),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0033CC).withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: AppSizer.deviceSp22,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight0_5),
          
          // Main Title
          Text(
            'Choose Your Premium Pass',
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0B1033),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSizer.deviceHeight0_5),
          
          // Subtitle
          Text(
            'Unlock all features, courses, eBooks, and boost your career',
            style: TextStyle(
              fontSize: AppSizer.deviceSp12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(BuildContext context, List<SubscriptionPlan> plans) {
    if (plans.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight5),
        child: Center(
          child: Text(
            'No premium plans available right now.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 30, height: 2, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 6, color: Color(0xFF0033CC)),
                const SizedBox(width: 8),
                Text(
                  'Available Memberships',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0B1033),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 6, color: Color(0xFF0033CC)),
                const SizedBox(width: 8),
                Container(width: 30, height: 2, color: const Color(0xFFF59E0B)),
              ],
            ),
          ),
          
          // Plans List
          ...plans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            return _buildPlanCard(context, plan, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, int index) {
    bool isSelected = _selectedPlan?.id == plan.id;
    final isYearly = plan.duration.toLowerCase().contains('year') || plan.duration.toLowerCase().contains('12 month');
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF0033CC), width: 2)
              : Border.all(color: const Color(0xFF0033CC), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Top Right Label (BEST VALUE / POPULAR Badge)
              if (isYearly || index == 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8C00),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      isYearly ? 'BEST VALUE' : 'POPULAR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name and Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0033CC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.star,
                            color: const Color(0xFFFFD700),
                            size: AppSizer.deviceSp15,
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth2_5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.planType,
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp15,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0B1033),
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight0_5),
                              Text(
                                'Validity: ${plan.duration}',
                                style: TextStyle(
                                  color: const Color(0xFF0033CC),
                                  fontSize: AppSizer.deviceSp11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Color(0xFFE5E7EB)),
                    ),
                    
                    // Benefits list
                    ...plan.planBenefits.take(3).map((benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF0033CC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: AppSizer.deviceSp12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    
                    if (plan.planBenefits.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 22),
                        child: Text(
                          '+ ${plan.planBenefits.length - 3} more benefits',
                          style: TextStyle(
                            color: const Color(0xFF0033CC),
                            fontSize: AppSizer.deviceSp11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Color(0xFFE5E7EB)),
                    ),

                    // Price & Select Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${plan.price.toInt()}',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp20,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0033CC),
                              ),
                            ),
                            if (isYearly)
                              Text(
                                '₹${(plan.price / 12).toInt()} / month',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: AppSizer.deviceSp11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        
                        // Select indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isSelected ? 'SELECTED' : 'SELECT',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade600,
                                  fontSize: AppSizer.deviceSp11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle, color: Color(0xFF0033CC), size: 14),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizer.deviceWidth4,
        vertical: AppSizer.deviceHeight2,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 30, height: 2, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 6, color: Color(0xFF0033CC)),
                const SizedBox(width: 8),
                Text(
                  'All Plan Inclusions',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0B1033),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 6, color: Color(0xFF0033CC)),
                const SizedBox(width: 8),
                Container(width: 30, height: 2, color: const Color(0xFFF59E0B)),
              ],
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  'All Premium Courses',
                  'Unlimited access to all premium courses',
                  Icons.school,
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth3),
              Expanded(
                child: _buildFeatureCard(
                  'Verified PDF eBooks',
                  'Download unlimited verified PDFs',
                  Icons.menu_book,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0033CC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: AppSizer.deviceSp20,
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF0B1033),
                    fontSize: AppSizer.deviceSp13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: AppSizer.deviceSp10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedSubscribeButton(BuildContext context, SubscriptionViewModel viewModel) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizer.deviceWidth4,
        vertical: AppSizer.deviceHeight1,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedPlan != null 
                    ? () {
                        _navigateToSubscriptionCheckout(context, _selectedPlan!);
                      }
                    : null,
                icon: Icon(
                  Icons.workspace_premium, 
                  color: _selectedPlan != null ? const Color(0xFFFF8C00) : Colors.grey,
                  size: AppSizer.deviceSp16,
                ),
                label: Text(
                  _selectedPlan != null 
                      ? 'SUBSCRIBE NOW - ₹${_selectedPlan!.price.toInt()}' 
                      : 'SELECT A PASS',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPlan != null 
                      ? const Color(0xFF0033CC) 
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizer.deviceHeight1,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrustIndicator(Icons.verified_user_outlined, 'Secure Payment'),
                _buildTrustIndicator(Icons.refresh, 'Cancel Anytime'),
                _buildTrustIndicator(Icons.headset_mic_outlined, '24/7 Support'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustIndicator(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0033CC)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: AppSizer.deviceSp11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navigateToSubscriptionCheckout(BuildContext context, SubscriptionPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailPage(plan: plan),
      ),
    );
  }
}