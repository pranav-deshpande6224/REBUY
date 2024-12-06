const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.myFunction = functions.firestore.onDocumentCreated("users/{recipientUid}/chats/{chatId}/messages/{messageId}",async (event) => {
    const messageData = event.data; // New message data
    console.log("Message data:", messageData);
    const { recipientUid, chatId } = event.params;
    const [senderUid] = chatId.split("_");
    console.log("Recipient UID:", recipientUid);
    console.log("Sender UID:", senderUid);
    try {
        const recipientDoc = await admin.firestore().collection("users").doc(recipientUid).get();
        if (!recipientDoc.exists) {
            console.error(`Recipient user (${recipientUid}) does not exist.`);
            return;
        }
      const recipientData = recipientDoc.data();
      const recipientFcmToken = recipientData.fcmToken;
      console.log("Recipient FCM token:", recipientFcmToken);
      if(recipientFcmToken == ''){
        return;
      }
      const senderDoc = await admin.firestore().collection("users").doc(senderUid).get();
      if (!senderDoc.exists) {
        console.error(`Sender user (${senderUid}) does not exist.`);
        return;
      }
      const senderData = senderDoc.data();
      const senderName = senderData.firstName;
      const message = {
        token: recipientFcmToken,
        notification: {
          title: `Message from ${senderName}`,
          body: messageData.text || "You have a new message.",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          senderUid: senderUid,
          recipientUid: recipientUid,
          messageId: event.params.messageId,
        },
      };
      // Send the message
      const response = await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);
    }catch (error) {
      console.error("Error sending notification:", error);
    }
});
