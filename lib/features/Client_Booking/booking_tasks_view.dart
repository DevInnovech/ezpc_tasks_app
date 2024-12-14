import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/booking_details_tasks_details.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/provider_tracking.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ezpc_tasks_app/shared/widgets/scrolling_taggle_button.dart'; // Asegúrate de importar el componente
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:text_scroll/text_Scroll.dart'; // Importa `primaryColor`

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> filteredBookings = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserBookings();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFF1E6);
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _fetchUserBookings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("No user is logged in.");
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: user.uid)
          .get();

      setState(() {
        bookings = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _applyFilter(_currentIndex); // Aplica el filtro inicial
      });
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    }
  }

  void _applyFilter(int index) {
    _currentIndex = index;

    setState(() {
      if (index == 0) {
        // Filtrar tanto 'pending' como 'accepted' en la categoría de pendientes
        filteredBookings = bookings
            .where((booking) =>
                booking['status']?.toLowerCase() == 'pending' ||
                booking['status']?.toLowerCase() == 'accepted')
            .toList();
      } else if (index == 1) {
        // 'in progress' y 'started' para tareas en progreso
        filteredBookings = bookings
            .where((booking) =>
                booking['status']?.toLowerCase() == 'in progress' ||
                booking['status']?.toLowerCase() == 'started')
            .toList();
      } else if (index == 2) {
        // Solo 'completed' para tareas completadas
        filteredBookings = bookings
            .where((booking) => booking['status']?.toLowerCase() == 'completed')
            .toList();
      } else if (index == 3) {
        // Solo 'cancelled' para tareas canceladas
        filteredBookings = bookings
            .where((booking) => booking['status']?.toLowerCase() == 'cancelled')
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ['Pending', 'In Progress', 'Completed', 'Cancelled'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: const Color(0xFF404C8C),
      ),
      body: Column(
        children: [
          // Filtros superiores
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.50, color: primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: ToggleButtonScrollComponent(
              textList: list,
              initialLabelIndex: _currentIndex,
              onChange: _applyFilter,
            ),
          ),
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(
                    child: Text(
                      'No bookings found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 16.0),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return InkWell(
                        onTap: () {
                          try {
                            // Crea el objeto OrderDetailsDto a partir de los datos de booking
                            final orderDetails = OrderDetailsDto(
                              orderId:
                                  booking['bookingId']?.toString() ?? 'N/A',
                              providerId:
                                  booking['providerId']?.toString() ?? 'N/A',
                              taskName:
                                  booking['selectedTaskName']?.toString() ??
                                      'N/A',
                              providerName:
                                  booking['providerName']?.toString() ?? 'N/A',
                              providerImageUrl:
                                  booking['providerImageUrl']?.toString() ?? '',
                              date: booking['date']?.toString() ?? 'N/A',
                              time: booking['timeSlot']?.toString() ?? 'N/A',
                              price: double.tryParse(
                                      booking['taskPrice']?.toString() ??
                                          '0.0') ??
                                  0.0,
                              discount: double.tryParse(
                                      booking['discount']?.toString() ??
                                          '0.0') ??
                                  0.0,
                              tax: double.tryParse(
                                      booking['tax']?.toString() ?? '0.0') ??
                                  0.0,
                              total: double.tryParse(
                                      booking['totalPrice']?.toString() ??
                                          '0.0') ??
                                  0.0,
                              status: booking['status']?.toString() ?? 'N/A',
                              address:
                                  booking['clientAddress']?.toString() ?? 'N/A',
                              providerEmail:
                                  booking['providerEmail']?.toString() ?? 'N/A',
                              providerPhone:
                                  booking['providerPhone']?.toString() ?? 'N/A',
                              rating: double.tryParse(
                                      booking['rating']?.toString() ?? '0.0') ??
                                  0.0,
                              paymentStatus:
                                  booking['paymentStatus']?.toString() ?? 'N/A',
                            );

                            // Navega al ProviderTrackingScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProviderTrackingScreen(order: orderDetails),
                              ),
                            );
                          } catch (e) {
                            // Muestra un mensaje de error si algo falla
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error al cargar la orden: $e')),
                            );
                          }
                        },
                        child: _buildBookingCard(booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFC0C1C7),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Task Image, Name, Price, and Status
            Row(
              children: [
                // Task Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: booking['imageUrl'] != null &&
                          booking['imageUrl'].isNotEmpty
                      ? Image.network(
                          booking['imageUrl'],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 12.0),
                // Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(booking['status']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking['status']?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '\$${booking['taskPrice']?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF404C8C),
                                ),
                              ),
                              if (booking['discount'] != null)
                                Text(
                                  ' (${booking['discount']}% Off)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      // Task Name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          booking['selectedTaskName'] ?? 'Task Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '#${booking['id'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Price and Discount
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                // Status and Booking ID
              ],
            ),
            const SizedBox(height: 12),
            // Encapsulation for Address, Date & Time, and Provider
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Address:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: TextScroll(
                          booking['clientAddress'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          mode: TextScrollMode.bouncing,
                          velocity:
                              const Velocity(pixelsPerSecond: Offset(30, 0)),
                          pauseBetween: const Duration(seconds: 1),
                          textAlign: TextAlign.right,
                          selectable: true,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  // Date & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date & Time:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${booking['date'] ?? 'N/A'} at ${booking['timeSlot'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  // Provider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Provider:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        booking['providerName'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
