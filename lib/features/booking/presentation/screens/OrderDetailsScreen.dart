import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String taskStatus = "pending"; // Estado inicial de la tarea
  Map<String, bool> expandedState = {
    "Included Task(s)": true,
    "Booking Information": true,
    "Client Details": true,
    "Bill Details": true,
    "Task Status": true,
  };

  @override
  void initState() {
    super.initState();
    taskStatus = widget.order['status']?.toLowerCase() ?? "pending";
  }

  Future<void> _updateTaskStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.order['bookingId'])
          .update({'status': newStatus, 'updatedAt': Timestamp.now()});

      setState(() {
        taskStatus = newStatus.toLowerCase();
      });
    } catch (e) {
      debugPrint("Error updating task status: $e");
    }
  }

  Widget _buildProgressBar() {
    const steps = ['Started', 'In Progress', 'Completed'];
    const stepLabels = {
      'started': 0,
      'in progress': 1,
      'completed': 2,
    };
    final currentStep = stepLabels[taskStatus] ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            steps.length,
            (index) {
              final isCompleted = index <= currentStep;
              return Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            isCompleted ? Colors.blue : Colors.grey[300],
                        child: isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      isCompleted ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      if (index < steps.length - 1)
                        Container(
                          width: 40,
                          height: 2,
                          color: isCompleted ? Colors.blue : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      color: isCompleted ? Colors.blue : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required Widget content,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF404C8C), // Color del texto del AppBar
              ),
            ),
            trailing: Icon(
              expandedState[title]! ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF404C8C),
            ),
            onTap: () {
              setState(() {
                expandedState[title] = !expandedState[title]!;
              });
            },
          ),
          if (expandedState[title]!)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildChatAndCallButtons() {
    if (taskStatus == "started" ||
        taskStatus == "in progress" ||
        taskStatus == "completed") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Lógica para llamar
            },
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text("Call"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(120, 50),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Lógica para abrir chat
            },
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text("Chat"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(120, 50),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildConditionalButton() {
    if (taskStatus == "pending") {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateTaskStatus("accepted"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Accept"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateTaskStatus("declined"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Decline"),
            ),
          ),
        ],
      );
    } else if (taskStatus == "accepted") {
      return ElevatedButton(
        onPressed: () => _updateTaskStatus("started"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text(
          "Drive to Task",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else if (taskStatus == "started") {
      return ElevatedButton(
        onPressed: () => _updateTaskStatus("in progress"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text(
          "Start Task",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else if (taskStatus == "in progress") {
      return ElevatedButton(
        onPressed: () => _updateTaskStatus("completed"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text(
          "Complete Task",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPriceRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? const Color(0xFF404C8C) : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF404C8C),
        elevation: 0,
        title: const Text(
          "Booking Tasks Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de Progreso
            _buildProgressBar(),
            const SizedBox(height: 20),

            // Included Task(s)
            _buildExpandableCard(
              title: "Included Task(s)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Service: ${widget.order['selectedTaskName'] ?? 'N/A'}"),
                  Text(
                      "Category: ${widget.order['selectedCategory'] ?? 'N/A'}"),
                ],
              ),
            ),

            // Booking Information
            _buildExpandableCard(
              title: "Booking Information",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${widget.order['date'] ?? 'N/A'}"),
                  Text("Time: ${widget.order['timeSlot'] ?? 'N/A'}"),
                ],
              ),
            ),

            // Client Details
            _buildExpandableCard(
              title: "Client Details",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Name: ${widget.order['clientName']} ${widget.order['clientLastName'] ?? ''}"),
                  Text("Phone: ${widget.order['clientPhone'] ?? 'N/A'}"),
                  Text("Address: ${widget.order['clientAddress'] ?? 'N/A'}"),
                ],
              ),
            ),

            // Botones de Chat y Call
            const SizedBox(height: 16),
            _buildChatAndCallButtons(),

            // Bill Details
            _buildExpandableCard(
              title: "Bill Details",
              content: Column(
                children: [
                  _buildPriceRow(
                      'Price', '\$${widget.order['taskPrice'] ?? '0.00'}'),
                  _buildPriceRow(
                      'Discount', '-\$${widget.order['discount'] ?? '0.00'}'),
                  _buildPriceRow('Tax', '\$${widget.order['tax'] ?? '0.00'}'),
                  const Divider(),
                  _buildPriceRow(
                    'Total Amount',
                    '\$${widget.order['totalPrice'] ?? '0.00'}',
                    isHighlighted: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Conditional Buttons
            _buildConditionalButton(),
          ],
        ),
      ),
    );
  }
}
