import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  final bool showEmoji;
  final bool isRecording;

  final VoidCallback onEmojiPressed;
  final VoidCallback onVideo;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onSend;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  final ValueChanged<String> onTyping;

  const MessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showEmoji,
    required this.isRecording,
    required this.onEmojiPressed,
    required this.onVideo,
    required this.onGallery,
    required this.onCamera,
    required this.onSend,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: onEmojiPressed,
                ),

                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: onVideo,
                ),

                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: onGallery,
                ),

                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: onCamera,
                ),

                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onTyping,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  radius: 28,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      if (value.text.trim().isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: onSend,
                        );
                      }

                      return GestureDetector(
                        onLongPressStart: (_) => onStartRecording(),
                        onLongPressEnd: (_) => onStopRecording(),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            isRecording
                                ? Icons.mic
                                : Icons.mic_none,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        if (showEmoji)
          SizedBox(
            height: 280,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                controller.text += emoji.emoji;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              },
              config: const Config(
                height: 280,
                checkPlatformCompatibility: true,
              ),
            ),
          ),
      ],
    );
  }
}