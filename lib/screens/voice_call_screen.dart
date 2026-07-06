import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/call_service.dart';

class VoiceCallScreen extends StatefulWidget {
  final String channelName;
  final String receiverId;

  const VoiceCallScreen({
    super.key,
    required this.channelName,
    required this.receiverId,
  });

  @override
  State<VoiceCallScreen> createState() =>
      _VoiceCallScreenState();
}

class _VoiceCallScreenState
    extends State<VoiceCallScreen> {

  static const String appId =
      "17fdf5db98b3426bae2b85396161e677";

  RtcEngine? engine;

  bool joined = false;

  bool muted = false;

  bool speaker = true;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {

    await Permission.microphone.request();

    engine = createAgoraRtcEngine();

    await engine!.initialize(
      const RtcEngineContext(
        appId: appId,
      ),
    );

    engine!.registerEventHandler(
      RtcEngineEventHandler(

        onJoinChannelSuccess:
            (connection, elapsed) {

          setState(() {
            joined = true;
          });

        },

      ),
    );

    await engine!.enableAudio();

    await engine!.joinChannel(
      token: "",
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> toggleMute() async {

    muted = !muted;

    await engine?.muteLocalAudioStream(
      muted,
    );

    setState(() {});
  }

  Future<void> toggleSpeaker() async {

    speaker = !speaker;

    await engine?.setEnableSpeakerphone(
      speaker,
    );

    setState(() {});
  }

  Future<void> endCall() async {

    await CallService()
        .endCall(
          callerId: widget.receiverId,
          receiverId: widget.receiverId,
          isVideo: false,
          duration: 0,
          isMissed: false,
        );

    await engine?.leaveChannel();

    await engine?.release();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {

    engine?.leaveChannel();

    engine?.release();

    super.dispose();
  }

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

              const SizedBox(height: 20),

              Text(
                joined
                    ? "Connected"
                    : "Connecting...",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),

              const SizedBox(height: 70),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [

                  CircleAvatar(
                    radius: 30,
                    child: IconButton(
                      icon: Icon(
                        muted
                            ? Icons.mic_off
                            : Icons.mic,
                      ),
                      onPressed: toggleMute,
                    ),
                  ),

                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                      onPressed: endCall,
                    ),
                  ),

                  CircleAvatar(
                    radius: 30,
                    child: IconButton(
                      icon: Icon(
                        speaker
                            ? Icons.volume_up
                            : Icons.volume_off,
                      ),
                      onPressed: toggleSpeaker,
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