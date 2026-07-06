import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save a new user
  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  /// Get all users except the currently logged-in user
  Stream<List<UserModel>> getUsers() {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data()),
              )
              .where((user) => user.uid != currentUid)
              .toList(),
        );
  }
  
  Stream<UserModel> getUser(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map(
          (doc) => UserModel.fromMap(doc.data()!),
        );
  }

  /// Update profile photo
  Future<void> updateProfilePhoto(
    String uid,
    String photoUrl,
  ) async {

    print("Updating Firestore...");
    print(uid);
    print(photoUrl);

    await _firestore
        .collection("users")
        .doc(uid)
        .update({
          "photoUrl": photoUrl,
        });

    print("Firestore Updated Successfully");
  }
  /// remove profile photo
  Future<void> removeProfilePhoto(String uid) async {
  await _firestore.collection("users").doc(uid).update({
    "photoUrl": "",
  });
  }

  Future<void> updateUserStatus({
    required bool isOnline,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _firestore.collection("users").doc(uid).update({
      "isOnline": isOnline,
      "lastSeen": DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Get current user details
  Future<UserModel?> getCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }
}