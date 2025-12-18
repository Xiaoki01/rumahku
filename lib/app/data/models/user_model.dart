class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'pengguna':
        return 'Pemilik Bangunan';
      case 'kepala_proyek':
        return 'Kepala Proyek';
      case 'mandor':
        return 'Mandor';
      default:
        return role;
    }
  }
}
