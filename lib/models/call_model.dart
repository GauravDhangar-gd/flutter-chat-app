class CallModel {
  final String id;

  final String callerId;
  final String receiverId;

  final bool isVideo;

  final bool isMissed;

  final int duration;

  final DateTime timestamp;

  CallModel({
    this.id = "",
    required this.callerId,
    required this.receiverId,
    required this.isVideo,
    required this.timestamp,
    this.isMissed = false,
    this.duration = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "callerId": callerId,
      "receiverId": receiverId,
      "isVideo": isVideo,
      "isMissed": isMissed,
      "duration": duration,
      "timestamp": timestamp.millisecondsSinceEpoch,
    };
  }

  factory CallModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CallModel(
      id: id,
      callerId: map["callerId"] ?? "",
      receiverId: map["receiverId"] ?? "",
      isVideo: map["isVideo"] ?? false,
      isMissed: map["isMissed"] ?? false,
      duration: map["duration"] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map["timestamp"] ?? 0,
      ),
    );
  }
}