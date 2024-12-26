import 'dart:async';

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
  final String orderId; // Nuevo campo
  final bool isFakeData;

  const CustomerChatScreen({
    super.key,
    required this.chatRoomId,
    required this.customerId,
    required this.providerId,
    required this.orderId, // Incluir en el constructor
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
  String? _orderStatus; // Variable para almacenar el estado del pedido
  bool _isChatBlocked = false; // Indica si el chat está bloqueado

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _checkOrderStatus(); // Verificar el estado del pedido
    _setUserOnlineStatus(true); // Marca como online al entrar

    // Listener para desconexión
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _setUserOnlineStatus(false); // Marca como offline al salir
      }
    });
  }

  Future<void> _checkOrderStatus() async {
    try {
      final orderSnapshot = await _firestore
          .collection('bookings') // Ajusta a tu colección de bookings
          .doc(widget.orderId)
          .get();

      if (orderSnapshot.exists) {
        setState(() {
          _orderStatus = orderSnapshot.data()?['status']?.toLowerCase();
          _isChatBlocked = _orderStatus == "pending" ||
              _orderStatus == "completed" ||
              _orderStatus == "cancelled";
        });
      }
    } catch (e) {
      print('Error fetching order status: $e');
    }
  }

  bool _containsNumbers(String message) {
    final numberRegex = RegExp(r'\d');
    return numberRegex.hasMatch(message);
  }

  Map<String, dynamic>? _chatPartnerData;

  Future<void> runTransactionWithRetry(
    Future<void> Function(Transaction transaction) operation, {
    int retries = 3,
  }) async {
    for (int i = 0; i < retries; i++) {
      try {
        await FirebaseFirestore.instance.runTransaction(operation);
        return;
      } catch (e) {
        if (i == retries - 1) {
          print('Transaction failed after $retries attempts: $e');
          rethrow; // Re-throw the exception after the final attempt
        }
      }
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

  void _setUserOnlineStatus(bool isOnline) async {
    try {
      final userId = _currentUser.id;
      final chatRoomRef = _firestore.collection('chats').doc(widget.chatRoomId);

      await runTransactionWithRetry((transaction) async {
        final chatRoomSnapshot = await transaction.get(chatRoomRef);

        if (!chatRoomSnapshot.exists) return;

        final currentOnlineUsers =
            List<String>.from(chatRoomSnapshot['onlineUsers'] ?? []);
        final updatedOnlineUsers = isOnline
            ? (currentOnlineUsers..add(userId)).toSet().toList()
            : (currentOnlineUsers..remove(userId));

        transaction.update(chatRoomRef, {'onlineUsers': updatedOnlineUsers});
      });
    } catch (e) {
      print('Error updating user online status: $e');
    }
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

  Future<void> _createChatRoomIfNeeded() async {
    final chatRoomRef = _firestore.collection('chats').doc(widget.chatRoomId);
    final chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      await chatRoomRef.set({
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'customerId': widget.customerId,
        'providerId': widget.providerId,
        'orderId': widget.orderId, // Agregar el orderId
        'unreadCounts': {}, // Inicializar los contadores de no leídos
        'onlineUsers': [], // Inicializar lista de usuarios en línea
      });
    } else {
      // Verificar y agregar el orderId si falta
      final chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>;
      if (!chatRoomData.containsKey('orderId')) {
        await chatRoomRef.update({'orderId': widget.orderId});
      }
    }
  }

  StreamSubscription?
      _messagesSubscription; // Controlador para escuchar mensajes.

  void _loadMessages() {
    _messagesSubscription = _firestore
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
      try {
        // Map Firestore messages to TextMessage objects
        final loadedMessages = snapshot.docs.map((doc) {
          final data = doc.data();

          return types.TextMessage(
            author: types.User(id: data['authorId']),
            createdAt: data['createdAt'],
            id: data['id'],
            text: data['text'],
            metadata: {
              'read': data['read'] ?? false, // Default to false if null
            },
          );
        }).toList();

        // Update messages in the UI
        setState(() {
          _messages
            ..clear()
            ..addAll(loadedMessages)
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        });

        // Mark messages as read (if both users are online)
        final chatRoomSnapshot =
            await _firestore.collection('chats').doc(widget.chatRoomId).get();
        final currentOnlineUsers =
            List<String>.from(chatRoomSnapshot['onlineUsers'] ?? []);
        final bothUsersOnline =
            currentOnlineUsers.contains(widget.customerId) &&
                currentOnlineUsers.contains(widget.providerId);

        if (bothUsersOnline) {
          final batch = _firestore.batch();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if ((data['read'] ?? false) == false &&
                data['receiverId'] == _currentUser.id) {
              batch.update(doc.reference, {'read': true});
            }
          }
          await batch.commit();
        }
      } catch (e) {
        print('Error loading messages: $e');
      }
    });
  }

  @override
  void dispose() {
    // Cancela la suscripción para evitar fugas de memoria.
    _messagesSubscription?.cancel();
    _setUserOnlineStatus(false); // Marca como offline al salir.
    super.dispose();
  }

  bool _isSending = false;
  void _handleSendPressed(String messageText) async {
    if (_isChatBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is blocked due to order status.')),
      );
      return;
    }
    if (messageText.isEmpty || _isSending) return;

    if (_containsNumbers(messageText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Messages cannot contain numbers.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final textMessage = types.TextMessage(
        author: _currentUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: messageText,
      );

      final receiverId = _currentUser.id == widget.customerId
          ? widget.providerId
          : widget.customerId;

      final chatRoomRef = _firestore.collection('chats').doc(widget.chatRoomId);

      await runTransactionWithRetry((transaction) async {
        final chatRoomSnapshot = await transaction.get(chatRoomRef);

        if (!chatRoomSnapshot.exists) return;

        final currentOnlineUsers =
            List<String>.from(chatRoomSnapshot['onlineUsers'] ?? []);
        final unreadCounts = Map<String, dynamic>.from(
          chatRoomSnapshot.data()?['unreadCounts'] ?? {},
        );

        // Increment unread count if the receiver is offline
        if (!currentOnlineUsers.contains(receiverId)) {
          unreadCounts[receiverId] = (unreadCounts[receiverId] ?? 0) + 1;
        }

        transaction.set(
          chatRoomRef.collection('messages').doc(textMessage.id),
          {
            'authorId': _currentUser.id,
            'createdAt': textMessage.createdAt,
            'id': textMessage.id,
            'text': textMessage.text,
            'read': currentOnlineUsers.contains(receiverId),
            'receiverId': receiverId,
            'orderId': widget.orderId, // Incluir orderId en el mensaje
          },
        );

        transaction.update(chatRoomRef, {'unreadCounts': unreadCounts});
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
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
    final otherUserId = _currentUser.id == widget.customerId
        ? widget.providerId
        : widget.customerId;

    return Container(
      padding: const EdgeInsets.only(top: 35, bottom: 5),
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('users').doc(otherUserId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.error, color: Colors.white),
                      );
                    }

                    final userData =
                        snapshot.data?.data() as Map<String, dynamic>? ?? {};
                    final profileImageUrl =
                        userData['profileImageUrl'] ?? KImages.pp;

                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: CustomImage(
                          path: profileImageUrl,
                          fit: BoxFit.cover,
                          url: null,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(widget.chatRoomId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.hasError) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _chatPartnerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      );
                    }

                    final chatData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final onlineUsers =
                        List<String>.from(chatData['onlineUsers'] ?? []);
                    final chatPartnerId = _currentUser.id == widget.customerId
                        ? widget.providerId
                        : widget.customerId;

                    final isOnline = onlineUsers.contains(chatPartnerId);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _chatPartnerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black, size: 25),
              position: PopupMenuPosition.under, // Coloca el menú hacia abajo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Esquinas redondeadas
              ),
              color: Colors.white,
              elevation: 4,
              onSelected: (value) {
                if (value == 'order') {
                  _showOrderNumber(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'order',
                  child: Row(
                    children: const [
                      Icon(Icons.receipt_long, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'View Order Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderNumber(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Order Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Order ID: ${widget.orderId}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF404C8C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatMessages() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: ListView.builder(
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
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _isChatBlocked
          ? Container(
              decoration: BoxDecoration(
                color: Colors.red[50], // Fondo suave para el estado bloqueado
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 1.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock,
                    color: Colors.red,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chat is currently blocked due to the order status: $_orderStatus.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _handleSendPressed(_messageController.text.trim());
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 25,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
