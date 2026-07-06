import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String callerId;
  final String receiverId;
  final bool isVideo;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.callerId,
    required this.receiverId,
    this.isVideo = true,
  });

  @override
  State<VideoCallScreen> createState() =>
      _VideoCallScreenState();
}

class _VideoCallScreenState
    extends State<VideoCallScreen> {

  // Replace with your Agora App ID
  static const String appId =
      "17fdf5db98b3426bae2b85396161e677";

  RtcEngine? engine;

  int? remoteUid;
  DateTime? callStartTime;

  bool localUserJoined = false;
  bool isMuted = false;
  bool isSpeakerOn = true;
  bool isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {

    await [
      Permission.camera,
      Permission.microphone,
    ].request();

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
            localUserJoined = true;
          });
          callStartTime = DateTime.now();
        },

        onUserJoined:
            (connection, uid, elapsed) {

          setState(() {
            remoteUid = uid;
          });

        },

        onUserOffline:
            (connection, uid, reason) {

          setState(() {
            remoteUid = null;
          });

        },

      ),
    );

    await engine!.enableVideo();

    await engine!.startPreview();

    await engine!.joinChannel(
      token: "",
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> toggleMute() async {
    isMuted = !isMuted;

    await engine?.muteLocalAudioStream(
      isMuted,
    );

    setState(() {});
  }

  Future<void> switchCamera() async {
    await engine?.switchCamera();

    isFrontCamera = !isFrontCamera;

    setState(() {});
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;

    await engine?.setEnableSpeakerphone(
      isSpeakerOn,
    );

    setState(() {});
  }

  Future<void> endCall() async {

    int duration = 0;

    if (callStartTime != null) {
      duration = DateTime.now()
          .difference(callStartTime!)
          .inSeconds;
    }

    await CallService().endCall(
      callerId: widget.callerId,
      receiverId: widget.receiverId,
      isVideo: widget.isVideo,
      duration: duration,
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

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Video Call"),
      ),

      body: Stack(

        children: [

          Center(

            child: remoteUid != null

                ? AgoraVideoView(

                    controller:
                        VideoViewController.remote(

                      rtcEngine: engine!,

                      canvas: VideoCanvas(
                        uid: remoteUid,
                      ),

                      connection: RtcConnection(
                        channelId:
                            widget.channelName,
                      ),
                    ),
                  )

                : const Center(
                    child: Text(
                      "Waiting for user...",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),

          Positioned(

            right: 16,

            top: 16,

            child: SizedBox(

              width: 120,

              height: 180,

              child: localUserJoined

                  ? AgoraVideoView(

                      controller:
                          VideoViewController(

                        rtcEngine: engine!,

                        canvas:
                            const VideoCanvas(
                          uid: 0,
                        ),
                      ),
                    )

                  : const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 35,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [

                  CircleAvatar(
                    radius: 28,
                    child: IconButton(
                      icon: Icon(
                        isMuted
                            ? Icons.mic_off
                            : Icons.mic,
                      ),
                      onPressed: toggleMute,
                    ),
                  ),

                  CircleAvatar(
                    radius: 32,
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
                    radius: 28,
                    child: IconButton(
                      icon: const Icon(
                        Icons.cameraswitch,
                      ),
                      onPressed: switchCamera,
                    ),
                  ),

                  CircleAvatar(
                    radius: 28,
                    child: IconButton(
                      icon: Icon(
                        isSpeakerOn
                            ? Icons.volume_up
                            : Icons.volume_off,
                      ),
                      onPressed: toggleSpeaker,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}