import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchWalletData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                controller: _scrollController,
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
                onTap: _showAddMoneyDialog,
              ),
              _buildActionButton(
                icon: Icons.currency_rupee,
                title: "Withdraw",
                color: AppColors.primaryColor,
                onTap: _showWithdrawDialog,
              ),
              _buildActionButton(
                icon: Icons.history,
                title: "History",
                color: AppColors.accentColor,
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              _buildActionButton(
                icon: Icons.share,
                title: "Share",
                color: AppColors.errorColor,
                onTap: () {
                  Share.share(
                    "Hey, checkout CodersAdda App! Earn rewards and manage your wallet balance. Download now!",
                  );
                },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  void _showAddMoneyDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Money"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter amount to add to your wallet:"),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Amount (e.g. 500)",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text.trim());
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
                return;
              }
              Navigator.pop(context);
              _showSupportSelection(amt);
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  void _showSupportSelection(double amount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Wallet Balance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "To add ₹${amount.toStringAsFixed(2)} to your wallet, choose one of the options below:",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.blue),
              title: const Text("Simulate Top-up (Testing Only)"),
              subtitle: const Text("Instantly add balance to test in-app purchases"),
              onTap: () {
                Navigator.pop(context);
                _simulateWalletTopup(amount);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("Contact Support (Official)"),
              subtitle: const Text("Official top-up via WhatsApp Support (+91 9369793688)"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("WhatsApp support: +91 9369793688. Balance will be updated soon."),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateWalletTopup(double amount) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(ApiUrls.walletTopup, {
        'amount': amount,
      });

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Successfully added money!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Failed to top up wallet"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _fetchWalletData();
    }
  }

  void _showWithdrawDialog() {
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
    final user = profileVm.user;
    
    if (user != null && user.isAmbassador && _totalBalance < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ambassadors can only withdraw when balance is at least ₹500"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    final TextEditingController upiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Withdraw Money"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Available Balance: ₹${_totalBalance.toStringAsFixed(2)}"),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: upiController,
              decoration: const InputDecoration(
                hintText: "Enter UPI ID (e.g. user@ybl)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text.trim());
              final upi = upiController.text.trim();
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
                return;
              }
              if (amt > _totalBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Insufficient wallet balance")),
                );
                return;
              }
              if (upi.isEmpty || !upi.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid UPI ID")),
                );
                return;
              }
              Navigator.pop(context);
              _submitWalletWithdrawal(amt, upi);
            },
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWalletWithdrawal(double amount, String upiId) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(ApiUrls.walletWithdraw, {
        'amount': amount,
        'upiId': upiId,
      });

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Withdrawal request submitted!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Withdrawal failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _fetchWalletData();
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp11,
                  color: AppColors.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              if (status == 'SUCCESS')
                InkWell(
                  onTap: () async {
                    final url = Uri.parse('${ApiUrls.baseUrl}/payment/slip/${tx['_id']}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 14, color: AppColors.primaryColor),
                      SizedBox(width: 4),
                      Text("Slip", style: TextStyle(fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
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
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchWalletData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                controller: _scrollController,
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
                onTap: _showAddMoneyDialog,
              ),
              _buildActionButton(
                icon: Icons.currency_rupee,
                title: "Withdraw",
                color: AppColors.primaryColor,
                onTap: _showWithdrawDialog,
              ),
              _buildActionButton(
                icon: Icons.history,
                title: "History",
                color: AppColors.accentColor,
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              _buildActionButton(
                icon: Icons.share,
                title: "Share",
                color: AppColors.errorColor,
                onTap: () {
                  Share.share(
                    "Hey, checkout CodersAdda App! Earn rewards and manage your wallet balance. Download now!",
                  );
                },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  void _showAddMoneyDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Money"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter amount to add to your wallet:"),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Amount (e.g. 500)",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text.trim());
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
                return;
              }
              Navigator.pop(context);
              _showSupportSelection(amt);
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  void _showSupportSelection(double amount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Wallet Balance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "To add ₹${amount.toStringAsFixed(2)} to your wallet, choose one of the options below:",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.blue),
              title: const Text("Simulate Top-up (Testing Only)"),
              subtitle: const Text("Instantly add balance to test in-app purchases"),
              onTap: () {
                Navigator.pop(context);
                _simulateWalletTopup(amount);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("Contact Support (Official)"),
              subtitle: const Text("Official top-up via WhatsApp Support (+91 9369793688)"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("WhatsApp support: +91 9369793688. Balance will be updated soon."),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateWalletTopup(double amount) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(ApiUrls.walletTopup, {
        'amount': amount,
      });

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Successfully added money!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Failed to top up wallet"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _fetchWalletData();
    }
  }

  void _showWithdrawDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController upiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Withdraw Money"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Available Balance: ₹${_totalBalance.toStringAsFixed(2)}"),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: upiController,
              decoration: const InputDecoration(
                hintText: "Enter UPI ID (e.g. user@ybl)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text.trim());
              final upi = upiController.text.trim();
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
                return;
              }
              if (amt > _totalBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Insufficient wallet balance")),
                );
                return;
              }
              if (upi.isEmpty || !upi.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid UPI ID")),
                );
                return;
              }
              Navigator.pop(context);
              _submitWalletWithdrawal(amt, upi);
            },
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWalletWithdrawal(double amount, String upiId) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(ApiUrls.walletWithdraw, {
        'amount': amount,
        'upiId': upiId,
      });

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Withdrawal request submitted!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Withdrawal failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _fetchWalletData();
    }
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