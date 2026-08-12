class PaymentHistoryItem {
  final String id;
  final String itemType;
  final String itemId;
  final num amount;
  final String status;
  final String failureReason;
  final String createdAt;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final Map<String, dynamic> itemDetails;

  PaymentHistoryItem({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.amount,
    required this.status,
    required this.failureReason,
    required this.createdAt,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.itemDetails,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['_id'] ?? '',
      itemType: json['itemType'] ?? '',
      itemId: json['itemId'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      failureReason: json['failureReason'] ?? '',
      createdAt: json['createdAt'] ?? '',
      razorpayOrderId: json['razorpay']?['order']?['id'] ?? '',
      razorpayPaymentId: json['razorpay']?['payment']?['id'] ?? '',
      itemDetails: json['itemDetails'] ?? {},
    );
  }
}
