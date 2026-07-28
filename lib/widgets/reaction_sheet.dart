import 'package:flutter/material.dart';

import '../models/message_model.dart';

class ReactionSheet {
  static Future<String?> show(
    BuildContext context,
    MessageModel message,
    String currentUserId,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _emoji("❤️"),
                    _emoji("😂"),
                    _emoji("👍"),
                    _emoji("😮"),
                    _emoji("😢"),
                  ],
                ),
              ),

              const Divider(height: 1),

              _tile(
                context,
                icon: Icons.reply,
                title: "Reply",
                value: "reply",
              ),

              _tile(
                context,
                icon: Icons.forward,
                title: "Forward",
                value: "forward",
              ),

              _tile(
                context,
                icon: Icons.delete_outline,
                title: "Delete for Me",
                value: "delete_me",
              ),

              if (message.senderId == currentUserId)
                _tile(
                  context,
                  icon: Icons.delete,
                  iconColor: Colors.red,
                  title: "Delete for Everyone",
                  value: "delete_everyone",
                ),

              const Divider(height: 1),

              _tile(
                context,
                icon: Icons.close,
                title: "Cancel",
                value: "cancel",
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _emoji(String emoji) {
    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.pop(context, emoji);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        );
      },
    );
  }

  static Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context, value);
      },
    );
  }
}