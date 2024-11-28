import 'package:ezpc_tasks_app/features/home/presentation/screens/booking_task_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_scroll/text_Scroll.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("No user is logged in.");
      } else {
        debugPrint("User ID: ${user.uid}");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: user?.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return [];
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: const Color(0xFF404C8C),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading bookings.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 16.0), // Space below AppBar
            itemCount: bookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingTaskDetailsScreen(booking: booking),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFFC0C1C7), // Outline color
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
                                  // Task Name
                                  Text(
                                    booking['taskName'] ?? 'Task Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Price
                                  Row(
                                    children: [
                                      Text(
                                        '\$${booking['price']?.toStringAsFixed(2) ?? '0.00'}',
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
                            ),
                            const SizedBox(width: 8.0),
                            // Status and Booking ID
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: booking['status']?.toLowerCase() ==
                                            'pending'
                                        ? const Color(0xFFFFF1E6)
                                        : getStatusColor(
                                            booking['status'] ?? ''),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    booking['status']?.toUpperCase() ?? 'N/A',
                                    style: TextStyle(
                                      color: booking['status']?.toLowerCase() ==
                                              'pending'
                                          ? const Color(0xFFEA7446)
                                          : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Booking ID
                                Text(
                                  '#${booking['id'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Your Address: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextScroll(
                                      booking['address'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      mode: TextScrollMode
                                          .bouncing, // Modo de desplazamiento
                                      velocity: const Velocity(
                                          pixelsPerSecond: Offset(
                                              30, 0)), // Velocidad del texto
                                      pauseBetween: const Duration(
                                          seconds: 1), // Pausa entre ciclos
                                      textAlign: TextAlign.right,
                                      selectable:
                                          true, // Permite seleccionar el texto si es necesario
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.grey),
                              // Date & Time
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Date & Time: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '${booking['date'] ?? 'N/A'} at ${booking['time'] ?? 'N/A'}',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Provider: ',
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
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
