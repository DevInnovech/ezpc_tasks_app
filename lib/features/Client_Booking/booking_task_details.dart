// esta en uso el order details
import 'package:flutter/material.dart';
/*
class BookingTaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingTaskDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF404C8C), // Mantener el color original
        elevation: 0, // Sin sombra
        toolbarHeight: 60, // Altura personalizada del AppBar
        titleSpacing: 0, // Sin espacio adicional
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                booking['status'] ?? 'N/A', // Estado dinámico
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  // Implementar acción para "Check Status"
                },
                child: const Text(
                  'Check Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Booking ID',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '#${booking['bookingId'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1.0, color: Colors.grey),
            const SizedBox(height: 16),
            // Task Name and Image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['taskName'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${booking['date'] ?? 'N/A'}\nTime: ${booking['time'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: booking['imageUrl'] != null
                      ? Image.network(
                          booking['imageUrl'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
              ],
            ),
            const Divider(thickness: 1.0, color: Colors.grey),
            const SizedBox(height: 24),
            // About Provider
            const Text(
              'About Provider',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(246, 247, 249, 255),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: booking['providerImageUrl'] != null
                          ? NetworkImage(booking['providerImageUrl'])
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: booking['providerImageUrl'] == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Provider Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['providerName'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                booking['rating']?.toStringAsFixed(1) ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            booking['providerEmail'] ?? 'N/A',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking['providerAddress'] ?? 'N/A',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking['providerPhone'] ?? 'N/A',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Call and Chat Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Call Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Acción para "Call"
                      print('Call button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF404C8C),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text(
                      'Call',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Espaciado entre botones
                // Chat Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Acción para "Chat"
                      print('Chat button pressed');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Colors.black),
                    label: const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(thickness: 1.0, color: Colors.grey),
            const SizedBox(height: 24),
            // Price Details
            const Text(
              'Price Detail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(246, 247, 249, 255),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Price',
                      '\$${booking['price']?.toStringAsFixed(2) ?? '0.00'}'),
                  const Divider(color: Colors.grey),
                  _buildPriceRow(
                    'Discount',
                    '-\$${booking['discount']?.toStringAsFixed(2) ?? '0.00'}',
                    textColor: Colors.green,
                  ),
                  const Divider(color: Colors.grey),
                  _buildPriceRow('Subtotal',
                      '\$${booking['subtotal']?.toStringAsFixed(2) ?? '0.00'}'),
                  const Divider(color: Colors.grey),
                  _buildPriceRow(
                    'Tax',
                    '\$${booking['tax']?.toStringAsFixed(2) ?? '0.00'}',
                    textColor: Colors.red,
                  ),
                  const Divider(color: Colors.grey),
                  _buildPriceRow(
                    'Total Amount',
                    '\$${booking['total']?.toStringAsFixed(2) ?? '0.00'}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1.0, color: Colors.grey),
            const SizedBox(height: 24),
            // Cancel Booking Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implementar la lógica para cancelar el booking
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF404C8C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {Color textColor = Colors.black, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w400),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
*/