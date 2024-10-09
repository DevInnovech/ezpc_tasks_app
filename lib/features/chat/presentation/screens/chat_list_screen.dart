import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          ),
        ),
      ),
      title: Text('Chats', style: TextStyle(fontSize: 24, color: Colors.white)),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
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
          decoration: InputDecoration(
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
          style: TextStyle(color: Colors.black), // Color del texto ingresado
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
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              decoration: BoxDecoration(
                color: _filter == filter ? primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor!),
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
        padding: EdgeInsets.only(right: 20),
        child: Text('Delete', style: TextStyle(color: Colors.white)),
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
            Text(chat['time'], style: TextStyle(fontSize: 12)),
            if (chat['unread'] > 0)
              Container(
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat['unread'].toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
