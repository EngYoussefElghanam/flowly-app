class StaffModel {
  final int userId; // We map 'id' to this
  final String name;
  final String email;
  final String role;
  final String? phone;
  final int ownerId;

  StaffModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.ownerId,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      userId: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'EMPLOYEE',
      phone: json['phone'],
      ownerId: json['ownerId'] ?? 0,
    );
  }
}
