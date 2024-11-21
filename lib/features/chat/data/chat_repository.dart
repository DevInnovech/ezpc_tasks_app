// lib/features/chat/data/repositories/chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateChatRoomId(String user1, String user2) {
    return user1.compareTo(user2) > 0 ? '$user1\_$user2' : '$user2\_$user1';
  }

  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
