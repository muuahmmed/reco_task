import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../models/user_model.dart';
import '../entities/user_entity.dart';

final logger = Logger();

abstract class DatabaseService {
  Future<Map<String, dynamic>?> getData({required String path});

  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
  });

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  });

  Future<void> deleteData({required String path});

  Future<UserEntity> getUserData(String uId);
}

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getData({required String path}) async {
    try {
      final docSnapshot = await _firestore.doc(path).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      logger.e('Error fetching data from path $path: $e');
      rethrow;
    }
  }

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.doc(path).set(data);
    } catch (e) {
      logger.e('Error saving to Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.doc(path).update(data);
    } catch (e) {
      logger.e('Error updating Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteData({required String path}) async {
    try {
      await _firestore.doc(path).delete();
    } catch (e) {
      logger.e('Error deleting Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> getUserData(String uId) async {
    try {
      final docSnapshot = await _firestore.doc('users/$uId').get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(docSnapshot.data()!);
      } else {
        throw Exception('User with ID $uId not found in Firestore');
      }
    } catch (e) {
      logger.e('Error fetching user data for $uId: $e');
      rethrow;
    }
  }
}
