import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  String formatLastSeen(DateTime time) {
    final now = DateTime.now();

    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return "Today at ${DateFormat('hh:mm a').format(time)}";
    }

    return DateFormat('dd MMM, hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestore = FirestoreService();
    final ChatService chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),

      body: StreamBuilder<List<UserModel>>(
        stream: firestore.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Users Found"),
            );
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return StreamBuilder<DocumentSnapshot>(
                stream: chatService.getChatRoom(user.uid),
                builder: (context, roomSnapshot) {
                  String subtitle;

                  String time = "";

                  if (roomSnapshot.hasData &&
                      roomSnapshot.data!.exists) {
                    final room =
                        roomSnapshot.data!.data()
                            as Map<String, dynamic>;

                    subtitle =
                        room["lastMessage"] ?? "";

                    if (room["lastMessageTime"] !=
                        null) {
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(
                        room["lastMessageTime"],
                      );

                      time = DateFormat(
                        'hh:mm a',
                      ).format(date);
                    }
                  } else {
                    subtitle = user.isOnline
                        ? "🟢 Online"
                        : user.lastSeen == null
                            ? "Offline"
                            : "Last seen ${formatLastSeen(user.lastSeen!)}";
                  }

                 return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? NetworkImage(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),

                          if (user.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 14,
                                width: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),

                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          if (time.isNotEmpty)
                            Text(
                              time,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatScreen(
                              user: user,
                            ),
                          ),
                        );
                      },
                    ),
                 );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.chat),
      ),
    );
  }
}