import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

class SearchScreen extends StatefulWidget {
  final UserModel user;

  const SearchScreen({
    super.key,
    required this.user,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ChatService chatService = ChatService();

  final TextEditingController searchController =
      TextEditingController();

  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search messages...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              query = value.trim();
            });
          },
        ),
      ),

      body: query.isEmpty
          ? const Center(
              child: Text(
                "Start typing to search",
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<List<MessageModel>>(
              stream: chatService.searchMessages(
                widget.user.uid,
                query,
              ),
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
                    child: Text("No matching messages"),
                  );
                }

                final messages = snapshot.data!;

                return ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          message.senderId == widget.user.uid
                              ? Icons.person
                              : Icons.person_outline,
                        ),
                      ),

                      title: Text(
                        message.messageType == "image"
                            ? "📷 Photo"
                            : message.messageType == "audio"
                                ? "🎤 Voice Message"
                                : message.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      subtitle: Text(
                        DateFormat(
                          "dd MMM yyyy, hh:mm a",
                        ).format(
                          message.timestamp,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),

                      onTap: () {
                        Navigator.pop(
                          context,
                          message,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}