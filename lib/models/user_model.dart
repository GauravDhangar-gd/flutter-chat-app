class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final bool isOnline;
  final String photoUrl;
  final DateTime? lastSeen;
  final DateTime? createdAt;
  final String fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.isOnline,
    required this.photoUrl,
    this.lastSeen,
    this.createdAt,
    this.fcmToken = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "phoneNumber": phoneNumber,
      "isOnline": isOnline,
      "photoUrl": photoUrl,
      "lastSeen": lastSeen?.millisecondsSinceEpoch,
      "createdAt": createdAt?.millisecondsSinceEpoch,
      "fcmToken": fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      phoneNumber: map["phoneNumber"] ?? "",
      isOnline: map["isOnline"] ?? false,
      photoUrl: map["photoUrl"] ?? "",
      lastSeen: map["lastSeen"] != null
          ? DateTime.fromMillisecondsSinceEpoch(map["lastSeen"])
          : null,
      createdAt: map["createdAt"] != null
          ? DateTime.fromMillisecondsSinceEpoch(map["createdAt"])
          : null,
      fcmToken: map["fcmToken"] ?? "",
    );
  }
}
