import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/call_service.dart';
import 'video_call_screen.dart';


class CallingScreen extends StatefulWidget {
  final String callerId;
  final String receiverId;
  final String channelName;
  final bool isVideo;

  const CallingScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.channelName,
    this.isVideo = true,
  });

  @override
  State<CallingScreen> createState() =>
      _CallingScreenState();
}

class _CallingScreenState
    extends State<CallingScreen> {

  Timer? timer;
  StreamSubscription? callSubscription;

  int seconds = 30;

  @override
  void initState() {
    super.initState();
    callSubscription =
        CallService()
            .watchCall(widget.receiverId)
            .listen((snapshot) {

              if (!snapshot.exists) return;

              final data = snapshot.data();

              if (data == null) return;

              if (data["status"] == "accepted") {


                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoCallScreen(
                      channelName: widget.channelName,
                      callerId: widget.callerId,
                      receiverId: widget.receiverId,
                      isVideo: true,
                    ),
                  ),
                );
              }
            });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) async {

        seconds--;

        setState(() {});

        if (seconds <= 0) {

          await CallService().endCall(
            callerId: widget.callerId,
            receiverId: widget.receiverId,
            isVideo: true,
            isMissed: true,
          );

          if (mounted) {
            Navigator.pop(context);
          }

          timer?.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: SafeArea(

        child: Center(

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const CircleAvatar(
                radius: 60,
                child: Icon(
                  Icons.person,
                  size: 60,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Calling...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "$seconds sec",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 60),

              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                  onPressed: () async {

                    await CallService().endCall(
                      callerId: widget.callerId,
                      receiverId: widget.receiverId,
                      isVideo: true,
                      isMissed: true,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}