class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isOnline;
  final String photoUrl;
  final DateTime? lastSeen;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isOnline,
    required this.photoUrl,
    this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "isOnline": isOnline,
      "photoUrl": photoUrl,
      "lastSeen": lastSeen?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      isOnline: map["isOnline"] ?? false,
      photoUrl: map["photoUrl"] ?? "",
      lastSeen: map["lastSeen"] != null
      ? DateTime.fromMillisecondsSinceEpoch(
          map["lastSeen"],
        )
      : null,
    );
  }
}