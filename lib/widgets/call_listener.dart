import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/incoming_voice_call_screen.dart';
import '../screens/incoming_call_screen.dart';
import '../services/call_service.dart';

class CallListener extends StatefulWidget {
  final Widget child;

  const CallListener({
    super.key,
    required this.child,
  });

  @override
  State<CallListener> createState() =>
      _CallListenerState();
}

class _CallListenerState
    extends State<CallListener> {

  bool showingCall = false;

  @override
  void initState() {
    super.initState();

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    CallService()
        .incomingCall(uid)
        .listen((snapshot) {

      if (!snapshot.exists) {
        showingCall = false;
        return;
      }

      if (showingCall) return;

      showingCall = true;

      final data = snapshot.data()!;

      final callType = data["callType"] ?? "video";

      Widget screen;

      if (callType == "voice") {
        screen = IncomingVoiceCallScreen(
          callerId: data["callerId"],
          receiverId: data["receiverId"],
          channelName: data["channelName"],
        );
      } else {
        screen = IncomingCallScreen(
          callerId: data["callerId"],
          receiverId: data["receiverId"],
          channelName: data["channelName"],
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => screen,
        ),
      ).then((_) {
        showingCall = false;
      }).
      then((_) {
        showingCall = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}