import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:intl/intl.dart';

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
  List<dynamic> _transactions = [];
  bool _showAllTransactions = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    try {
      final response = await _apiClient.get(ApiUrls.getWallet);
      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        setState(() {
          _totalBalance = (data['totalBalance'] ?? 0).toDouble();
          _totalEarnings = (data['totalEarnings'] ?? 0).toDouble();
          _withdrawn = (data['withdrawn'] ?? 0).toDouble();
          _transactions = (data['transactions'] as List?) ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "My Wallet",
          style: TextStyle(
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchWalletData,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSizer.deviceWidth4),
                child: Column(
                  children: [
                    // Balance Card
                    _buildBalanceCard(),
                    SizedBox(height: AppSizer.deviceHeight3),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    SizedBox(height: AppSizer.deviceHeight3),
                    
                    // Transaction History
                    _buildTransactionHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizer.deviceWidth6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Balance",
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            "₹${_totalBalance.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),
          Row(
            children: [
              _buildBalanceItem("Earnings", "₹${_totalEarnings.toStringAsFixed(2)}"),
              SizedBox(width: AppSizer.deviceWidth8),
              _buildBalanceItem("Withdrawn", "₹${_withdrawn.toStringAsFixed(2)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          amount,
          style: TextStyle(
            fontSize: AppSizer.deviceSp16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.account_balance_wallet,
                title: "Add Money",
                color: AppColors.successColor,
              ),
              _buildActionButton(
                icon: Icons.currency_rupee,
                title: "Withdraw",
                color: AppColors.primaryColor,
              ),
              _buildActionButton(
                icon: Icons.history,
                title: "History",
                color: AppColors.accentColor,
              ),
              _buildActionButton(
                icon: Icons.share,
                title: "Share",
                color: AppColors.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: AppSizer.deviceWidth15,
          height: AppSizer.deviceWidth15,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: AppSizer.deviceSp20,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          title,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizer.deviceWidth6),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        child: Center(
          child: Text(
            "No transactions found.",
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: AppSizer.deviceSp14,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: AppSizer.deviceSp18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              if (_transactions.length > 5)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllTransactions = !_showAllTransactions;
                    });
                  },
                  child: Text(
                    _showAllTransactions ? "View Less" : "View All",
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllTransactions 
                ? _transactions.length 
                : (_transactions.length > 5 ? 5 : _transactions.length),
            separatorBuilder: (context, index) => Divider(
              color: AppColors.outline,
              height: AppSizer.deviceHeight2,
            ),
            itemBuilder: (context, index) {
              final tx = _transactions[index];
              return _buildTransactionItem(tx);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    final String title = tx['itemName'] ?? 'Unknown Item';
    final String desc = tx['itemType'] != null ? '${tx['itemType']}'.toUpperCase() : 'TRANSACTION';
    final double amount = (tx['amount'] ?? 0).toDouble();
    
    // Attempt parse date
    String dateStr = 'Unknown Date';
    if (tx['createdAt'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(tx['createdAt']).toLocal();
        dateStr = DateFormat('MMM dd, yyyy  hh:mm a').format(parsedDate);
      } catch (_) {}
    }

    final String status = (tx['status'] ?? '').toString().toUpperCase();
    
    // For visual only - assume negative if itemType isn't 'referral' or something. 
    // We'll treat purchases as debit. We can adjust based on itemType.
    final bool isCredit = (tx['itemType']?.toLowerCase() == 'referral' || tx['itemType']?.toLowerCase() == 'reward');
    
    final IconData icon = isCredit ? Icons.account_balance_wallet : Icons.shopping_cart_checkout;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: AppSizer.deviceWidth12,
        height: AppSizer.deviceWidth12,
        decoration: BoxDecoration(
          color: isCredit
              ? AppColors.successColor.withOpacity(0.1)
              : AppColors.errorColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isCredit
              ? AppColors.successColor
              : AppColors.errorColor,
          size: AppSizer.deviceSp18,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer.deviceSp16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizer.deviceHeight0_5),
          Text(
            desc,
            style: TextStyle(
              fontSize: AppSizer.deviceSp12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight0_5),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: AppSizer.deviceSp11,
              color: AppColors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.bold,
              color: isCredit
                  ? AppColors.successColor
                  : AppColors.errorColor,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight0_5),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizer.deviceWidth2,
              vertical: AppSizer.deviceHeight0_5,
            ),
            decoration: BoxDecoration(
              color: status == 'SUCCESS' 
                  ? AppColors.successColor.withOpacity(0.1)
                  : (status == 'CREATED' || status == 'PENDING') 
                      ? Colors.orange.withOpacity(0.1)
                      : AppColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizer.deviceWidth1),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: AppSizer.deviceSp10,
                color: status == 'SUCCESS' 
                    ? AppColors.successColor
                    : (status == 'CREATED' || status == 'PENDING') 
                        ? Colors.orange
                        : AppColors.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}