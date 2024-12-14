import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _chats = [];
  String _searchTerm = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _determineUserRoleAndLoadChats();
  }

  Future<void> _determineUserRoleAndLoadChats() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Consultar el rol del usuario actual
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final userRole = userData['role']; // Obtener el rol

        // Cargar chats basados en el rol
        if (userRole == 'Independent Provider') {
          await _loadClientsForProvider(); // Proveedor: Cargar clientes con los que trabajó
        } else {
          await _loadIndependentProviders(); // Cliente: Cargar proveedores
        }
      }
    } catch (e) {
      print('Error determining user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load chat list')),
      );
    }
  }

  Future<void> _loadClientsForProvider() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Obtener los bookings donde el proveedor es el usuario actual
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: currentUser.uid)
          .get();

      // Obtener los IDs únicos de los clientes
      final Set<String> customerIds = bookingsSnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['customerId'] as String?)
          .where((id) => id != null) // Validar que no sean nulos
          .cast<String>()
          .toSet();

      final List<Map<String, dynamic>> tempChats = [];

      for (var customerId in customerIds) {
        try {
          DocumentSnapshot customerSnapshot =
              await _firestore.collection('users').doc(customerId).get();

          String customerName = 'Unknown'; // Nombre predeterminado
          String profileImage = KImages.pp; // Imagen predeterminada

          if (customerSnapshot.exists) {
            final customerData =
                customerSnapshot.data() as Map<String, dynamic>;
            customerName =
                '${customerData['name']} ${customerData['lastName'] ?? ''}'
                    .trim();
            profileImage = customerData['profileImage'] ?? KImages.pp;
          }

          String chatRoomId = _generateChatRoomId(currentUser.uid, customerId);

          tempChats.add({
            'name': customerName,
            'message': '',
            'time': '',
            'unread': 0,
            'hasMessages': false,
            'image': profileImage,
            'chatRoomId': chatRoomId,
            'customerId': customerId,
            'providerId': currentUser.uid,
          });
        } catch (e) {
          print('Error loading customer data for $customerId: $e');
        }
      }

      setState(() {
        _chats = tempChats;
      });

      _loadChatData();
    } catch (e) {
      print('Error loading clients for provider: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load chat list')),
      );
    }
  }

  Future<void> _loadIndependentProviders() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Consultar los chats donde el usuario actual es el cliente
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .where('customerId', isEqualTo: currentUser.uid)
          .get();

      final List<Map<String, dynamic>> tempChats = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String chatRoomId = doc.id;
        String providerId = data['providerId'];

        // Consultar el nombre y la imagen del proveedor desde la colección `users`
        DocumentSnapshot providerSnapshot =
            await _firestore.collection('users').doc(providerId).get();

        String providerName = 'Unknown'; // Nombre predeterminado
        String profileImage = KImages.pp; // Imagen predeterminada
        if (providerSnapshot.exists) {
          final providerData = providerSnapshot.data() as Map<String, dynamic>;
          providerName =
              '${providerData['name']} ${providerData['lastName'] ?? ''}'
                  .trim();
          profileImage = providerData['profileImage'] ??
              KImages.pp; // Cargar imagen de perfil o usar la predeterminada
        }

        tempChats.add({
          'name': providerName, // Nombre real del proveedor
          'message': '', // Se actualizará con el último mensaje
          'time': '', // Se actualizará con el timestamp del mensaje
          'unread': 0, // Se actualizará con la cantidad de mensajes no leídos
          'hasMessages': false, // Indicar si hay mensajes
          'image': profileImage, // Imagen del perfil del proveedor
          'chatRoomId': chatRoomId,
          'customerId': data['customerId'],
          'providerId': providerId,
        });
      }

      setState(() {
        _chats = tempChats;
      });

      // Cargar mensajes no leídos y últimos mensajes para cada sala de chat
      _loadChatData();
    } catch (e) {
      print('Error loading chats: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load chat list')),
      );
    }
  }

  Future<void> _loadChatList() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Consultar el rol del usuario
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final userRole = userData['role'];

      if (userRole == 'Independent Provider') {
        await _loadClientsForProvider(); // Cargar clientes del proveedor
      } else {
        await _loadIndependentProviders(); // Cargar proveedores para clientes
      }
    }
  }

  Future<void> _loadChatData() async {
    for (var chat in _chats) {
      String? chatRoomId = chat['chatRoomId'] as String?;
      if (chatRoomId == null) continue;

      try {
        // Escucha los mensajes en tiempo real.
        _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final messageData =
                snapshot.docs.first.data() as Map<String, dynamic>?;

            if (messageData != null &&
                messageData.containsKey('text') &&
                messageData.containsKey('createdAt')) {
              setState(() {
                chat['message'] = messageData['text'];
                chat['time'] = _formatTimestamp(messageData['createdAt']);
                chat['hasMessages'] = true;
              });
            } else {
              print('Invalid message data for $chatRoomId: $messageData');
            }
          } else {
            setState(() {
              chat['message'] = 'No messages yet';
              chat['time'] = '';
              chat['hasMessages'] = false;
            });
          }
        }, onError: (error) {
          print('Error loading messages for $chatRoomId: $error');
        });

        // Escucha los mensajes no leídos en tiempo real.
        _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .where('read', isEqualTo: false)
            .where('receiverId', isEqualTo: _auth.currentUser?.uid)
            .snapshots()
            .listen((snapshot) {
          setState(() {
            // Actualiza los mensajes no leídos.
            chat['unread'] = snapshot.docs.length;
          });
        }, onError: (error) {
          print('Error loading unread messages for $chatRoomId: $error');
        });
      } catch (e) {
        print('Unexpected error in chat data loading for $chatRoomId: $e');
      }
    }
  }

  void _markMessagesAsRead(String chatRoomId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return; // Validar que haya un usuario autenticado

      final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);

      await _firestore.runTransaction((transaction) async {
        final chatRoomSnapshot = await transaction.get(chatRoomRef);

        if (!chatRoomSnapshot.exists) return;

        // Obtener los contadores actuales
        final unreadCounts = Map<String, dynamic>.from(
          chatRoomSnapshot.data()?['unreadCounts'] ?? {},
        );

        // Limpiar los mensajes no leídos del usuario actual
        unreadCounts[userId] = 0;

        // Actualizar Firestore
        transaction.update(chatRoomRef, {'unreadCounts': unreadCounts});

        // Opcional: Marcar mensajes como leídos
        final unreadMessagesQuery = await chatRoomRef
            .collection('messages')
            .where('receiverId', isEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        for (var doc in unreadMessagesQuery.docs) {
          transaction.update(doc.reference, {'read': true});
        }
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  String _generateChatRoomId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        return DateFormat('hh:mm a').format(timestamp.toDate());
      } else if (timestamp is int) {
        return DateFormat('hh:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
      } else {
        print('Unsupported timestamp type: $timestamp');
      }
    } catch (e) {
      print('Error formatting timestamp: $e');
    }
    return '';
  }

  void _setSearchTerm(String term) {
    setState(() {
      _searchTerm = term.toLowerCase();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  List<Map<String, dynamic>> get _filteredChats {
    List<Map<String, dynamic>> filtered = _chats;
    if (_searchTerm.isNotEmpty) {
      filtered = filtered.where((chat) {
        return chat['name'].toLowerCase().contains(_searchTerm);
      }).toList();
    }
    // Apply filtering based on the selected filter
    if (_filter == 'Read') {
      filtered = filtered.where((chat) => chat['unread'] == 0).toList();
    } else if (_filter == 'Unread') {
      filtered = filtered.where((chat) => chat['unread'] > 0).toList();
    }
    return filtered;
  }

  void _navigateToChat(Map<String, dynamic> chat) {
    _markMessagesAsRead(chat['chatRoomId']); // Marcar mensajes como leídos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerChatScreen(
          chatRoomId: chat['chatRoomId'],
          customerId: chat['customerId'],
          providerId: chat['providerId'],
          isFakeData: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: primaryColor,
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
            Utils.verticalSpace(20),
            _buildSearchBar(),
            Utils.verticalSpace(15),
            _buildFilterOptions(),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = _filteredChats[index];
                  return GestureDetector(
                    onTap: () => _navigateToChat(chat),
                    child: _buildChatItem(chat),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          ),
        ),
      ),
      title: const Text('Chats',
          style: TextStyle(fontSize: 24, color: Colors.white)),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<DocumentSnapshot>(
            future: _firestore
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!.exists) {
                print('Error loading user data: ${snapshot.error}');
                return const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.error, color: Colors.white),
                );
              }

              try {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
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
              } catch (e) {
                print('Error processing user data: $e');
                return const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.error, color: Colors.white),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.grey[400]!, // Color del borde
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 2), // Sombra ligera para resaltar
            ),
          ],
        ),
        child: TextField(
          onChanged: _setSearchTerm,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: 25,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: ['All Messages', 'Read', 'Unread'].map((filter) {
          return GestureDetector(
            onTap: () => _setFilter(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              decoration: BoxDecoration(
                color: _filter == filter ? primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: _filter == filter ? Colors.white : primaryColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final bool hasUnreadMessages = (chat['unread'] ?? 0) > 0;
    return ListTile(
      leading: FutureBuilder<DocumentSnapshot>(
        future: _firestore
            .collection('users')
            .doc(
              chat['customerId'] == _auth.currentUser?.uid
                  ? chat['providerId']
                  : chat['customerId'],
            )
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.error, color: Colors.white),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImageUrl = userData['profileImageUrl'] ?? KImages.pp;
          print(userData['profileImageUrl']);

          return CircleAvatar(
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
      title: Text(
        chat['name'] ?? 'Unknown',
        style: TextStyle(
          fontSize: 16,
          fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chat['message'] ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnreadMessages ? Colors.black : Colors.grey[600],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chat['time'] ?? '', style: const TextStyle(fontSize: 12)),
          if (hasUnreadMessages)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unread'].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () => _navigateToChat(chat),
    );
  }
}
