import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import 'audio_message.dart';
import 'image_message.dart';
import 'video_message.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isHighlighted;
  final VoidCallback onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isHighlighted,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment:
            isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Colors.amber.shade200
                : isMe
                    ? const Color(0xffDCF8C6)
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  Radius.circular(isMe ? 18 : 4),
              bottomRight:
                  Radius.circular(isMe ? 4 : 18),
            ),
    
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isForwarded) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forward,
                      size: 14,
                      color: isMe
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Forwarded",
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isMe
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              _buildMessageContent(),

              const SizedBox(height: 6),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (message.deletedForEveryone) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.block,
            size: 18,
            color: Colors.grey,
          ),
          SizedBox(width: 6),
          Text(
            "This message was deleted",
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ---------- Reply Preview ----------
        if (message.isReply) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white24
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(
                  color: isMe
                      ? Colors.white
                      : Colors.green,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  message.replySender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe
                        ? Colors.white
                        : Colors.green,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message.replyMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],

        _actualMessage(),
      ],
    );
  }
  Widget _actualMessage() {

    switch (message.messageType) {

      case "image":
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ImageMessage(
            imageUrl: message.imageUrl,
          ),
        );
         
      case "audio":
        return AudioMessage(
          audioUrl: message.audioUrl,
        );

      case "video":
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: VideoMessage(
            videoUrl: message.videoUrl,
          ),
        );

      default:
        return Text(
          message.message,
          style: TextStyle(
            color: isMe
                ? Colors.white
                : Colors.black87,
            fontSize: 16,
          ),
        );
    }
  }

  Widget _buildFooter() {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [

        if (message.reaction.isNotEmpty)

          Container(
            margin:
                const EdgeInsets.only(bottom: 6),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Text(
              message.reaction,
              style:
                  const TextStyle(fontSize: 18),
            ),
          ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              DateFormat('hh:mm a')
                  .format(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: message.messageType ==
                        "image"
                    ? Colors.transparent
                    : isMe
                        ? Colors.white70
                        : Colors.black54,
              ),
            ),

            if (isMe) ...[
              const SizedBox(width: 4),

              Icon(
                message.status == "read"
                    ? Icons.done_all
                    : Icons.done,
                size: 16,
                color:
                    message.status == "read"
                        ? Colors.blue
                        : Colors.white70,
              ),
            ],
          ],
        ),
      ],
    );
  }
}