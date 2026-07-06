import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMessage extends StatefulWidget {
  final String videoUrl;

  const VideoMessage({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoMessage> createState() =>
      _VideoMessageState();
}

class _VideoMessageState
    extends State<VideoMessage> {

  late VideoPlayerController controller;

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          initialized = true;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void playPause() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Container(
        width: 220,
        height: 220,
        alignment: Alignment.center,
        child:
            const CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: playPause,
      child: Stack(
        alignment: Alignment.center,
        children: [

          ClipRRect(
            borderRadius:
                BorderRadius.circular(12),
            child: SizedBox(
              width: 220,
              child: AspectRatio(
                aspectRatio:
                    controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
          ),

          if (!controller.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding:
                  const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 42,
              ),
            ),
        ],
      ),
    );
  }
}