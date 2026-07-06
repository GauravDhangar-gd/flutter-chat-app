import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/call_model.dart';
import '../services/call_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallsScreen extends StatelessWidget {
  CallsScreen({super.key});

  final CallService callService = CallService();
  final FirestoreService firestoreService =
    FirestoreService();

  final currentUser =
    FirebaseAuth.instance.currentUser!;

  String formatDuration(int seconds) {
    if (seconds == 0) return "0 sec";

    final minutes = seconds ~/ 60;
    final remain = seconds % 60;

    if (minutes == 0) {
      return "$remain sec";
    }

    return "$minutes min ${remain}s";
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Calls"),
    ),
    body: StreamBuilder<List<CallModel>>(
      stream: callService.getCallHistory(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final calls = snapshot.data!;

        if (calls.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text("No call history"),
            ),
          );
        }

        String getHeader(DateTime date) {

          final now = DateTime.now();

          final today = DateTime(
            now.year,
            now.month,
            now.day,
          );

          final yesterday = today.subtract(
            const Duration(days: 1),
          );

          final messageDate = DateTime(
            date.year,
            date.month,
            date.day,
          );

          if (messageDate == today) {
            return "Today";
          }

          if (messageDate == yesterday) {
            return "Yesterday";
          }

          return DateFormat(
            "dd MMM yyyy",
          ).format(date);
        }

        return ListView.builder(
          itemCount: calls.length,
          itemBuilder: (context, index) {

            final call = calls[index];
            final otherUserId =
                call.callerId == currentUser.uid
                    ? call.receiverId
                    : call.callerId;
            final currentHeader =
                getHeader(call.timestamp);

            String? previousHeader;

            if (index > 0) {
              previousHeader = getHeader(
                calls[index - 1].timestamp,
              );
            }

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                if (index == 0 ||
                    currentHeader != previousHeader)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      8,
                    ),
                    child: Text(
                      currentHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

            StreamBuilder<UserModel>(

              stream: firestoreService.getUser(
                otherUserId,
              ),
              builder: (context, userSnapshot) {

                if (!userSnapshot.hasData) {
                  return const SizedBox();
                }

                final user = userSnapshot.data!;

                return ListTile(

                  leading: CircleAvatar(
                    backgroundImage:
                        user.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                    child: user.photoUrl.isEmpty
                        ? Text(
                            user.name[0].toUpperCase(),
                          )
                        : null,
                  ),

                  title: Text(user.name),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [

                          Icon(
                            call.isMissed
                                ? Icons.call_missed
                                : call.callerId == currentUser.uid
                                    ? Icons.call_made
                                    : Icons.call_received,
                            size: 18,
                            color: call.isMissed
                                ? Colors.red
                                : Colors.green,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              call.isMissed
                                  ? "Missed Call"
                                  : formatDuration(call.duration),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        DateFormat(
                          "dd MMM • hh:mm a",
                        ).format(call.timestamp),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: Icon(
                      call.isVideo
                          ? Icons.videocam
                          : Icons.call,
                      color: Colors.green,
                    ),
                    onPressed: () {

                      // We'll reopen the
                      // Voice/Video Call screen
                      // in the next phase.

                    },
                  ),
                );
              },
            ),
            ],
            );
          },
        );
      },
    ),
    );
  }
}