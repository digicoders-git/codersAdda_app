import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/subscription_viewmodel.dart';
import 'package:coders_adda_app/views/subscription_pages/buy_subscription_page.dart';
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
    // Auto-select the Super plan (middle one) by default
    _selectedPlan = viewModel.plans.firstWhere((plan) => plan.name == "Super");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Consumer<SubscriptionViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
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
      padding: EdgeInsets.all(AppSizer.deviceWidth6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3460),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: AppSizer.deviceHeight4),
          
          // App Icon/Logo
          Container(
            width: AppSizer.deviceWidth20,
            height: AppSizer.deviceWidth20,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: AppSizer.deviceSp24,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Main Title
          Text(
            'Unlock Premium Learning',
            style: TextStyle(
              fontSize: AppSizer.deviceSp24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Subtitle
          Text(
            'Access all courses, PDFs, and premium features',
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSizer.deviceHeight3),
          
          // Benefits Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBenefitItem('All Courses', Icons.video_library),
              _buildBenefitItem('PDF Access', Icons.picture_as_pdf),
              _buildBenefitItem('No Ads', Icons.block),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: AppSizer.deviceSp18,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizer.deviceSp13,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansSection(BuildContext context, List<SubscriptionPlan> plans) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Section Title
          Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          Text(
            'Flexible plans for your learning journey',
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: Colors.white70,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight3),
          
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
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primaryColor.withOpacity(0.3) 
                  : Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Stack(
          children: [
            // Selected Badge
            if (isSelected)
              Positioned(
                top: -10,
                right: AppSizer.deviceWidth4,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth4,
                    vertical: AppSizer.deviceHeight0_5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SELECTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizer.deviceSp10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          
            Column(
              children: [
                // Plan Header
                Container(
                  padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryColor 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizer.deviceWidth4),
                      topRight: Radius.circular(AppSizer.deviceWidth4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp18,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: AppSizer.deviceHeight0_5),
                          Text(
                            plan.duration,
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.white70 
                                  : AppColors.onSurfaceVariant,
                              fontSize: AppSizer.deviceSp12,
                            ),
                          ),
                        ],
                      ),
                      
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${plan.price.toInt()}',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp24,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppColors.primaryColor,
                            ),
                          ),
                          if (plan.duration.contains('Year'))
                            Text(
                              '₹${(plan.price / 12).toInt()}/month',
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white70 
                                    : AppColors.onSurfaceVariant,
                                fontSize: AppSizer.deviceSp12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Features List
                Padding(
                  padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  child: Column(
                    children: plan.features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.successColor,
                            size: AppSizer.deviceSp16,
                          ),
                          SizedBox(width: AppSizer.deviceWidth2),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                
                // Select Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlan = plan;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? AppColors.primaryColor 
                          : Colors.transparent,
                      foregroundColor: isSelected 
                          ? Colors.white 
                          : AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                        side: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizer.deviceHeight1_5,
                      ),
                    ),
                    child: Text(
                      isSelected ? 'SELECTED' : 'SELECT PLAN',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          Text(
            'What You Get',
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: AppSizer.deviceWidth2,
            mainAxisSpacing: AppSizer.deviceHeight1,
            children: [
              _buildFeatureItem('All Courses Access', Icons.video_library),
              _buildFeatureItem('Premium PDFs', Icons.picture_as_pdf),
              _buildFeatureItem('Ad-Free Experience', Icons.block),
              _buildFeatureItem('Job Opportunities', Icons.work),
              _buildFeatureItem('Download Content', Icons.download),
              _buildFeatureItem('Priority Support', Icons.support_agent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
      ),
      child: Row(
        children: [
          SizedBox(width: AppSizer.deviceWidth2),
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: AppSizer.deviceSp16,
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp14,
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
        color: Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -2),
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
                  ? AppColors.primaryColor 
                  : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
              ),
              padding: EdgeInsets.symmetric(
                vertical: AppSizer.deviceHeight2,
              ),
              elevation: 5,
              shadowColor: AppColors.primaryColor.withOpacity(0.5),
            ),
            child: Text(
              _selectedPlan != null 
                  ? 'SUBSCRIBE NOW - ₹${_selectedPlan!.price.toInt()}' 
                  : 'SELECT A PLAN',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
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
        builder: (context) => SubscriptionCheckoutPage(plan: plan),
      ),
    );
  }
}