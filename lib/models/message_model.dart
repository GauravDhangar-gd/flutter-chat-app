class MessageModel {
  final String id; // Firestore document id

  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  final String messageType;
  final String imageUrl;
  final String audioUrl;
  final int audioDuration;

  final bool isSeen;
  final bool isDelivered;

  final String status;

  final String replyMessage;
  final String replySender;
  final bool isReply;

  final bool deletedForEveryone;

  final List<String> deletedFor;

  final String reaction;
  final bool isForwarded;

  final String forwardedFrom;

  final String videoUrl;


  MessageModel({
    this.id = "",
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.messageType = "text",
    this.imageUrl = "",
    this.isSeen = false,
    this.isDelivered = false,
    this.status = "sent",
    this.replyMessage = "",
    this.replySender = "",
    this.isReply = false,
    this.deletedForEveryone = false,
    this.deletedFor = const [],
    this.reaction = "",
    this.isForwarded = false,
    this.forwardedFrom = "",
    this.audioUrl = "",
    this.audioDuration = 0,
    this.videoUrl = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "timestamp": timestamp.millisecondsSinceEpoch,
      "status": status,
      "messageType": messageType,
      "imageUrl": imageUrl,
      "audioUrl": audioUrl,
      "audioDuration": audioDuration,
      "isSeen": isSeen,
      "isDelivered": isDelivered,
      "replyMessage": replyMessage,
      "replySender": replySender,
      "isReply": isReply,
      "deletedForEveryone": deletedForEveryone,
      "deletedFor": deletedFor,
      "reaction": reaction,
      "isForwarded": isForwarded,
      "forwardedFrom": forwardedFrom,
      "videoUrl": videoUrl,
    };
  }

  factory MessageModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return MessageModel(
      id: id,
      senderId: map["senderId"] ?? "",
      receiverId: map["receiverId"] ?? "",
      message: map["message"] ?? "",
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map["timestamp"] ?? 0,
      ),
      status: map["status"] ?? "sent",
      messageType: map["messageType"] ?? "text",
      imageUrl: map["imageUrl"] ?? "",
      audioUrl: map["audioUrl"] ?? "",
      audioDuration: map["audioDuration"] ?? 0,
      isSeen: map["isSeen"] ?? false,
      isDelivered: map["isDelivered"] ?? false,
      replyMessage: map["replyMessage"] ?? "",
      replySender: map["replySender"] ?? "",
      isReply: map["isReply"] ?? false,
      deletedForEveryone:
          map["deletedForEveryone"] ?? false,

      deletedFor:
          List<String>.from(
            map["deletedFor"] ?? [],
          ),
      reaction: map["reaction"] ?? "",

      isForwarded:
          map["isForwarded"] ?? false,

      forwardedFrom:
          map["forwardedFrom"] ?? "",
      
      videoUrl: map["videoUrl"] ?? "",
    );
  }
}