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
        backgroundColor: const Color(0xFF0F0C24),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Premium Plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizer.deviceSp20,
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
                      SizedBox(height: AppSizer.deviceHeight15),
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
        horizontal: AppSizer.deviceWidth6,
        vertical: AppSizer.deviceHeight2,
      ),
      child: Column(
        children: [
          // App Icon/Logo (Premium Crown with Glow)
          Container(
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(
              Icons.workspace_premium,
              color: const Color(0xFF0F0C24),
              size: AppSizer.deviceSp32,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2.toDouble()),
          
          // Main Title
          Text(
            'Choose Your Premium Pass',
            style: TextStyle(
              fontSize: AppSizer.deviceSp22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSizer.deviceHeight1.toDouble()),
          
          // Subtitle
          Text(
            'Unlock all features, courses, eBooks, and boost your career',
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: Colors.white.withOpacity(0.6),
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
        child: const Center(
          child: Text(
            'No premium plans available right now.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSizer.deviceWidth1,
              bottom: AppSizer.deviceHeight2,
            ),
            child: Text(
              'Available Memberships',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          
          // Plans List
          ...plans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            return _buildHotstarPlanCard(context, plan, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHotstarPlanCard(BuildContext context, SubscriptionPlan plan, int index) {
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
          color: isSelected ? const Color(0xFF1E1A3D) : const Color(0xFF15122E),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFD700), width: 2)
              : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Premium Background Glow
              if (isSelected)
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withOpacity(0.08),
                    ),
                  ),
                ),
              
              // Top Right Label (Popular / Best Value Badge)
              if (isYearly || index == 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF2E2A5D),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      isYearly ? 'BEST VALUE' : 'POPULAR',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0F0C24) : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
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
                        Icon(
                          Icons.workspace_premium,
                          color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                          size: AppSizer.deviceSp20,
                        ),
                        SizedBox(width: AppSizer.deviceWidth2),
                        Text(
                          plan.planType,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1_5),
                    
                    // Duration & Description
                    Text(
                      'Validity: ${plan.duration}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppSizer.deviceSp13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.white10),
                    ),
                    
                    // Benefits list
                    ...plan.planBenefits.take(3).map((benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00FFCC),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: AppSizer.deviceSp12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    
                    if (plan.planBenefits.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 22),
                        child: Text(
                          '+ ${plan.planBenefits.length - 3} more benefits',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: AppSizer.deviceSp11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 12),

                    // Price & Select Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${plan.price.toInt()}',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp24,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                            if (isYearly)
                              Text(
                                '₹${(plan.price / 12).toInt()}/month',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: AppSizer.deviceSp11,
                                ),
                              ),
                          ],
                        ),
                        
                        // Select indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            isSelected ? 'SELECTED' : 'SELECT',
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0F0C24) : Colors.white70,
                              fontSize: AppSizer.deviceSp12,
                              fontWeight: FontWeight.bold,
                            ),
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
          Text(
            'All Plan Inclusions',
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: AppSizer.deviceWidth3,
            mainAxisSpacing: AppSizer.deviceHeight1_5,
            children: [
              _buildFeatureItem('All Premium Courses', Icons.school),
              _buildFeatureItem('Verified PDF eBooks', Icons.menu_book),
              _buildFeatureItem('Ad-Free Learning', Icons.verified_user),
              _buildFeatureItem('Job Referrals', Icons.work),
              _buildFeatureItem('Offline Download', Icons.cloud_download),
              _buildFeatureItem('1-on-1 Support', Icons.support_agent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: AppSizer.deviceSp14,
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: AppSizer.deviceSp12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedSubscribeButton(BuildContext context, SubscriptionViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0C24),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedPlan != null 
                ? () {
                    _navigateToSubscriptionCheckout(context, _selectedPlan!);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedPlan != null 
                  ? const Color(0xFFFFD700) 
                  : Colors.grey.shade800,
              foregroundColor: const Color(0xFF0F0C24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.symmetric(
                vertical: AppSizer.deviceHeight2,
              ),
              elevation: 4,
              shadowColor: const Color(0xFFFFD700).withOpacity(0.4),
            ),
            child: Text(
              _selectedPlan != null 
                  ? 'SUBSCRIBE NOW - ₹${_selectedPlan!.price.toInt()}' 
                  : 'SELECT A PASS',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
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