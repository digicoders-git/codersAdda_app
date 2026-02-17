// views/subscription_checkout_page.dart
import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/models/subscription_model.dart';

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
  String _selectedCoupon = '';
  String _selectedPaymentMethod = 'UPI';
  
  final List<SubscriptionCoupon> _availableCoupons = [
    SubscriptionCoupon(code: 'STUDENT30', discount: 30, description: '30% off for students', type: 'percentage'),
    SubscriptionCoupon(code: 'WELCOME20', discount: 20, description: '20% off on first subscription', type: 'percentage'),
    SubscriptionCoupon(code: 'FLAT50', discount: 50, description: 'Flat ₹50 off', type: 'fixed'),
    SubscriptionCoupon(code: 'CODERS25', discount: 25, description: '25% off for Coders Adda', type: 'percentage'),
  ];

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.plan.price;
    final double gst = basePrice * 0.18; // 18% GST
    final double totalAmount = basePrice + gst - _discountAmount;

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                  _buildCouponSection(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Available Coupons
                  _buildAvailableCoupons(),
                  SizedBox(height: AppSizer.deviceHeight4),

                  // Price Breakdown
                  _buildPriceBreakdown(basePrice, gst, totalAmount),
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

  Widget _buildCouponSection() {
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
                  onPressed: _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Coupons',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            ..._availableCoupons.map((coupon) => _buildCouponItem(coupon)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponItem(SubscriptionCoupon coupon) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      padding: EdgeInsets.all(AppSizer.deviceWidth3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizer.deviceWidth2),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              coupon.code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.description,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  coupon.type == 'percentage' 
                      ? '${coupon.discount}% OFF' 
                      : '₹${coupon.discount} OFF',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: AppSizer.deviceSp12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _couponController.text = coupon.code;
              _applyCoupon();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight1,
              ),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(double basePrice, double gst, double totalAmount) {
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
            _buildPriceRow('Subscription Price', '₹${basePrice.toStringAsFixed(2)}'),
            _buildPriceRow('GST (18%)', '₹${gst.toStringAsFixed(2)}'),
            if (_discountAmount > 0)
              _buildPriceRow('Discount', '-₹${_discountAmount.toStringAsFixed(2)}', isDiscount: true),
            Divider(),
            SizedBox(height: AppSizer.deviceHeight2),
            _buildPriceRow(
              'Total Amount',
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
                onPressed: _proceedToPayment,
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
                child: Text(
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

  void _applyCoupon() {
    final enteredCode = _couponController.text.trim();
    final coupon = _availableCoupons.firstWhere(
      (c) => c.code == enteredCode,
      orElse: () => SubscriptionCoupon(code: '', discount: 0, description: '', type: ''),
    );

    if (coupon.code.isNotEmpty) {
      setState(() {
        _isCouponApplied = true;
        _selectedCoupon = coupon.code;
        _discountAmount = coupon.type == 'percentage' 
            ? (widget.plan.price * coupon.discount / 100)
            : coupon.discount.toDouble();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon applied successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid coupon code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _isCouponApplied = false;
      _discountAmount = 0;
      _selectedCoupon = '';
      _couponController.clear();
    });
  }

  void _proceedToPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${widget.plan.name}'),
            Text('Duration: ${widget.plan.duration}'),
            Text('Amount: ₹${(widget.plan.price * 1.18 - _discountAmount).toStringAsFixed(2)}'),
            Text('Payment Method: $_selectedPaymentMethod'),
            if (_isCouponApplied) Text('Coupon: $_selectedCoupon'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processSubscriptionPayment();
            },
            child: Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _processSubscriptionPayment() {
    // Simulate payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing subscription...'),
        duration: Duration(seconds: 2),
      ),
    );

    // After payment success
    Future.delayed(Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscription activated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Go back to previous page
      Navigator.pop(context);
    });
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