import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;
  final String currentUserId;

  final FirestoreService firestoreService;
  final ChatService chatService;

  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;
  final VoidCallback onSearch;
  final VoidCallback onChangeWallpaper;
  final VoidCallback onRemoveWallpaper;

  const ChatAppBar({
    super.key,
    required this.user,
    required this.currentUserId,
    required this.firestoreService,
    required this.chatService,
    required this.onVoiceCall,
    required this.onVideoCall,
    required this.onSearch,
    required this.onChangeWallpaper,
    required this.onRemoveWallpaper,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      elevation: 1,

      title: StreamBuilder<UserModel>(
        stream: firestoreService.getUser(user.uid),
        builder: (context, snapshot) {
          final chatUser = snapshot.data ?? user;

          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: chatUser.photoUrl.isNotEmpty
                    ? NetworkImage(chatUser.photoUrl)
                    : null,
                child: chatUser.photoUrl.isEmpty
                    ? Text(chatUser.name[0].toUpperCase())
                    : null,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      chatUser.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    StreamBuilder<bool>(
                      stream: chatService.getTypingStatus(chatUser.uid),
                      builder: (context, typingSnapshot) {

                        final typing =
                            typingSnapshot.data ?? false;

                        String status;

                        if (typing) {
                          status = "Typing...";
                        } else if (chatUser.isOnline) {
                          status = "🟢 Online";
                        } else if (chatUser.lastSeen == null) {
                          status = "Offline";
                        } else {
                          status =
                              "Last seen ${DateFormat('dd MMM, hh:mm a').format(chatUser.lastSeen!)}";
                        }

                        return Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      actions: [

        IconButton(
          icon: const Icon(Icons.call),
          onPressed: onVoiceCall,
        ),

        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: onVideoCall,
        ),

        PopupMenuButton<String>(
          onSelected: (value) {

            switch (value) {

              case "search":
                onSearch();
                break;

              case "wallpaper":
                onChangeWallpaper();
                break;

              case "remove_wallpaper":
                onRemoveWallpaper();
                break;
            }
          },

          itemBuilder: (_) => const [

            PopupMenuItem(
              value: "search",
              child: Text("Search"),
            ),

            PopupMenuItem(
              value: "wallpaper",
              child: Text("Change Wallpaper"),
            ),

            PopupMenuItem(
              value: "remove_wallpaper",
              child: Text("Remove Wallpaper"),
            ),
          ],
        ),
      ],
    );
  }
}