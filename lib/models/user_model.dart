import 'package:firebase_auth/firebase_auth.dart';

import '../services/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uId,
    required super.name,
    required super.email,
    super.createdAt,
  });

  factory UserModel.fromFirebaseUser(User user, {required String name}) {
    return UserModel(
      uId: user.uid,
      email: user.email ?? '',
      name: name,
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uId: map['uId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'uId': uId,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }
}
