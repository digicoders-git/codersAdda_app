import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_faq_dialog.dart';

class AmbassadorDashboardPage extends StatefulWidget {
  final String? referralCode;
  final double? initialBalance;
  final int? initialReferrals;

  const AmbassadorDashboardPage({
    super.key,
    this.referralCode,
    this.initialBalance,
    this.initialReferrals,
  });

  @override
  State<AmbassadorDashboardPage> createState() => _AmbassadorDashboardPageState();
}

class _AmbassadorDashboardPageState extends State<AmbassadorDashboardPage> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _code = "";
  double _walletBalance = 0.0;
  int _referralCount = 0;
  String _status = "Approved";

  @override
  void initState() {
    super.initState();
    _code = widget.referralCode ?? "";
    _walletBalance = widget.initialBalance ?? 0.0;
    _referralCount = widget.initialReferrals ?? 0;
    _fetchLatestData();
  }

  Future<void> _fetchLatestData() async {
    try {
      final res = await _apiClient.get(ApiUrls.getAmbassadorStatus);
      if (res != null && res['success'] == true) {
        final refCode = res['referralCode']?.toString() ?? "";
        setState(() {
          _code = (refCode.toLowerCase() == 'none' || refCode.toLowerCase() == 'null' || refCode.isEmpty)
              ? (_code.isNotEmpty ? _code : "CA12345")
              : refCode;
          _walletBalance = (res['walletBalance'] ?? 0).toDouble();
          _referralCount = res['referralCount'] ?? 0;
          _status = res['status']?.toString() ?? "Approved";
          _isLoading = false;
        });
      } else {
        setState(() {
          if (_code.isEmpty) _code = "CA12345";
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        if (_code.isEmpty) _code = "CA12345";
        _isLoading = false;
      });
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _code)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Referral code "$_code" copied to clipboard!'),
          backgroundColor: const Color(0xFF0033CC),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _shareCode() {
    Share.share(
      'Hey! Use my CodersAdda referral code: $_code to get discounts and rewards when learning in-demand programming courses. Download now: https://codersadda.com',
      subject: 'CodersAdda Referral Code',
    );
  }

  void _shareViaApp(String platform) async {
    final text = Uri.encodeComponent(
      'Hey! Use my CodersAdda referral code: $_code to get discounts and rewards. Download now: https://codersadda.com',
    );

    Uri? uri;
    if (platform == 'whatsapp') {
      uri = Uri.parse('whatsapp://send?text=$text');
    } else if (platform == 'telegram') {
      uri = Uri.parse('tg://msg?text=$text');
    }

    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _shareCode();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Hero Card: Welcome, Ambassador!
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizer.deviceWidth5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0052FF), Color(0xFF0033CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0033CC).withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,\nAmbassador!',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight1),
                              Text(
                                'Start referring and earn amazing rewards',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp12,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth3),
                        // Golden Trophy Box
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 50,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight2_5),

                  // Referral Code Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                color: Color(0xFF0052FF),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: AppSizer.deviceWidth2_5),
                            Text(
                              'Your Referral Code',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0B1033),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizer.deviceHeight1_5),

                        // Code Display Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _code,
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0B1033),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              InkWell(
                                onTap: _copyCode,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    color: const Color(0xFF0052FF),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppSizer.deviceHeight1_5),
                        Center(
                          child: Text(
                            'Share this code with your friends and help them learn with CodersAdda!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                        ),

                        SizedBox(height: AppSizer.deviceHeight2),

                        // Share Code Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _shareCode,
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: Text(
                              'Share Code',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0052FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        SizedBox(height: AppSizer.deviceHeight2),

                        // Social Share Circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialCircle(
                              icon: Icons.chat_rounded,
                              color: const Color(0xFF25D366),
                              bgColor: const Color(0xFFDCFCE7),
                              onTap: () => _shareViaApp('whatsapp'),
                            ),
                            SizedBox(width: AppSizer.deviceWidth4),
                            _buildSocialCircle(
                              icon: Icons.send_rounded,
                              color: const Color(0xFF0088CC),
                              bgColor: const Color(0xFFE0F2FE),
                              onTap: () => _shareViaApp('telegram'),
                            ),
                            SizedBox(width: AppSizer.deviceWidth4),
                            _buildSocialCircle(
                              icon: Icons.camera_alt_rounded,
                              color: const Color(0xFFE1306C),
                              bgColor: const Color(0xFFFCE7F3),
                              onTap: _shareCode,
                            ),
                            SizedBox(width: AppSizer.deviceWidth4),
                            _buildSocialCircle(
                              icon: Icons.more_horiz_rounded,
                              color: Colors.grey.shade700,
                              bgColor: const Color(0xFFF1F5F9),
                              onTap: _shareCode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight2_5),

                  // 4 Stats Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardStat(
                          icon: Icons.school_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBgColor: const Color(0xFFFEF3C7),
                          title: _status,
                          subtitle: 'Status',
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),
                      Expanded(
                        child: _buildDashboardStat(
                          icon: Icons.emoji_events_rounded,
                          iconColor: const Color(0xFF10B981),
                          iconBgColor: const Color(0xFFECFDF5),
                          title: 'Yes',
                          subtitle: 'Is Ambassador',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight1_5),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardStat(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF0284C7),
                          iconBgColor: const Color(0xFFE0F2FE),
                          title: '₹${_walletBalance.toStringAsFixed(0)}',
                          subtitle: 'Wallet Balance',
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),
                      Expanded(
                        child: _buildDashboardStat(
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
                ],
              ),
            ),
    );
  }

  Widget _buildSocialCircle({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildDashboardStat({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
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
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppSizer.deviceSp11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
