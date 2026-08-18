import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/purchase_success_modal.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';

class SubscriptionCheckoutPage extends StatefulWidget {
  final SubscriptionPlan plan;

  const SubscriptionCheckoutPage({Key? key, required this.plan}) : super(key: key);

  @override
  State<SubscriptionCheckoutPage> createState() => _SubscriptionCheckoutPageState();
}

class _SubscriptionCheckoutPageState extends State<SubscriptionCheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponApplied = false;
  double _discountAmount = 0;
  double? _finalAmount;
  double? _discountPercent;
  String _selectedCoupon = '';
  String _selectedPaymentMethod = 'UPI';
  bool _isValidatingCoupon = false;
  String? _couponErrorMessage;

  late Razorpay _razorpay;
  final CourseService _courseService = CourseService();
  bool _isProcessing = false;
  
  List<Map<String, dynamic>> _activeCoupons = [];
  bool _isLoadingCoupons = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveCoupons();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchActiveCoupons() async {
    try {
      final coupons = await _courseService.getActiveCoupons();
      if (mounted) {
        setState(() {
          _activeCoupons = coupons;
          _isLoadingCoupons = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCoupons = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);
    try {
      final verifyBody = {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      };
      final result = await _courseService.verifyPayment(verifyBody);
      if (mounted) {
        if (result['success'] == true) {
          PurchaseSuccessModal.show(
            context,
            title: widget.plan.name,
            itemType: 'subscription',
            customBenefits: widget.plan.features,
            onClose: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onGoToMyLearning: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyLearningPage(initialTabIndex: 3)), // Assuming 3 is subscription tab
                (route) => route.isFirst,
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Verification failed'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External Wallet: ${response.walletName}')));
  }

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.plan.price;
    final double totalAmount = _finalAmount ?? basePrice;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Subscription Checkout',
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              ),
      ),
      body: Column(
        children: [
          // Order Summary Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscription Plan Details Card
                  _buildPlanDetailsCard(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Coupon Section
                  _buildCouponSection(basePrice),
                  SizedBox(height: AppSizer.deviceHeight4),
/*
                  // Available Coupons
                  _buildAvailableCoupons(),
                  SizedBox(height: AppSizer.deviceHeight4),
*/

                  // Price Breakdown
                  _buildPriceBreakdown(basePrice, totalAmount),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Payment Methods
                  _buildPaymentMethods(),
                  
                  SizedBox(height: AppSizer.deviceHeight4),
                ],
              ),
            ),
          ),

          // Bottom Payment Section
          _buildPaymentSection(totalAmount),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Plan',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Icon
                Container(
                  width: AppSizer.deviceWidth20,
                  height: AppSizer.deviceWidth20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: AppColors.primaryColor,
                    size: AppSizer.deviceSp24,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Name with Popular Badge
                      Row(
                        children: [
                          Text(
                            widget.plan.name,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(width: AppSizer.deviceWidth2),
                          if (widget.plan.isPopular)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth2,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizer.deviceSp8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        widget.plan.duration,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp14,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        'Access on ${widget.plan.deviceLimit} device${widget.plan.deviceLimit > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Divider(),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'Plan Features:',
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            ...widget.plan.features.map((feature) => _buildFeatureItem(feature)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(double amount) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply Coupon',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth2,
                        vertical: AppSizer.deviceHeight1_5,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                ElevatedButton(
                  onPressed: _isValidatingCoupon ? null : () => _applyCoupon(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isValidatingCoupon 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Apply',
                        style: TextStyle(color: Colors.white),
                      ),
                ),
              ],
            ),
            if (_couponErrorMessage != null) ...[
              SizedBox(height: AppSizer.deviceHeight1),
              Text(
                _couponErrorMessage!,
                style: TextStyle(color: Colors.red, fontSize: AppSizer.deviceSp12),
              ),
            ],
            if (!_isCouponApplied && _isLoadingCoupons)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else if (!_isCouponApplied && _activeCoupons.isNotEmpty) ...[
              SizedBox(height: AppSizer.deviceHeight2),
              Text(
                'Available Coupons:',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight1),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _activeCoupons.length,
                  separatorBuilder: (context, index) => SizedBox(width: AppSizer.deviceWidth3),
                  itemBuilder: (context, index) {
                    final coupon = _activeCoupons[index];
                    return GestureDetector(
                      onTap: () {
                        _couponController.text = coupon['code'];
                        _applyCoupon(amount);
                      },
                      child: Container(
                        width: 200,
                        padding: EdgeInsets.all(AppSizer.deviceWidth2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primaryColor.withOpacity(0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              coupon['code'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                fontSize: AppSizer.deviceSp14,
                              ),
                            ),
                            if (coupon['discountPercent'] != null)
                              Text(
                                '${coupon['discountPercent']}% OFF',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: AppSizer.deviceSp12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_isCouponApplied) ...[
              SizedBox(height: AppSizer.deviceHeight2),
              Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: AppSizer.deviceSp18),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coupon Applied!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            'You saved ₹$_discountAmount with $_selectedCoupon',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: AppSizer.deviceSp12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _removeCoupon,
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCoupons() {
    return SizedBox.shrink();
  }

  Widget _buildPriceBreakdown(double basePrice, double totalAmount) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Details',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            _buildPriceRow('Original Price', '₹${basePrice.toStringAsFixed(2)}'),
            if (_discountAmount > 0)
              _buildPriceRow('Coupon Discount', '-₹${_discountAmount.toStringAsFixed(2)}', isDiscount: true),
            Divider(),
            SizedBox(height: AppSizer.deviceHeight2),
            _buildPriceRow(
              'Total To Pay',
              '₹${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            if (_discountAmount > 0) ...[
              SizedBox(height: AppSizer.deviceHeight2),
              Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green, size: AppSizer.deviceSp16),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Text(
                      'You save ₹${_discountAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final List<PaymentMethod> paymentMethods = [
      PaymentMethod(name: 'UPI', icon: Icons.phone_android, description: 'Google Pay, PhonePe, etc.'),
      PaymentMethod(name: 'Credit Card', icon: Icons.credit_card, description: 'Visa, MasterCard, RuPay'),
      PaymentMethod(name: 'Debit Card', icon: Icons.credit_card, description: 'Visa, MasterCard, RuPay'),
      PaymentMethod(name: 'Net Banking', icon: Icons.account_balance, description: 'All major banks'),
      PaymentMethod(name: 'Wallet', icon: Icons.wallet, description: 'Paytm, Amazon Pay'),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            ...paymentMethods.map((method) => _buildPaymentMethodItem(method)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth2),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(method.icon, color: AppColors.primaryColor, size: AppSizer.deviceSp20),
        ),
        title: Text(method.name),
        subtitle: Text(method.description),
        trailing: Radio(
          value: method.name,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value.toString();
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.name;
          });
        },
      ),
    );
  }

  Widget _buildPaymentSection(double totalAmount) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth6,
                    vertical: AppSizer.deviceHeight2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Subscribe Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: AppSizer.deviceSp16),
          SizedBox(width: AppSizer.deviceWidth2),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: isDiscount ? Colors.green : AppColors.textColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: isDiscount ? Colors.green : (isTotal ? AppColors.primaryColor : AppColors.textColor),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon(double amount) async {
    final enteredCode = _couponController.text.trim();
    if (enteredCode.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
      _couponErrorMessage = null;
    });

    try {
      final response = await _courseService.validateCoupon(enteredCode, amount);
      if (response['success'] == true) {
        setState(() {
          _isCouponApplied = true;
          _selectedCoupon = enteredCode;
          _discountAmount = (response['discountAmount'] as num).toDouble();
          _finalAmount = (response['finalAmount'] as num).toDouble();
          _discountPercent = (response['discountPercent'] as num).toDouble();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coupon Applied Successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _couponErrorMessage = response['message'] ?? 'Invalid coupon code';
        });
      }
    } catch (e) {
      setState(() {
        _couponErrorMessage = e.toString().replaceAll('Exception:', '').replaceAll('Error:', '').trim();
      });
    } finally {
      setState(() {
        _isValidatingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _isCouponApplied = false;
      _discountAmount = 0;
      _finalAmount = null;
      _discountPercent = null;
      _selectedCoupon = '';
      _couponController.clear();
      _couponErrorMessage = null;
    });
  }

  void _proceedToPayment() async {
    setState(() => _isProcessing = true);
    try {
      final couponCode = _isCouponApplied ? _selectedCoupon : null;
      final orderResponse = await _courseService.createOrder(
        widget.plan.id, 
        itemType: 'subscription', 
        couponCode: couponCode
      );

      if (orderResponse['success'] == true) {
        final profile = context.read<ProfileViewModel>().user;
        var options = {
          'key': orderResponse['key'],
          'amount': orderResponse['amount'],
          'name': 'Coders Adda',
          'order_id': orderResponse['orderId'],
          'description': widget.plan.name,
          'timeout': 300,
          'prefill': {
            'contact': profile?.mobile ?? '',
            'email': profile?.email ?? '',
            'name': profile?.name ?? ''
          },
          'theme': {'color': '#2196F3'}
        };
        _razorpay.open(options);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(orderResponse['message'] ?? 'Order creation failed'), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _processSubscriptionPayment() {
    // This method is now replaced by _proceedToPayment logic directly or called via Confirm
    _proceedToPayment();
  }
}

// Helper Models for Subscription Checkout
class SubscriptionCoupon {
  final String code;
  final int discount;
  final String description;
  final String type; // 'percentage' or 'fixed'

  SubscriptionCoupon({
    required this.code,
    required this.discount,
    required this.description,
    required this.type,
  });
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final String description;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.description,
  });
}