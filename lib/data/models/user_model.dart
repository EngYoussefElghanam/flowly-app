class UserModel {
  final String token;
  final int userId;
  final String email;
  final String name;
  final String role;

  UserModel({
    required this.token,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'], // Accessing the 'token' field we send from Node
      userId: int.parse(json['userId'].toString()),
      // We might need to adjust these based on exactly how your login controller returns data
      // For now, let's assume you send { token: "...", userId: 1, email: "..." }
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
