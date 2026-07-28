import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';

class ReplyPreview extends StatelessWidget {
  final MessageModel message;
  final UserModel receiver;
  final String currentUserId;
  final VoidCallback onCancel;

  const ReplyPreview({
    super.key,
    required this.message,
    required this.receiver,
    required this.currentUserId,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.reply,
            color: Colors.green,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  message.senderId == currentUserId
                      ? "Replying to yourself"
                      : "Replying to ${receiver.name}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  message.messageType == "image"
                      ? "📷 Photo"
                      : message.messageType == "video"
                          ? "🎥 Video"
                          : message.messageType == "audio"
                              ? "🎤 Voice Message"
                              : message.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}