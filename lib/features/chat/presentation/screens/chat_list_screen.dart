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
    _loadIndependentProviders();
  }

  Future<void> _loadIndependentProviders() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Independent Provider')
          .get();

      setState(() {
        _chats = snapshot.docs
            .where(
                (doc) => doc.id != currentUser.uid) // Exclude the current user
            .map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String chatRoomId = _generateChatRoomId(currentUser.uid, doc.id);

          return {
            'name': '${data['name'] ?? ''} ${data['lastName'] ?? ''}',
            'message': '', // Will be updated with the latest message
            'time': '', // Will be updated with the latest message timestamp
            'unread': 0, // Will be updated with the count of unread messages
            'hasMessages': false, // New field to check if messages exist
            'image': KImages.pp, // Default profile image, can be customized
            'chatRoomId': chatRoomId,
            'customerId': currentUser.uid,
            'providerId': doc.id,
          };
        }).toList();

        // Load unread counts and last messages for each chat room
        _loadChatData();
      });
    } catch (e) {
      print('Error loading independent providers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load chat list')),
      );
    }
  }

  Future<void> _loadChatData() async {
    for (var chat in _chats) {
      String chatRoomId = chat['chatRoomId'];
      // Load the count of unread messages
      _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .where('receiverId', isEqualTo: _auth.currentUser?.uid)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            chat['unread'] = snapshot.docs.length;
          });
        }
      });

      // Load the last message
      _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final lastMessageData = snapshot.docs.first.data();
          setState(() {
            chat['message'] = lastMessageData['text'] ?? '';
            chat['time'] = _formatTimestamp(lastMessageData['createdAt']);
            chat['hasMessages'] = true; // Set flag to true if messages exist
          });
        }
      });
    }
  }

  String _generateChatRoomId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(date);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerChatScreen(
          chatRoomId: chat['chatRoomId'],
          customerId: chat['customerId'],
          providerId: chat['providerId'],
          isFakeData: false, // Real data usage
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
      actions: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomImage(
                  url: null,
                  path: KImages.pp,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
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
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: _setSearchTerm,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
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
    final bool hasUnreadMessages = chat['unread'] > 0;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomImage(
              url: null,
              path: chat['image'].toString(),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      title: Text(
        chat['name'],
        style: TextStyle(
          fontSize: 16,
          fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: chat['hasMessages']
          ? Text(
              chat['message'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnreadMessages ? Colors.black : Colors.grey[600],
              ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chat['time'], style: const TextStyle(fontSize: 12)),
          if (chat['unread'] > 0)
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
    );
  }
}
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Jose Florez',
      'message': 'Hello! See you this afternoon?',
      'time': '12:36',
      'unread': 1,
      'image': KImages.pp,
      'chatRoomId': 'room_jose_florez',
      'customerId': 'customer_jose',
      'providerId': 'provider_jose',
    },
    {
      'name': 'Tifany Plures',
      'message': 'Yes ok. This needs to be discussed',
      'time': '14:06',
      'unread': 3,
      'image': KImages.pp,
      'chatRoomId': 'room_tifany_plures',
      'customerId': 'customer_tifany',
      'providerId': 'provider_tifany',
    },
    {
      'name': 'Mary Torrez',
      'message': 'The meeting must be arranged tomorrow.',
      'time': '13:48',
      'unread': 2,
      'image': KImages.pp,
      'chatRoomId': 'room_mary_torrez',
      'customerId': 'customer_mary',
      'providerId': 'provider_mary',
    },
  ];
  String _searchTerm = '';
  String _filter = 'All';

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
        return chat['name'].toLowerCase().contains(_searchTerm) ||
            chat['message'].toLowerCase().contains(_searchTerm);
      }).toList();
    }
    if (_filter != 'All') {
      filtered = filtered.where((chat) {
        bool hasUnread = chat['unread'] > 0;
        return (_filter == 'Read' && !hasUnread) ||
            (_filter == 'Unread' && hasUnread);
      }).toList();
    }
    return filtered;
  }

  void _navigateToChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerChatScreen(
          chatRoomId: chat['chatRoomId'], // Asegúrate de tener esto en tu data
          customerId: chat['customerId'], // Asegúrate de tener esto en tu data
          providerId: chat['providerId'], // Asegúrate de tener esto en tu data
          isFakeData: true,
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
                    child: _buildChatItem(chat, index),
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
      actions: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent, // Fondo transparente
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomImage(
                  url: null,
                  path: KImages.pp, // Reemplaza con la ruta de tu imagen
                  fit: BoxFit
                      .cover, // Ajusta la imagen para que rellene el CircleAvatar
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0), // Ajuste horizontal
      child: Container(
        height: 42, // Altura más delgada para el buscador
        decoration: BoxDecoration(
          color: Colors.grey[350], // Color de fondo claro
          borderRadius: BorderRadius.circular(30), // Bordes redondeados
        ),
        child: TextField(
          onChanged: _setSearchTerm,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
            filled: false,
            border:
                InputBorder.none, // Eliminar bordes por defecto al hacer clic
            enabledBorder:
                InputBorder.none, // Sin borde cuando no está enfocado
            focusedBorder: InputBorder.none, // Sin borde cuando está enfocado
            contentPadding: EdgeInsets.symmetric(
                vertical: 10, horizontal: 20), // Ajuste vertical del texto
          ),
          style:
              const TextStyle(color: Colors.black), // Color del texto ingresado
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

  Widget _buildChatItem(Map<String, dynamic> chat, int index) {
    return Dismissible(
      key: Key(chat['name']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _chats.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${chat['name']} chat deleted')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Text('Delete', style: TextStyle(color: Colors.white)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          //     radius: 25,
          backgroundColor: Colors.transparent, // Fondo transparente
          child: ClipOval(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomImage(
                url: null,
                path: chat['image']
                    .toString(), // Reemplaza con la ruta de tu imagen
                fit: BoxFit
                    .cover, // Ajusta la imagen para que rellene el CircleAvatar
                //  width: 50,
                //    height: 50,
              ),
            ),
          ),
        ),
        title: Text(chat['name']),
        subtitle:
            Text(chat['message'], maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(chat['time'], style: const TextStyle(fontSize: 12)),
            if (chat['unread'] > 0)
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
      ),
    );
  }
}
