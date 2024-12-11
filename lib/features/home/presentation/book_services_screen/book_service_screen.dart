import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookServiceScreen extends StatefulWidget {
  final String taskId;

  const BookServiceScreen(
      {super.key, required this.taskId, required List categories});

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  Map<String, dynamic>? taskData;
  bool isLoading = true;
  String? error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      DocumentSnapshot<Map<String, dynamic>> taskDoc =
          await _firestore.collection('tasks').doc(widget.taskId).get();

      if (!taskDoc.exists) {
        setState(() {
          error = 'Task not found';
          isLoading = false;
        });
        return;
      }

      final data = taskDoc.data();

      if (data == null) {
        setState(() {
          error = 'No data available';
          isLoading = false;
        });
        return;
      }

      setState(() {
        taskData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading task: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Services'),
        backgroundColor: Colors.blue,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTaskData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (taskData == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceWidget(),
          const SizedBox(height: 20),
          _buildAddressAndDescription(),
          const SizedBox(height: 20),
          _buildDateTimePicker(),
          const SizedBox(height: 20),
          _buildPriceDetails(),
          const SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildServiceWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          taskData!['imageUrl'] != null
              ? Image.network(
                  taskData!['imageUrl'],
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.work, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskData!['title'] ?? 'No Title',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${taskData!['category'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (taskData!['description'] != null)
                  Text(
                    'Description: ${taskData!['description']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAndDescription() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your address',
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Additional Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Add any specific requirements or notes',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );

        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {
            final selectedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            print('Selected DateTime: $selectedDateTime');
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Date & Time'),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetails() {
    final double price = taskData!['price'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Service Price:'),
              Text('\$${price.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Advance Payment (10%):'),
              Text('\$${(price * 0.1).toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        final double advancePayment = (taskData!['price'] ?? 0.0) * 0.1;
        print(
            'Processing advance payment of: \$${advancePayment.toStringAsFixed(2)}');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.blue,
      ),
      child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
    );
  }
}
