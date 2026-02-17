import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';


class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

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
      body: SingleChildScrollView(
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
            "₹12,450.00",
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),
          Row(
            children: [
              _buildBalanceItem("Earnings", "₹8,250.00"),
              SizedBox(width: AppSizer.deviceWidth8),
              _buildBalanceItem("Withdrawn", "₹4,200.00"),
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
    final List<Transaction> transactions = [
      Transaction(
        id: "1",
        title: "Course Purchase",
        description: "Advanced Flutter Development",
        amount: -1299.00,
        date: "2024-01-15",
        type: TransactionType.debit,
        icon: Icons.shopping_cart,
      ),
      Transaction(
        id: "2",
        title: "Referral Bonus",
        description: "From John Doe",
        amount: 500.00,
        date: "2024-01-14",
        type: TransactionType.credit,
        icon: Icons.people,
      ),
      Transaction(
        id: "3",
        title: "Withdrawal",
        description: "Bank Transfer",
        amount: -2000.00,
        date: "2024-01-12",
        type: TransactionType.debit,
        icon: Icons.account_balance,
      ),
      Transaction(
        id: "4",
        title: "Course Earnings",
        description: "Flutter Basics Course",
        amount: 850.00,
        date: "2024-01-10",
        type: TransactionType.credit,
        icon: Icons.school,
      ),
      Transaction(
        id: "5",
        title: "Course Purchase",
        description: "UI/UX Design Masterclass",
        amount: -999.00,
        date: "2024-01-08",
        type: TransactionType.debit,
        icon: Icons.shopping_cart,
      ),
    ];

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
              TextButton(
                onPressed: () {},
                child: Text(
                  "View All",
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
            itemCount: transactions.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.outline,
              height: AppSizer.deviceHeight2,
            ),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: AppSizer.deviceWidth12,
        height: AppSizer.deviceWidth12,
        decoration: BoxDecoration(
          color: transaction.type == TransactionType.credit
              ? AppColors.successColor.withOpacity(0.1)
              : AppColors.errorColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          transaction.icon,
          color: transaction.type == TransactionType.credit
              ? AppColors.successColor
              : AppColors.errorColor,
          size: AppSizer.deviceSp18,
        ),
      ),
      title: Text(
        transaction.title,
        style: TextStyle(
          fontSize: AppSizer.deviceSp16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizer.deviceHeight0_5),
          Text(
            transaction.description,
            style: TextStyle(
              fontSize: AppSizer.deviceSp12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight0_5),
          Text(
            transaction.date,
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
            "₹${transaction.amount.abs().toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.bold,
              color: transaction.type == TransactionType.credit
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
              color: transaction.type == TransactionType.credit
                  ? AppColors.successColor.withOpacity(0.1)
                  : AppColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizer.deviceWidth1),
            ),
            child: Text(
              transaction.type == TransactionType.credit ? "Credit" : "Debit",
              style: TextStyle(
                fontSize: AppSizer.deviceSp10,
                color: transaction.type == TransactionType.credit
                    ? AppColors.successColor
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

enum TransactionType { credit, debit }

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String date;
  final TransactionType type;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
  });
}