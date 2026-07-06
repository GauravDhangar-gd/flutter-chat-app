import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessage extends StatefulWidget {
  final String audioUrl;

  const AudioMessage({
    super.key,
    required this.audioUrl,
  });

  @override
  State<AudioMessage> createState() =>
      _AudioMessageState();
}

class _AudioMessageState
    extends State<AudioMessage> {
  final AudioPlayer player = AudioPlayer();

  bool playing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            playing
                ? Icons.pause
                : Icons.play_arrow,
          ),
          onPressed: () async {
            if (playing) {
              await player.pause();
            } else {
              await player.setUrl(widget.audioUrl);
              await player.play();
            }

            setState(() {
              playing = !playing;
            });
          },
        ),
        const Text("Voice Message"),
      ],
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}