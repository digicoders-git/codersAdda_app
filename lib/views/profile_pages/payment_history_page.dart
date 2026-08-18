import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';
import '../../services/api_urls.dart';
import '../../utils/app_colors/app_theme.dart';
import '../../utils/app_sizer/app_sizer.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  bool isLoading = true;
  List<PaymentHistoryItem> payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final data = await PaymentService.getPaymentHistory();
      setState(() {
        payments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _downloadSlip(String paymentId) async {
    final url = '${ApiUrls.paymentSlipPrefix}/$paymentId';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not download slip. Try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPayments,
              color: AppColors.primaryColor,
              child: payments.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: const Center(child: Text("No transactions found.", style: TextStyle(fontSize: 16))),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    final bool isSuccess = payment.status == 'success';
                    final date = DateTime.tryParse(payment.createdAt);
                    final dateString = date != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal())
                        : 'Unknown date';

                    String title = "Item";
                    if (payment.itemDetails.isNotEmpty && payment.itemDetails['title'] != null) {
                      title = payment.itemDetails['title'];
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Type: ${payment.itemType.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    payment.status.toUpperCase(),
                                    style: TextStyle(
                                      color: isSuccess ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Amount',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Text(
                                      (payment.itemType == 'wallet_deposit' || payment.itemType == 'referral_reward') 
                                          ? '+ ₹${payment.amount}' 
                                          : '- ₹${payment.amount}',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp18,
                                        fontWeight: FontWeight.bold,
                                        color: (payment.itemType == 'wallet_deposit' || payment.itemType == 'referral_reward')
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Text(
                                      dateString,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isSuccess && payment.failureReason.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Reason: ${payment.failureReason}',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                            if (isSuccess) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () => _downloadSlip(payment.id),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Slip'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
    );
  }
}
