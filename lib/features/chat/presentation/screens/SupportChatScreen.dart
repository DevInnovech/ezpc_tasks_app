import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SupportChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String userId;

  const SupportChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.userId,
  }) : super(key: key);

  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final List<types.Message> _messages = [];
  late types.User _user;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Si el usuario está autenticado, lo usamos
    if (currentUser != null) {
      _user = types.User(
        id: currentUser.uid,
        firstName: currentUser.displayName ?? 'User',
      );
    }
    // Si no hay usuario autenticado, creamos un usuario ficticio
    else {
      _user = types.User(
        id: 'guest_user', // ID ficticio para el usuario de invitado
        firstName: 'Guest', // Nombre ficticio del usuario
      );
    }

    _loadMessages(); // Cargar mensajes
  }

  void _loadMessages() {
    FirebaseFirestore.instance
        .collection('supportChats')
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
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: messageText,
    );

    FirebaseFirestore.instance
        .collection('supportChats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .doc(textMessage.id)
        .set({
      'authorId': _user.id,
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
          preferredSize: Size.fromHeight(70.0), child: customAppBar(context)),
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
      padding: const EdgeInsets.only(
        top: 25,
        bottom: 5,
      ), // Ajusta el espacio superior e inferior
      color: Colors.transparent, // Fondo transparente
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón de retroceso
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 35, // Tamaño más pequeño del botón
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white, // Fondo blanco
                        shape: BoxShape.circle, // Botón circular
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                          size: 20, // Tamaño pequeño del ícono
                        ),
                      ),
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.transparent, // Fondo transparente
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomImage(
                        path: KImages.pp, // Reemplaza con la ruta de tu imagen
                        fit: BoxFit.cover,
                        //    width: 50,
                        //   height: 50,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10), // Espacio entre el avatar y el texto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Support Agent',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
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
            // Icono de más opciones
            GestureDetector(
              onTap: () {
                // Acción del botón
              },
              child: Container(
                width: 35, // Tamaño más pequeño del botón
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco
                  shape: BoxShape.circle, // Botón circular
                ),
                child: Center(
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 25, // Tamaño pequeño del ícono
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
          crossAxisAlignment: message.author.id == _user.id
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start, // Fix message alignment here
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
    bool isMe = message.author.id == _user.id;
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
                bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)),
          ),
          child: Text(
            message.text,
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        message.createdAt != null
            ? Text(
                DateFormat('hh:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(message.createdAt!)),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            : Text('Hora desconocida'),
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
                    color: Colors.grey.withOpacity(0.5), // Sombra del borde
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
                    borderRadius:
                        BorderRadius.circular(12), // Bordes redondeados
                    borderSide: const BorderSide(
                      color: Colors
                          .grey, // Color del borde cuando no está enfocado
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color:
                          Colors.blue, // Color del borde cuando está enfocado
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Fondo blanco para que sea visible
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12, // Espaciado dentro del campo de texto
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
