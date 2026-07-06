import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_model.dart';

class CallService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> startCall({
    required String callerId,
    required String receiverId,
    required String channelName,
    required bool isVideo,
  }) async {
    await _firestore
        .collection("calls")
        .doc(receiverId)
        .set({
      "callerId": callerId,
      "receiverId": receiverId,
      "channelName": channelName,
      "isVideo": isVideo,
      "callType": isVideo ? "video" : "voice",
      "status": "calling",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveCallHistory({
    required String callerId,
    required String receiverId,
    required bool isVideo,
    required int duration,
    bool isMissed = false,
  }) async {

    final call = CallModel(
      callerId: callerId,
      receiverId: receiverId,
      isVideo: isVideo,
      duration: duration,
      isMissed: isMissed,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection("call_history")
        .add(call.toMap());
  }

  Future<void> endCall({
    required String callerId,
    required String receiverId,
    required bool isVideo,
    int duration = 0,
    bool isMissed = false,
  }) async {

    await saveCallHistory(
      callerId: callerId,
      receiverId: receiverId,
      isVideo: isVideo,
      duration: duration,
      isMissed: isMissed,
    );

    await _firestore
        .collection("calls")
        .doc(receiverId)
        .delete();
  }

  Stream<List<CallModel>> getCallHistory() {
    return _firestore
        .collection("call_history")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CallModel.fromMap(
              doc.data(),
              doc.id,
            );
          }).toList();
        });
  }
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCall(
    String receiverId,
  ) {
    return _firestore
        .collection("calls")
        .doc(receiverId)
        .snapshots();
  }
  Stream<DocumentSnapshot<Map<String, dynamic>>>
      incomingCall(String uid) {
    return _firestore
        .collection("calls")
        .doc(uid)
        .snapshots();
  }
}