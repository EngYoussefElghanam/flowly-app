class OrderModel {
  final int id;
  final String status;
  final double totalAmount;
  final String? courierName;
  final String? notes;
  final String? trackingNumber;
  final String date;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.courierName,
    this.notes,
    this.trackingNumber,
    required this.date,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0, // Safety first
      status: json['status'] ?? 'NEW',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),

      // ✅ FIX 1: Actually map these fields!
      courierName: json['courierName'], // null is fine here
      notes: json['notes'], // null is fine here
      // ✅ FIX 2: Parse as String to match Sequelize.STRING
      trackingNumber: json['trackingNumber']?.toString(),

      date: json['createdAt'] != null
          ? json['createdAt'].toString().split('T')[0]
          : 'Unknown Date',
    );
  }
}
