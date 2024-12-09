import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const ConfirmationScreen({
    super.key,
    required this.bookingData,
  });

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool isLoading = false;

  Future<void> saveBookingToFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .add(widget.bookingData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully!')),
      );

      // Navega a la pantalla de pago
      Navigator.pushNamed(context, '/payment');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildProgressStep("Task", isCompleted: true),
        _buildProgressStep("Information", isCompleted: true),
        _buildProgressStep("Confirm", isCompleted: true),
      ],
    );
  }

  Widget _buildProgressStep(String title, {required bool isCompleted}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isCompleted ? const Color(0xFF404C8C) : Colors.grey,
          child: Icon(
            isCompleted ? Icons.check : Icons.circle_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: isCompleted ? const Color(0xFF404C8C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Client Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Name: ${widget.bookingData['clientName']}"),
            Text("Phone: ${widget.bookingData['clientPhone']}"),
            Text("Email: ${widget.bookingData['clientEmail']}"),
            Text("Address: ${widget.bookingData['clientAddress']}"),
            if (widget.bookingData['shortNotes'] != null &&
                widget.bookingData['shortNotes'].isNotEmpty)
              Text("Notes: ${widget.bookingData['shortNotes']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    final subCategories = widget.bookingData['subCategories'];
    final subCategoriesText = (subCategories != null && subCategories is List)
        ? subCategories.join(', ')
        : 'No details available';

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Task Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Service: ${widget.bookingData['category']}"),
            Text("Date: ${widget.bookingData['date']}"),
            Text("Time: ${widget.bookingData['timeSlot']}"),
            Text("Service Details: $subCategoriesText"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final categoryPrice = widget.bookingData['categoryPrice'] ?? 0.0;
    final taskPrice = widget.bookingData['taskPrice'] ?? 0.0;
    final taxes = widget.bookingData['taxes'] ?? 0.0;
    final totalPrice = widget.bookingData['totalPrice'] ?? 0.0;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildPriceRow("Category Price", categoryPrice),
            _buildPriceRow("Task Price", taskPrice),
            _buildPriceRow("Taxes (10%)", taxes),
            const Divider(),
            _buildPriceRow(
              "Total",
              totalPrice,
              isBold: true,
              textColor: const Color(0xFF404C8C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double price,
      {bool isBold = false, Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "\$${price.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              await saveBookingToFirestore();
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: const Color(0xFF404C8C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Proceed to Payment",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmation"),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),

              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 24.0),

              // Client Information Card
              _buildClientInfoCard(),
              const SizedBox(height: 16.0),

              // Task Information Card
              _buildTaskInfoCard(),
              const SizedBox(height: 16.0),

              // Payment Information Card
              _buildPaymentInfoCard(),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildProceedButton(),
      ),
    );
  }
}
