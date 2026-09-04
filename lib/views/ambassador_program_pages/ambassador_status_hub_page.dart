import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/wallet_pages/wallets_page.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_rewards_page.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_how_it_works_page.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_faq_dialog.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/join_ambassador_page.dart';

class AmbassadorStatusHubPage extends StatefulWidget {
  const AmbassadorStatusHubPage({super.key});

  @override
  State<AmbassadorStatusHubPage> createState() => _AmbassadorStatusHubPageState();
}

class _AmbassadorStatusHubPageState extends State<AmbassadorStatusHubPage> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _status = 'Pending';
  bool _isAmbassador = false;
  double _walletBalance = 0.0;
  int _referralCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await _apiClient.get(ApiUrls.getAmbassadorStatus);
      if (res != null && res['success'] == true) {
        setState(() {
          _status = res['status']?.toString() ?? 'Pending';
          _isAmbassador = res['isAmbassador'] ?? false;
          _walletBalance = (res['walletBalance'] ?? 0).toDouble();
          _referralCount = res['referralCount'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _formatStatusLabel(String s) {
    if (s.toLowerCase() == 'pending') return 'Application Under Review';
    if (s.toLowerCase() == 'approved') return 'Approved & Active';
    if (s.toLowerCase() == 'rejected') return 'Application Rejected';
    return s;
  }

  Color _getStatusColor(String s) {
    if (s.toLowerCase() == 'approved') return const Color(0xFF16A34A);
    if (s.toLowerCase() == 'rejected') return const Color(0xFFDC2626);
    return const Color(0xFFD97706); // Amber for pending
  }

  Color _getStatusBgColor(String s) {
    if (s.toLowerCase() == 'approved') return const Color(0xFFDCFCE7);
    if (s.toLowerCase() == 'rejected') return const Color(0xFFFEE2E2);
    return const Color(0xFFFEF3C7);
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final user = profileVM.user;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Ambassador';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1033)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF0B1033)),
            onPressed: () => AmbassadorFaqDialog.show(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0052FF)))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight2,
              ),
              child: Column(
                children: [
                  // User Profile Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF0052FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth3_5),

                        // Name & Subtitle & Status Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0B1033),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Campus Ambassador',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(_status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatStatusLabel(_status),
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp11,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(_status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.info_outline_rounded, color: Colors.grey.shade500),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AmbassadorHowItWorksPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight2),

                  // Motivational Quote Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth4,
                      vertical: AppSizer.deviceHeight2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Center(
                      child: Text(
                        '“Great things happen when you help others learn.”',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0033CC),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight2_5),

                  // 4 Stats Cards (2x2)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          icon: Icons.school_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBgColor: const Color(0xFFFEF3C7),
                          title: _status.toUpperCase(),
                          subtitle: 'Under Review',
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),
                      Expanded(
                        child: _buildMiniStat(
                          icon: Icons.emoji_events_rounded,
                          iconColor: const Color(0xFF10B981),
                          iconBgColor: const Color(0xFFECFDF5),
                          title: _isAmbassador ? 'Yes' : 'No',
                          subtitle: 'Is Ambassador',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight1_5),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF0284C7),
                          iconBgColor: const Color(0xFFE0F2FE),
                          title: '₹${_walletBalance.toStringAsFixed(0)}',
                          subtitle: 'Wallet Balance',
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),
                      Expanded(
                        child: _buildMiniStat(
                          icon: Icons.groups_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          iconBgColor: const Color(0xFFF3E8FF),
                          title: '$_referralCount',
                          subtitle: 'Total Referrals',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizer.deviceHeight3),

                  // Menu List
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.groups_rounded,
                          iconColor: const Color(0xFF0052FF),
                          title: 'My Referrals',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => Padding(
                                padding: EdgeInsets.all(AppSizer.deviceWidth5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Referrals',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0B1033),
                                      ),
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight2),
                                    Text(
                                      _isAmbassador
                                          ? 'You have successfully referred $_referralCount friends!'
                                          : 'Your application is currently under review. Once approved, your referral code and real-time friends signup list will appear here.',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp13,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight3),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0052FF),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Got It'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 56, endIndent: 16),

                        _buildMenuItem(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF0284C7),
                          title: 'Wallet & Earnings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WalletsPage()),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 56, endIndent: 16),

                        _buildMenuItem(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Rewards & Benefits',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AmbassadorRewardsPage()),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 56, endIndent: 16),

                        _buildMenuItem(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF0052FF),
                          title: 'FAQ',
                          onTap: () => AmbassadorFaqDialog.show(context),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 56, endIndent: 16),

                        _buildMenuItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Contact Support',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Support Email: support@codersadda.com'),
                                backgroundColor: Color(0xFF0033CC),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight3),

                  // Apply Again Button (Outlined light red/pink)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinAmbassadorPage(isReapplying: true),
                          ),
                        );
                        if (res == true) {
                          _fetchStatus();
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFFEF4444)),
                      label: Text(
                        'Apply Again',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight3),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B1033),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizer.deviceSp11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer.deviceSp14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0B1033),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }
}
