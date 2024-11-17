// lib/features/chat/data/models/chat_model.dart

class ChatMessage {
  final String id;
  final String authorId;
  final String text;
  final int createdAt;

  ChatMessage({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  // Convierte un objeto ChatMessage a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'text': text,
      'createdAt': createdAt,
    };
  }

  // Crea una instancia de ChatMessage a partir de un Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? 0,
    );
  }
}
