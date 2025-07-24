abstract class UserEntity {
  final String email;
  final String name;
  final String uId;
  final DateTime? createdAt;

  UserEntity({
    required this.uId,
    required this.name,
    required this.email,
    this.createdAt,
  });

  // Add an abstract toMap method
  Map<String, dynamic> toMap();
}