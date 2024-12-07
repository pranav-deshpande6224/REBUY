const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.myFunction = functions.firestore.onDocumentCreated("users/{recipientUid}/chats/{chatId}/messages/{messageId}",async (event) => {
    const messageData = event.data;
    const snapshot = messageData.data();
    const textMessage = snapshot['text'];
    const { recipientUid, chatId } = event.params;
    const [senderUid] = chatId.split("_");
    try {
        const recipientDoc = await admin.firestore().collection("users").doc(recipientUid).get();
        if (!recipientDoc.exists) {
            console.error(`Recipient user (${recipientUid}) does not exist.`);
            return;
        }
      const recipientData = recipientDoc.data();
      const recipientFcmToken = recipientData.fcmToken;
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
          body: textMessage,
        },
        data: {
          senderUid: senderUid,
          recipientUid: recipientUid,
          messageId: event.params.messageId,
          "navigate_to": 'chats',
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "sound": "default", 
        },
        android: {
          priority: "high",
        }
      };
      const response = await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);
    }catch (error) {
      console.error("Error sending notification:", error);
    }
});
