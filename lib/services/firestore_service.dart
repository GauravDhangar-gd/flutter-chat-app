import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save New User
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection("users").doc(user.uid).set(user.toMap());
  }

  /// Check if user profile already exists
  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();

    return doc.exists;
  }

  /// Get Current User
  Future<UserModel?> getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return null;

    final doc = await _firestore.collection("users").doc(currentUser.uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  /// Get User by UID
  Stream<UserModel> getUser(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data()!));
  }

  /// Get All Users Except Current User
  Stream<List<UserModel>> getUsers() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("users")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where((user) => user.uid != currentUser.uid)
              .toList(),
        );
  }

  /// Update Profile Photo
  Future<void> updateProfilePhoto({
    required String uid,
    required String photoUrl,
  }) async {
    await _firestore.collection("users").doc(uid).update({
      "photoUrl": photoUrl,
    });
  }

  /// Remove Profile Photo
  Future<void> removeProfilePhoto(String uid) async {
    await _firestore.collection("users").doc(uid).update({"photoUrl": ""});
  }

  /// Update Online Status
  Future<void> updateUserStatus({required bool isOnline}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    await _firestore.collection("users").doc(currentUser.uid).update({
      "isOnline": isOnline,
      "lastSeen": DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Update FCM Token
  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) async {
    await _firestore.collection("users").doc(uid).update({"fcmToken": token});
  }
}
