import 'package:flutter/material.dart';
import 'video_call_screen.dart';
import '../services/call_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerId;
  final String receiverId;
  final String channelName;

  const IncomingCallScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.channelName,

  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    player.setReleaseMode(
      ReleaseMode.loop,
    );

    player.play(
      AssetSource(
        "audio/ringtone.mp3",
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              const CircleAvatar(
                radius: 55,
                child: Icon(
                  Icons.person,
                  size: 55,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Incoming Video Call",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.callerId,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 60),

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
                            .endCall(
                              callerId: widget.callerId,
                              receiverId: widget.receiverId,
                              isVideo: true,
                              duration: 0,
                            );

                        Navigator.pop(context);
                      },
                    ),
                  ),

                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                      ),
                      onPressed: () async {

                        await FirebaseFirestore.instance
                            .collection("calls")
                            .doc(widget.receiverId)
                            .update({
                          "status": "accepted",
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoCallScreen(
                              channelName: widget.channelName,
                              callerId: widget.callerId,
                              receiverId: widget.receiverId,
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
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}