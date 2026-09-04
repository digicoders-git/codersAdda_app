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
            onClose: () {
              Navigator.pop(context); // Close modal
              Navigator.pop(context); // Pop CourseCheckoutPage
            },
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B), // Dark text
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
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

  Widget _buildSectionHeader(int number, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
          child: Center(
            child: Text(number.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildCourseDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(1, 'Course Details'),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image (Square)
                  Container(
                    width: AppSizer.deviceWidth20,
                    height: AppSizer.deviceWidth20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF0F172A),
                      image: widget.course.thumbnail.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.course.thumbnail),
                              fit: BoxFit.cover,
                            )
                          : null,
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
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'By ${widget.course.instructor}',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.course.duration.isNotEmpty ? widget.course.duration : '0h'}  •  ${widget.course.totalLessons} Lessons',
                              style: const TextStyle(
                                fontSize: 11,
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
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              // Features Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureItem('Lifetime access'),
                        _buildFeatureItem('Certificate of completion'),
                        _buildFeatureItem('Downloadable resources'),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureItem('Project files included'),
                        _buildFeatureItem('Q&A support'),
                        _buildFeatureItem('Access on mobile & TV'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCouponSection(double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(2, 'Apply Coupon'),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC), // Very light grey blue
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2563EB)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth4,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth2),
                  ElevatedButton(
                    onPressed: _isValidatingCoupon ? null : () => _applyCoupon(amount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isValidatingCoupon 
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else if (!_isCouponApplied && _activeCoupons.isNotEmpty) ...[
                SizedBox(height: AppSizer.deviceHeight2),
                Text(
                  'Available Coupons:',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
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
                          padding: EdgeInsets.all(AppSizer.deviceWidth3),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    coupon['code'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                      fontSize: AppSizer.deviceSp14,
                                    ),
                                  ),
                                  if (coupon['discountPercent'] != null)
                                    Text(
                                      'Save ${coupon['discountPercent']}%',
                                      style: TextStyle(
                                        color: const Color(0xFF16A34A),
                                        fontSize: AppSizer.deviceSp12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
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
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Coupon Applied!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                            Text(
                              'You saved ₹$_discountAmount with $_selectedCoupon',
                              style: TextStyle(
                                color: const Color(0xFF166534),
                                fontSize: AppSizer.deviceSp12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _removeCoupon,
                        child: const Text(
                          'Remove',
                          style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableCoupons() {
    return const SizedBox.shrink();
  }

  Widget _buildPriceBreakdown(double basePrice, double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(3, 'Price Details'),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceRow('Original Price', '₹${basePrice.toStringAsFixed(2)}'),
              if (_discountAmount > 0)
                _buildPriceRow('Coupon Discount', '-₹${_discountAmount.toStringAsFixed(2)}', isDiscount: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: Color(0xFFE2E8F0)),
              ),
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
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings, color: Color(0xFF16A34A), size: 16),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Text(
                        'You save ₹${_discountAmount.toStringAsFixed(2)} on this order!',
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return SizedBox.shrink(); // Removed payment method selection
  }

  Widget _buildPaymentSection(double totalAmount) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSizer.deviceWidth4, AppSizer.deviceHeight2, AppSizer.deviceWidth4, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'one-time payment',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(width: AppSizer.deviceWidth4),
            Expanded(
              child: FilledButton(
                onPressed: _isProcessing ? null : _proceedToPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizer.deviceHeight1_5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'PROCEED TO PAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
    final cleanText = text.replaceFirst(RegExp(r'^[✓\s]+'), '');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: AppColors.logoGreen, size: AppSizer.deviceSp15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              cleanText,
              style: TextStyle(
                fontSize: AppSizer.deviceSp12,
                color: AppColors.onSurfaceVariant,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
              color: isDiscount ? AppColors.logoGreen : AppColors.logoNavy,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: isDiscount ? AppColors.logoGreen : (isTotal ? AppColors.primaryColor : AppColors.logoNavy),
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
              backgroundColor: AppColors.logoGreen,
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
      backgroundColor: AppColors.logoGreen,
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