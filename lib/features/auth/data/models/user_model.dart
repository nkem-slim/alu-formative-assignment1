class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String campus;
  final String avatarInitials;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.campus,
    required this.avatarInitials,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'] ?? '',
        campus: json['campus'],
        avatarInitials: json['avatarInitials'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'campus': campus,
        'avatarInitials': avatarInitials,
      };
}
