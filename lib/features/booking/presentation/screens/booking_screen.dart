import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/ProviderOrderDetailsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderOrdersScreen extends StatelessWidget {
  const ProviderOrdersScreen({super.key});

  // Función para obtener las órdenes desde Firebase
  Future<List<Map<String, dynamic>>> fetchProviderOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("No provider is logged in.");
        return [];
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => {'taskId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  // Actualizar estado en Firebase
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  // Obtener color según el estado
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
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF404C8C),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProviderOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return Column(
            // Wrap the ListView in a Column
            children: [
              const SizedBox(height: 10), // Optional padding
              Expanded(
                // Use Expanded here
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      child: _buildOrderCard(context, order),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Construcción del contenedor de la orden
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskImage(order),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusLabel(order),
                      const SizedBox(height: 8),
                      Text(
                        order['selectedTaskName'] ?? 'Task Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildPriceRow(order),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOrderDetailsContainer(context, order),
          ],
        ),
      ),
    );
  }

  // Construcción de la imagen
  Widget _buildTaskImage(Map<String, dynamic> order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: order['imageUrl'] != null && order['imageUrl'].isNotEmpty
          ? Image.network(
              order['imageUrl'],
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 80,
      width: 80,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStatusLabel(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(order['status'] ?? ''),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        order['status']?.toUpperCase() ?? 'N/A',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceRow(Map<String, dynamic> order) {
    return Row(
      children: [
        Text(
          '\$${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF404C8C),
          ),
        ),
        if (order['discount'] != null)
          Text(
            ' (${order['discount']}% Off)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
      ],
    );
  }

  Widget _buildOrderDetailsContainer(
      BuildContext context, Map<String, dynamic> order) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Address', order['clientAddress'] ?? 'N/A'),
            const Divider(color: Colors.grey),
            _buildDetailRow('Date & Time',
                '${order['date'] ?? 'N/A'} At ${order['timeSlot'] ?? 'N/A'}'),
            const Divider(color: Colors.grey),
            _buildDetailRow('Customer', order['clientName'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
