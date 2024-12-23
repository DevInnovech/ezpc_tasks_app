import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/provider_tracking_provider.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/expandable_status.dart';
import 'package:ezpc_tasks_app/features/chat/data/chat_repository.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class ProviderTrackingScreen extends ConsumerWidget {
  final OrderDetailsDto order;
  final MapController _mapController = MapController(); // Add MapController
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProviderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(providerTrackingProvider(order.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Provider")),
      body: trackingState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (trackingData) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(trackingData, context),
                _buildOrderInfo(trackingData),
                // Usar `order.providerId` directamente aquí
                _buildMap(order.providerId, context),
                _buildProcessIndicator(trackingData.status),
                ExpandableStatusDescription(status: trackingData.status),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: PrimaryButton(
                    text: "Report a problem",
                    onPressed: () {},
                    bgColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(trackingData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(trackingData.providerImageUrl),
          ),
          Column(
            children: [
              Text(trackingData.providerName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat,
                      color: primaryColor,
                    ),
                    onPressed: () => _openChatWithCustomer(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.phone,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      // Iniciar llamada
                    },
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
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

  void _markMessagesAsRead(String chatRoomId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('No authenticated user found.');
        return; // Validar que haya un usuario autenticado
      }

      final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);

      await _firestore.runTransaction((transaction) async {
        final chatRoomSnapshot = await transaction.get(chatRoomRef);

        if (!chatRoomSnapshot.exists) {
          print('Chat room does not exist: $chatRoomId');
          return; // Detener si el documento no existe
        }

        // Convertir los datos del snapshot a un mapa y manejar valores opcionales
        final chatRoomData = chatRoomSnapshot.data() ?? {};

        // Validar la existencia del campo `unrea dCounts`
        final unreadCounts = chatRoomData.containsKey('unreadCounts')
            ? Map<String, dynamic>.from(chatRoomData['unreadCounts'])
            : {};

        // Establecer el contador de mensajes no leídos a 0 para el usuario actual
        unreadCounts[userId] = 0;

        // Actualizar el documento de la sala de chat con los contadores actualizados
        transaction.update(chatRoomRef, {'unreadCounts': unreadCounts});

        // Opcional: Marcar mensajes como leídos dentro de la subcolección `messages`
        final unreadMessagesQuery = await chatRoomRef
            .collection('messages')
            .where('receiverId', isEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        for (var doc in unreadMessagesQuery.docs) {
          transaction.update(doc.reference, {'read': true});
        }
      });

      print('Messages marked as read in chatRoomId: $chatRoomId');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _openChatWithCustomer(BuildContext context) async {
    final clientId = FirebaseAuth.instance.currentUser?.uid;

    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to start chat: Missing client ID')),
      );
      return;
    }

    try {
      // Consulta la orden en Firebase para obtener el providerId
      final orderSnapshot = await FirebaseFirestore.instance
          .collection('bookings') // Cambiar según tu colección de bookings
          .doc(order.orderId) // Usa el orderId del pedido actual
          .get();

      if (!orderSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order not found!')),
        );
        return;
      }

      // Extraer providerId de los datos del pedido
      final orderData = orderSnapshot.data() as Map<String, dynamic>;
      final providerId = orderData['providerId'] as String?;

      if (providerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider ID not found in order data')),
        );
        return;
      }

      // Generar el ID único para la sala de chat
      final chatRoomId = _generateChatRoomId(clientId, providerId);

      // Crear o actualizar la sala de chat
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chats').doc(chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        // Crear la sala de chat si no existe
        await chatRoomRef.set({
          'customerId': clientId,
          'providerId': providerId,
          'orderId': order.orderId, // Agregar orderId a la sala
          'createdAt': FieldValue.serverTimestamp(),
          'unreadCounts': {}, // Inicializar contadores de no leídos
          'onlineUsers': [], // Inicializar lista de usuarios en línea
        });
      } else {
        // Verificar y actualizar el campo `orderId` si está ausente
        final chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>;
        if (!chatRoomData.containsKey('orderId')) {
          await chatRoomRef.update({'orderId': order.orderId});
        }
      }

      // Marcar mensajes como leídos si es necesario
      _markMessagesAsRead(chatRoomId);

      // Navegar a la pantalla de chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerChatScreen(
            chatRoomId: chatRoomId,
            customerId: clientId,
            providerId: providerId,
            isFakeData: false,
            orderId: order.orderId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error opening chat: $e');
    }
  }

  Widget _buildOrderInfo(trackingData) {
    return Column(
      children: [
        const Text(
          "Order Number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4), // Space between title and order number
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            trackingData.orderId,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF535769),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(String providerId, BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('providers') // Cambia si la colección es diferente
          .doc(providerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Error loading live location"));
        }

        final providerData = snapshot.data!.data() as Map<String, dynamic>;
        final LatLng providerLocation = LatLng(
          providerData['latitude'] ?? 0.0,
          providerData['longitude'] ?? 0.0,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FlutterMap(
              mapController: _mapController, // Usa el MapController
              options: MapOptions(
                initialCenter:
                    providerLocation, // Cambia 'center' por 'initialCenter'
                initialZoom: 15.0, // Nivel inicial de zoom
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point:
                          providerLocation, // Asegúrate que providerLocation sea LatLng válido
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessIndicator(TrackingStatus status) {
    Color activeColor = Colors.blue; // Replace with your primary color
    Color inactiveColor = Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // First Circle with Target Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gps_fixed,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Connecting Line 1
          Container(
            width: 50,
            height: 2,
            color: (status == TrackingStatus.reserved ||
                    status == TrackingStatus.onTheWay ||
                    status == TrackingStatus.atLocation)
                ? activeColor
                : inactiveColor,
          ),

          // Second Circle with Person Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (status == TrackingStatus.onTheWay ||
                      status == TrackingStatus.atLocation)
                  ? activeColor
                  : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Connecting Line 2
          Container(
            width: 50,
            height: 2,
            color: (status == TrackingStatus.atLocation)
                ? activeColor
                : inactiveColor,
          ),

          // Third Circle with Location Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: status == TrackingStatus.atLocation
                  ? activeColor
                  : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
