import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';

class AddMoneyPage extends StatefulWidget {
  final double currentBalance;
  const AddMoneyPage({super.key, this.currentBalance = 0.0});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  int? _selectedQuick;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuick(int amt) {
    setState(() {
      _selectedQuick = amt;
      _amountController.text = amt.toString();
    });
  }

  Future<void> _proceed() async {
    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) {
      _snack("Please enter a valid amount", isError: true);
      return;
    }
    if (amt > 2000) {
      _snack("Maximum top-up limit is ₹2,000", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response =
          await _apiClient.post(ApiUrls.walletTopup, {'amount': amt});
      if (response != null && response['success'] == true) {
        _snack(response['message'] ?? "₹${amt.toStringAsFixed(0)} added to wallet!");
        if (mounted) Navigator.pop(context, true);
      } else {
        _snack(response?['message'] ?? "Failed to add money", isError: true);
      }
    } catch (e) {
      _snack("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF25934E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text("Add Money",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Top icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF25934E).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_card_rounded,
                  color: Color(0xFF25934E), size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              "Add Money",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF01123F)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Enter amount to add to your wallet",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 30),

            // Amount Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter Amount",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF01123F))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    onChanged: (_) => setState(() => _selectedQuick = null),
                    decoration: InputDecoration(
                      hintText: "e.g. 500",
                      prefixIcon: const Icon(Icons.currency_rupee,
                          color: Color(0xFF64748B), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF0145E6), width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Quick Select",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  Row(
                    children: [100, 500, 1000].map((amt) {
                      final isSelected = _selectedQuick == amt;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _selectQuick(amt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0145E6)
                                    : const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0145E6)
                                        : const Color(0xFF0145E6)
                                            .withOpacity(0.2)),
                              ),
                              child: Center(
                                child: Text(
                                  "+ ₹$amt",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0145E6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Security note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0145E6).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: Color(0xFF0145E6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "100% Secure • Powered by Razorpay",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF01123F)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _proceed,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(_isLoading ? "Processing..." : "Proceed to Pay"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0145E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
