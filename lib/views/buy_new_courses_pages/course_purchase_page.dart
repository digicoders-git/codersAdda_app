import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/purchase_success_modal.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CourseCheckoutPage extends StatefulWidget {
  final Course course;
  final String itemType;
  const CourseCheckoutPage({Key? key, required this.course, this.itemType = 'course'}) : super(key: key);

  @override
  State<CourseCheckoutPage> createState() => _CourseCheckoutPageState();
}

class _CourseCheckoutPageState extends State<CourseCheckoutPage> {
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

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final verifyBody = {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      };

      final result = await _courseService.verifyPayment(verifyBody);

      if (context.mounted) {
        if (result['success'] == true) {
          final isFree = widget.course.isFree;
          final tabIndex = PurchaseSuccessModal.getTabIndexForItemType(widget.itemType, isFree);
          
          List<String>? customBenefits;
          if (widget.itemType == 'subscription' && widget.course.description.isNotEmpty) {
            customBenefits = widget.course.description.split(', ');
          }
          
          PurchaseSuccessModal.show(
            context,
            title: widget.course.title,
            itemType: widget.itemType,
            customBenefits: customBenefits,
            onGoToMyLearning: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyLearningPage(initialTabIndex: tabIndex)),
                (route) => route.isFirst,
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Payment Verification Failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.course.price;
    final double totalAmount = _finalAmount ?? basePrice;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: AppSizer.deviceSp20,
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
                  // Course Details Card
                  _buildCourseDetailsCard(),
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

  Widget _buildCourseDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Details',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Image
                Container(
                  width: AppSizer.deviceWidth20,
                  height: AppSizer.deviceWidth15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  child: widget.course.thumbnail.isNotEmpty
                      ? Image.network(widget.course.thumbnail, fit: BoxFit.cover)
                      : Icon(
                          Icons.school,
                          color: AppColors.primaryColor,
                          size: AppSizer.deviceSp24,
                        ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        'By ${widget.course.instructor}',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: AppSizer.deviceSp14, color: Colors.grey),
                          SizedBox(width: AppSizer.deviceWidth1),
                          Text(
                            '${widget.course.duration} • ${widget.course.totalLessons} lessons',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Divider(),
            SizedBox(height: AppSizer.deviceHeight2),
            _buildFeatureItem('✓ Lifetime access'),
            _buildFeatureItem('✓ Certificate of completion'),
            _buildFeatureItem('✓ Downloadable resources'),
            _buildFeatureItem('✓ Project files included'),
            _buildFeatureItem('✓ Q&A support'),
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
    return SizedBox.shrink(); // Removed payment method selection
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
                      'Proceed to Pay',
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
    setState(() {
      _isProcessing = true;
    });

    try {
      final couponCode = _isCouponApplied ? _selectedCoupon : null;
      final orderResponse = await _courseService.createOrder(widget.course.id, itemType: widget.itemType, couponCode: couponCode);
      
      if (orderResponse['success'] == true) {
        final profile = context.read<ProfileViewModel>().user;
        
        var options = {
          'key': orderResponse['key'],
          'amount': orderResponse['amount'],
          'name': 'Coders Adda',
          'order_id': orderResponse['orderId'],
          'description': widget.course.title,
          'timeout': 300,
          'prefill': {
            'contact': profile?.mobile ?? '',
            'email': profile?.email ?? '',
            'name': profile?.name ?? ''
          },
          'theme': {
            'color': '#2196F3'
          }
        };

        _razorpay.open(options);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(orderResponse['message'] ?? 'Failed to create order'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _processPayment() {
    // Simulate payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment...'),
        duration: Duration(seconds: 2),
      ),
    );

    // After payment success
    Future.delayed(Duration(seconds: 2), () {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        widget.course.totalLessons == 1 
          ? 'Payment successful! PDF purchased.' 
          : 'Payment successful! Course enrolled.',
      ),
      backgroundColor: Colors.green,
    ),
  );

      
      // Go back to previous page
      Navigator.pop(context);
    });
  }
}

// Helper Models for Checkout Page
class Coupon {
  final String code;
  final int discount;
  final String description;
  final String type; // 'percentage' or 'fixed'

  Coupon({
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