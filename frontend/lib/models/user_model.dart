class UserModel {
  final String email;
  final String role;
  final String name;

  UserModel({
    required this.email,
    required this.role,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role,
        'name': name,
      };

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';
}
