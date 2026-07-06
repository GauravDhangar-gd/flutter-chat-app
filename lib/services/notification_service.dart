import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {

  final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  Future<void> saveTokenToFirestore() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "fcmToken": token,
    });
  }

  void listenTokenRefresh() {

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) return;

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({
          "fcmToken": newToken,
        });
      },
    );
  }

  Future<void> initialize() async {

    await FirebaseMessaging.instance.requestPermission();

    await saveTokenToFirestore();

    listenTokenRefresh();
  }
}