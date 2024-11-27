import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CustomerChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String customerId;
  final String providerId;
  final bool isFakeData;

  const CustomerChatScreen({
    super.key,
    required this.chatRoomId,
    required this.customerId,
    required this.providerId,
    this.isFakeData = false,
  });

  @override
  _CustomerChatScreenState createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final List<types.Message> _messages = [];
  late types.User _currentUser;
  String _chatPartnerName = 'Chat Partner'; // Default text
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _currentUser = types.User(
        id: currentUser.uid,
        firstName: currentUser.displayName ?? 'User',
      );
      _createChatRoomIfNeeded();
      _loadChatPartnerInfo(); // Load chat partner's name
      _loadMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is signed in!')),
      );
    }
  }

  Future<void> _loadChatPartnerInfo() async {
    try {
      String chatPartnerId = _currentUser.id == widget.customerId
          ? widget.providerId
          : widget.customerId;
      DocumentSnapshot partnerSnapshot =
          await _firestore.collection('users').doc(chatPartnerId).get();
      if (partnerSnapshot.exists) {
        setState(() {
          Map<String, dynamic> data =
              partnerSnapshot.data() as Map<String, dynamic>;
          _chatPartnerName =
              '${data['name'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        });
      }
    } catch (e) {
      print('Error loading chat partner info: $e');
    }
  }

  Future<void> _createChatRoomIfNeeded() async {
    final chatRoomRef = _firestore.collection('chats').doc(widget.chatRoomId);
    final chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      await chatRoomRef.set({
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'customerId': widget.customerId,
        'providerId': widget.providerId,
      });
    }
  }

  void _loadMessages() {
    _firestore
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return types.TextMessage(
          author: types.User(id: data['authorId']),
          createdAt: data['createdAt'],
          id: data['id'],
          text: data['text'],
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
    });
  }

  void _handleSendPressed(String messageText) {
    if (messageText.isEmpty) return;

    final textMessage = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: messageText,
    );

    _firestore
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .doc(textMessage.id)
        .set({
      'authorId': _currentUser.id,
      'createdAt': textMessage.createdAt,
      'id': textMessage.id,
      'text': textMessage.text,
    });

    setState(() {
      _messages.insert(0, textMessage);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: customAppBar(context)),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildChatMessages()),
            _buildMessageInputField(),
          ],
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 25, bottom: 5),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomImage(
                        url: null,
                        path: KImages.pp,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _chatPartnerName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index] as types.TextMessage;

        bool showDateHeader = false;
        if (index == _messages.length - 1 ||
            !_isSameDay(
                DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
                DateTime.fromMillisecondsSinceEpoch(
                    _messages[index + 1].createdAt!))) {
          showDateHeader = true;
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: message.author.id == _currentUser.id
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (showDateHeader) _buildDateHeader(message.createdAt!),
            _buildChatBubble(message),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(int createdAt) {
    final messageDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final today = DateTime.now();

    String formattedDate;
    if (_isSameDay(messageDate, today)) {
      formattedDate = 'Today';
    } else {
      formattedDate = DateFormat('MMMM dd, yyyy').format(messageDate);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        formattedDate,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildChatBubble(types.TextMessage message) {
    bool isMe = message.author.id == _currentUser.id;
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: const Offset(0, 0),
              )
            ],
            color: isMe ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.only(
                bottomLeft:
                    isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight:
                    isMe ? const Radius.circular(0) : const Radius.circular(12),
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12)),
          ),
          child: Text(
            message.text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        message.createdAt != null
            ? Text(
                DateFormat('hh:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(message.createdAt!)),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : const Text('Hora desconocida'),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                _handleSendPressed(_messageController.text.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}
