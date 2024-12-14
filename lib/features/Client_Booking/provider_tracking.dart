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
import 'package:latlong2/latlong.dart';

class ProviderTrackingScreen extends ConsumerWidget {
  final OrderDetailsDto order;
  final MapController _mapController = MapController(); // Add MapController

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
          .collection('bookings') // Cambia por la colección correspondiente
          .doc(order.orderId) // Usa orderId para buscar la orden
          .get();

      if (!orderSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order not found!')),
        );
        return;
      }

      // Extraer providerId de los datos de la orden
      final orderData = orderSnapshot.data() as Map<String, dynamic>;
      final providerId = orderData['providerId'] as String?;

      if (providerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider ID not found in order data')),
        );
        return;
      }

      final chatRepository = ChatRepository();
      final chatRoomId =
          chatRepository.generateChatRoomId(clientId, providerId);

      // Crear la sala de chat si no existe
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chats').doc(chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'customerId': clientId,
          'providerId': providerId,
        });
      }

      // Navegar a la pantalla de chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerChatScreen(
            chatRoomId: chatRoomId,
            customerId: clientId,
            providerId: providerId,
            isFakeData: false,
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
