import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendMessageNotification = onDocumentCreated(
  "chat_rooms/{roomId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();

    if (!message) return;

    const receiverId = message.receiverId;

    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .get();

    if (!userDoc.exists) return;

    const user = userDoc.data();

    if (!user?.fcmToken) return;

    await admin.messaging().send({
      token: user.fcmToken,

      notification: {
        title: "New Message",
        body:
          message.messageType === "text"
              ? message.message
              : "📎 Sent an attachment",
      },

      data: {
        senderId: message.senderId,
        receiverId: receiverId,
        messageType: message.messageType,
      },
    });
  }
);