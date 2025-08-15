class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  User({required this.id, required this.name, required this.email, this.phone, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'],
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'email': email, 'phone': phone, 'created_at': createdAt.toIso8601String(),
      };
}
