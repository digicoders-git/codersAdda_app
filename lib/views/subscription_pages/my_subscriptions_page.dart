import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MySubscriptionsPage extends StatefulWidget {
  @override
  State<MySubscriptionsPage> createState() => _MySubscriptionsPageState();
}

class _MySubscriptionsPageState extends State<MySubscriptionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('My Subscriptions'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Active Plans'),
            Tab(text: 'Expired Plans'),
          ],
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = viewModel.user;
          if (user == null) {
            return const Center(child: Text('No profile data found.'));
          }

          final now = DateTime.now();
          final activePlans = user.purchaseSubscriptions.where((sub) {
            final status = sub['status'] ?? 'active';
            final endDateStr = sub['endDate'];
            final endDate = endDateStr != null ? DateTime.tryParse(endDateStr) : null;
            return status == 'active' && (endDateStr == null || (endDate != null && endDate.isAfter(now)));
          }).toList();

          final expiredPlans = user.purchaseSubscriptions.where((sub) {
            final status = sub['status'] ?? 'active';
            final endDateStr = sub['endDate'];
            final endDate = endDateStr != null ? DateTime.tryParse(endDateStr) : null;
            return status == 'expired' || status == 'cancelled' || (endDate != null && endDate.isBefore(now));
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPlanList(activePlans, isActive: true),
              _buildPlanList(expiredPlans, isActive: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanList(List<Map<String, dynamic>> plans, {required bool isActive}) {
    if (plans.isEmpty) {
      return Center(
        child: Text(
          isActive ? 'No active plans found.' : 'No expired plans found.',
          style: TextStyle(color: Colors.grey, fontSize: AppSizer.deviceSp16),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final sub = plans[index];
        final subscription = sub['subscription'] ?? {};
        final planType = subscription['planType'] ?? 'Unknown Plan';
        final duration = subscription['duration'] ?? 'N/A';
        final price = subscription['price']?.toString() ?? '0';
        
        final startDate = DateTime.tryParse(sub['startDate'] ?? '');
        final endDate = DateTime.tryParse(sub['endDate'] ?? '');
        
        final DateFormat formatter = DateFormat('dd MMM yyyy');

        return Card(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        planType,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'EXPIRED',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontSize: AppSizer.deviceSp12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizer.deviceHeight1),
                Text(
                  'Duration: $duration',
                  style: TextStyle(fontSize: AppSizer.deviceSp14),
                ),
                Text(
                  'Price Paid: ₹$price',
                  style: TextStyle(fontSize: AppSizer.deviceSp14),
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                Divider(),
                SizedBox(height: AppSizer.deviceHeight1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date', style: TextStyle(fontSize: AppSizer.deviceSp12, color: Colors.grey)),
                        Text(
                          startDate != null ? formatter.format(startDate) : 'N/A',
                          style: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('End Date', style: TextStyle(fontSize: AppSizer.deviceSp12, color: Colors.grey)),
                        Text(
                          endDate != null ? formatter.format(endDate) : 'N/A',
                          style: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold, color: isActive ? Colors.amber[800] : Colors.red),
                        ),
                      ],
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
}
