import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';

class ForwardScreen extends StatefulWidget {
  final MessageModel message;

  const ForwardScreen({
    super.key,
    required this.message,
  });

  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  final FirestoreService firestoreService =
      FirestoreService();

  final ChatService chatService =
      ChatService();

  UserModel? selectedUser;

  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forward Message"),
      ),

      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getUsers(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!;

          if (users.isEmpty) {
            return const Center(
              child: Text("No users found"),
            );
          }

          return Column(
            children: [

              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {

                    final user = users[index];

                    final selected =
                        selectedUser?.uid == user.uid;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user.photoUrl.isNotEmpty
                                ? NetworkImage(
                                    user.photoUrl,
                                  )
                                : null,
                        child: user.photoUrl.isEmpty
                            ? Text(
                                user.name[0]
                                    .toUpperCase(),
                              )
                            : null,
                      ),

                      title: Text(user.name),

                      trailing: selected
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,

                      onTap: () {
                        setState(() {
                          selectedUser = user;
                        });
                      },
                    );
                  },
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),

                      label: const Text("Forward"),

                      onPressed: selectedUser == null || isSending
                          ? null
                          : () async {

                              setState(() {
                                isSending = true;
                              });

                              await chatService.forwardMessage(
                                selectedUser!.uid,
                                widget.message,
                              );

                              if (mounted) {
                                Navigator.pop(
                                  context,
                                );
                              }
                            },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}