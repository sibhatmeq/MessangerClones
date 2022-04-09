import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future addUserInfoToDB(String userId, Map<String, dynamic>userInfoMap){
    return FirebaseFirestore.instance.collection('users').doc(userId).set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username)async{
    return FirebaseFirestore.instance.collection("users").where("username", isEqualTo: username).snapshots();
  }
   
  Future addMessage(String chatRoomId, String messageId, Map<String, dynamic> messageInfoMap){
    return FirebaseFirestore.instance
        .collection("charooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId, Map<String, dynamic> lastMessageInfoMap){
   return FirebaseFirestore.instance
       .collection("chatrooms")
       .doc(chatRoomId)
       .update(lastMessageInfoMap);
  }
  createChatRoom(String chatRoomId,Map<String, dynamic> chatRoomInfoMap)async{
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if(snapshot.exists){
      return true;
    }
    else{
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId).set(chatRoomInfoMap);
    }
  }
   Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts")
        .snapshots();
  }
}
