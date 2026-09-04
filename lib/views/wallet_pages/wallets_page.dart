import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:coders_adda_app/views/wallet_pages/add_money_page.dart';
import 'package:coders_adda_app/views/wallet_pages/withdraw_page.dart';
import 'package:coders_adda_app/views/profile_pages/payment_history_page.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  bool _isLoading = true;
  double _totalBalance = 0.0;
  double _totalEarnings = 0.0;
  double _withdrawn = 0.0;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiUrls.getWallet);
      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        setState(() {
          _totalBalance = (data['totalBalance'] ?? 0).toDouble();
          _totalEarnings = (data['totalEarnings'] ?? 0).toDouble();
          _withdrawn = (data['withdrawn'] ?? 0).toDouble();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _goToAddMoney() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddMoneyPage(currentBalance: _totalBalance)),
    );
    if (result == true) _fetchWalletData();
  }

  void _goToWithdraw() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => WithdrawPage(currentBalance: _totalBalance)),
    );
    if (result == true) _fetchWalletData();
  }

  void _goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
    );
  }

  void _share() {
    Share.share(
        "Hey! Checkout CodersAdda App – Learn coding, earn rewards & manage your wallet. Download now!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0B1033)),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF0B1033)),
            onPressed: () => _showHelp(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchWalletData,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Balance Header
                    _buildBalanceCard(),
                    const SizedBox(height: 14),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _buildQuickActionsCard(),
                    ),
                    const SizedBox(height: 12),

                    // Secure Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _buildSecureBanner(),
                    ),
                    const SizedBox(height: 16),

                    // Recent Transactions Preview
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _buildViewHistoryButton(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  BALANCE CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0145E6), Color(0xFF083AA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text("Total Balance",
                        style:
                            TextStyle(fontSize: 12, color: Colors.white70)),
                    SizedBox(width: 5),
                    Icon(Icons.visibility_off_outlined,
                        color: Colors.white54, size: 14),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "₹${_totalBalance.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _balanceStat(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: Colors.greenAccent,
                      label: "Total Earnings",
                      value: "₹${_totalEarnings.toStringAsFixed(2)}",
                    ),
                    Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 14),
                        height: 32,
                        width: 1,
                        color: Colors.white24),
                    _balanceStat(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: Colors.redAccent,
                      label: "Total Withdrawn",
                      value: "₹${_withdrawn.toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    size: 30, color: Colors.white.withOpacity(0.9)),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFD700), shape: BoxShape.circle),
                    child: const Icon(Icons.currency_rupee,
                        size: 9, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.25),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 11, color: iconColor),
            ),
            const SizedBox(width: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.white60)),
          ],
        ),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  QUICK ACTIONS CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Quick Actions",
                  style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.logoNavy)),
              GestureDetector(
                onTap: _goToHistory,
                child: Text("View All",
                    style: TextStyle(
                        fontSize: AppSizer.deviceSp12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionBtn(
                icon: Icons.add_card_rounded,
                label: "Add Money",
                color: const Color(0xFF25934E),
                onTap: _goToAddMoney,
              ),
              _actionBtn(
                icon: Icons.currency_rupee_rounded,
                label: "Withdraw",
                color: const Color(0xFF0145E6),
                onTap: _goToWithdraw,
              ),
              _actionBtn(
                icon: Icons.history_rounded,
                label: "Payment\nHistory",
                color: const Color(0xFFFC6304),
                onTap: _goToHistory,
              ),
              _actionBtn(
                icon: Icons.share_rounded,
                label: "Share",
                color: const Color(0xFF8B5CF6),
                onTap: _share,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizer.deviceSp10,
              fontWeight: FontWeight.w600,
              color: AppColors.logoNavy,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SECURE BANNER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSecureBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0145E6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded,
                color: Color(0xFF0145E6), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("100% Secure Payments",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF01123F))),
                SizedBox(height: 2),
                Text("Your transactions are safe with bank-level security.",
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF64748B), size: 22),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  VIEW HISTORY BUTTON
  // ─────────────────────────────────────────────────────────────
  Widget _buildViewHistoryButton() {
    return GestureDetector(
      onTap: _goToHistory,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF0145E6).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFC6304).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: Color(0xFFFC6304), size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payment History",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF01123F))),
                  SizedBox(height: 2),
                  Text("View all your transactions",
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF0145E6), size: 24),
          ],
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline_rounded,
                color: Color(0xFF0145E6), size: 22),
            SizedBox(width: 8),
            Text("Wallet Help",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          "• Add Money: Top up your wallet balance.\n\n"
          "• Withdraw: Request payout to your UPI ID (min ₹500).\n\n"
          "• Payment History: View all transactions including course purchases, wallet top-ups, and withdrawals.",
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0145E6)),
            child: const Text("Got it",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}