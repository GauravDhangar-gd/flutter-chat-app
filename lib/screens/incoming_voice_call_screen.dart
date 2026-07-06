import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/call_service.dart';
import 'voice_call_screen.dart';

class IncomingVoiceCallScreen extends StatelessWidget {
  final String callerId;
  final String receiverId;
  final String channelName;

  const IncomingVoiceCallScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
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
                "Incoming Voice Call",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                callerId,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 70),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [

                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await CallService()
                            .endCall(receiverId: receiverId, callerId: callerId, isVideo: false, duration: 0);

                        Navigator.pop(context);
                      },
                    ),
                  ),

                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      onPressed: () async {

                        await FirebaseFirestore.instance
                            .collection("calls")
                            .doc(receiverId)
                            .update({
                          "status": "accepted",
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VoiceCallScreen(
                              channelName:
                                  channelName,
                              receiverId:
                                  callerId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}