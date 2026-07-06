import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String getChatRoomId(
      String user1,
      String user2,
      ) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage(
    String receiverId,
    String message, {
    String replyMessage = "",
    String replySender = "",
    bool isReply = false,
  }) async {
    final currentUser = _auth.currentUser!;

    String roomId = getChatRoomId(
      currentUser.uid,
      receiverId,
    );

    MessageModel newMessage = MessageModel(
      senderId: currentUser.uid,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      status: "sent",

      messageType: "text",
      imageUrl: "",
      isSeen: false,
      isDelivered: true,

      // Reply fields
      replyMessage: replyMessage,
      replySender: replySender,
      isReply: isReply,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .add(newMessage.toMap());

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .set({
      "users": [
        currentUser.uid,
        receiverId,
      ],
      "lastMessage": message,
      "lastMessageTime":
          DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Future<void> sendImage(
    String receiverId,
    String imageUrl, {
    String replyMessage = "",
    String replySender = "",
    bool isReply = false,
  }) async {
    final currentUser = _auth.currentUser!;

    String roomId = getChatRoomId(
      currentUser.uid,
      receiverId,
    );

    MessageModel newMessage = MessageModel(
      senderId: currentUser.uid,
      receiverId: receiverId,
      message: "",
      timestamp: DateTime.now(),

      messageType: "image",
      imageUrl: imageUrl,

      status: "sent",
      isDelivered: true,

      replyMessage: replyMessage,
      replySender: replySender,
      isReply: isReply,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .add(newMessage.toMap());

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .set({
      "users": [
        currentUser.uid,
        receiverId,
      ],
      "lastMessage": "📷 Photo",
      "lastMessageTime":
          DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }
  Future<void> sendVoiceMessage(
    String receiverId,
    String audioUrl,
  ) async {
    final currentUser = _auth.currentUser!;

    String roomId = getChatRoomId(
      currentUser.uid,
      receiverId,
    );

    MessageModel newMessage = MessageModel(
      senderId: currentUser.uid,
      receiverId: receiverId,
      message: "",
      timestamp: DateTime.now(),
      status: "sent",

      messageType: "audio",
      imageUrl: "",
      audioUrl: audioUrl,

      isSeen: false,
      isDelivered: true,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .add(newMessage.toMap());

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .set({
      "users": [
        currentUser.uid,
        receiverId,
      ],
      "lastMessage": "🎤 Voice message",
      "lastMessageTime":
          DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> forwardMessage(
    String receiverId,
    MessageModel message,
  ) async {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      receiverId,
    );

    final forwardedMessage = MessageModel(
      senderId: currentUser.uid,
      receiverId: receiverId,

      message: message.message,
      timestamp: DateTime.now(),

      status: "sent",

      messageType: message.messageType,

      imageUrl: message.imageUrl,

      audioUrl: message.audioUrl,

      audioDuration: message.audioDuration,

      isDelivered: true,

      isSeen: false,

      isForwarded: true,

      forwardedFrom: message.senderId,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .add(forwardedMessage.toMap());

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .set({
      "users": [
        currentUser.uid,
        receiverId,
      ],
      "lastMessage":
          message.messageType == "image"
              ? "📷 Photo"
              : message.messageType == "audio"
                  ? "🎤 Voice message"
                  : message.message,
      "lastMessageTime":
          DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> setTypingStatus(
    String receiverId,
    bool isTyping,
  ) async {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      receiverId,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .set({
          "typing": {
            currentUser.uid: isTyping,
          }
        }, SetOptions(merge: true));
  }

  Stream<List<MessageModel>> getMessages(
    String otherUserId,
  ) {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    return _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .orderBy("timestamp")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .where(
                (message) => !message.deletedFor.contains(
                  currentUser.uid,
                ),
              )
              .toList(),
        );
  }

  Stream<QuerySnapshot> getChatRooms() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection("chat_rooms")
        .where(
      "users",
      arrayContains: uid,
    )
        .orderBy(
      "lastMessageTime",
      descending: true,
    )
        .snapshots();
  }

  Stream<DocumentSnapshot> getChatRoom(
      String otherUserId,
      ) {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    return _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .snapshots();
  }
  Stream<bool> getTypingStatus(
    String otherUserId,
  ) {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    return _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;

          final data = doc.data();

          if (data == null) return false;

          if (!data.containsKey("typing")) {
            return false;
          }

          final typing =
              Map<String, dynamic>.from(
            data["typing"],
          );

          return typing[otherUserId] ?? false;
        });
  }

  Future<void> markMessagesAsRead(
      String otherUserId,
      ) async {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    final snapshot = await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .where(
      "receiverId",
      isEqualTo: currentUser.uid,
    )
        .where(
      "status",
      whereIn: [
        "sent",
        "delivered",
      ],
    )
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({
        "status": "read",
      });
    }
  }
  Future<void> deleteForMe(
    String otherUserId,
    String messageId,
  ) async {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({
      "deletedFor": FieldValue.arrayUnion([
        currentUser.uid,
      ]),
    });
  }

  Future<void> deleteForEveryone(
    String otherUserId,
    String messageId,
  ) async {
    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({
      "deletedForEveryone": true,
      "message": "This message was deleted",
      "imageUrl": "",
      "messageType": "text",
    });
  }

  Future<void> reactToMessage(
    String otherUserId,
    String messageId,
    String reaction,
  ) async {

    final currentUser = _auth.currentUser!;

    final roomId = getChatRoomId(
      currentUser.uid,
      otherUserId,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({
          "reaction": reaction,
        });
  }

Stream<List<MessageModel>> searchMessages(
  String otherUserId,
  String query,
) {
  final currentUser = _auth.currentUser!;

  final roomId = getChatRoomId(
    currentUser.uid,
    otherUserId,
  );

  return _firestore
      .collection("chat_rooms")
      .doc(roomId)
      .collection("messages")
      .orderBy("timestamp")
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => MessageModel.fromMap(
                doc.data(),
                doc.id,
              ),
            )
            .where(
              (message) => message.message
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .toList();
      });
}

  Future<void> updateMessageStatus(
      String otherUserId,
      String messageId,
      String status,
      ) async {
    final roomId = getChatRoomId(
      _auth.currentUser!.uid,
      otherUserId,
    );

    await _firestore
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({
      "status": status,
    });
  }
}