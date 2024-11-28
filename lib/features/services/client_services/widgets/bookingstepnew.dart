import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/newpaymentscreen.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/googleplaceautocomplete.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatelessWidget {
  final String taskId;

  const BookingScreen({super.key, required this.taskId});

  Future<String?> getCurrentUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user?.uid;
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
    return null;
  }

  Future<Task?> fetchTask(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        data?['taskId'] = doc.id; // Agregar el taskId al mapa
        return Task.fromMap(data!);
      }
    } catch (e) {
      debugPrint('Error fetching task: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Task'),
        backgroundColor: const Color(0xFF404C8C),
        titleTextStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white), // Cambia el color del texto a blanco,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<String?>(
        future: getCurrentUserId(),
        builder: (context, userIdSnapshot) {
          if (userIdSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userIdSnapshot.hasError) {
            return const Center(child: Text('Error loading user data.'));
          } else if (!userIdSnapshot.hasData || userIdSnapshot.data == null) {
            return const Center(child: Text('User not logged in.'));
          }

          final userId = userIdSnapshot.data!;
          return FutureBuilder<Task?>(
            future: fetchTask(taskId),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (taskSnapshot.hasError) {
                return const Center(child: Text('Error loading task.'));
              } else if (!taskSnapshot.hasData || taskSnapshot.data == null) {
                return const Center(child: Text('Task not found.'));
              }

              final task = taskSnapshot.data!;
              return BookingDetails(task: task, userId: userId);
            },
          );
        },
      ),
    );
  }
}

class BookingDetails extends StatefulWidget {
  final Task task;
  final String userId;

  const BookingDetails({Key? key, required this.task, required this.userId})
      : super(key: key);

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;
  late int taskDuration;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchClientData(widget.userId);
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
    descriptionController = TextEditingController();
    taskDuration =
        int.tryParse(widget.task.duration.replaceAll(RegExp(r'\D'), '')) ?? 30;
  }

  Future<void> fetchClientData(String userId) async {
    try {
      final clientDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(userId)
          .get();

      if (clientDoc.exists) {
        final clientData = clientDoc.data();
        setState(() {
          firstNameController =
              TextEditingController(text: clientData?['name'] ?? '');
          lastNameController =
              TextEditingController(text: clientData?['lastName'] ?? '');
          phoneController =
              TextEditingController(text: clientData?['phoneNumber'] ?? '');
          emailController =
              TextEditingController(text: clientData?['email'] ?? '');
        });
      }
    } catch (e) {
      debugPrint('Error fetching client data: $e');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd-MMM-yyyy');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Task Duration
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: widget.task.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.task.imageUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child:
                                Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                taskDuration =
                                    (taskDuration - 30).clamp(30, 480);
                              });
                            },
                          ),
                          Text(
                            '$taskDuration min',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                taskDuration =
                                    (taskDuration + 30).clamp(30, 480);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Name, Email, and Phone Fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstNameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: lastNameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: phoneController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Address Section with Autocomplete
            const Text(
              'Address',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your address...',
              ),
              onTap: () async {
                final suggestion =
                    await GooglePlacesService.getAddressPrediction(context);
                if (suggestion != null) {
                  setState(() {
                    addressController.text = suggestion;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),

            // Description Section
            const Text(
              'Description',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add a description...',
              ),
            ),
            const SizedBox(height: 16.0),

            // Booking Date & Slot Section
            const Text(
              'Booking Date & Slot',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            InkWell(
              onTap: () => pickDateTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${selectedDate != null ? dateFormatter.format(selectedDate!) : 'Choose Date'}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        Text(
                          'Time: ${selectedTime != null ? selectedTime!.format(context) : 'Choose Time'}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                      ],
                    ),
                    const Icon(Icons.edit, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Price Details Section
            const Divider(),
            const Text(
              'Price Detail',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _PriceDetailRow(
                label: 'Price',
                value: '\$${widget.task.price.toStringAsFixed(2)}'),
            const SizedBox(height: 16.0),

            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF404C8C), // Fondo azul
                  foregroundColor: Colors.white, // Texto blanco
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Bordes redondeados
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                onPressed: () async {
                  if (selectedDate == null || selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a date and time.'),
                      ),
                    );
                    return;
                  }

                  // Construye los datos para la colección bookings
                  final bookingData = {
                    'taskId': widget.task.id,
                    'taskName': widget.task.name,
                    'providerId': widget.task.providerId ?? '',
                    'providerName':
                        '${widget.task.firstName ?? ''} ${widget.task.lastName ?? ''}',
                    'type': widget.task.type ??
                        '', // Asegúrate de tener este campo en el modelo de tareas
                    'address': addressController.text,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                    'time': selectedTime!.format(context),
                    'taskDuration': '$taskDuration minutes',
                    'price': widget.task.price,
                    'customerId': widget.userId,
                    'customerName':
                        '${firstNameController.text} ${lastNameController.text}',
                    'email': emailController.text,
                    'phoneNumber': phoneController.text,
                    'status': 'pending', // Estado inicial de la reserva
                    'paymentStatus': 'pending', // Estado inicial del pago
                    'paymentMethod':
                        '', // Inicialmente vacío; se llenará en la pantalla de pago
                    'description': descriptionController.text,
                    'refundAmount': 0, // Por defecto, sin reembolso
                    'refundStatus': '', // Estado inicial del reembolso
                    'cancellationCharges':
                        0, // Por defecto, sin cargos de cancelación
                    'cancellationChargeAmount':
                        0, // Cantidad específica de cargos de cancelación
                    'cancellationChargeHours':
                        0, // Horas mínimas necesarias para cancelar sin cargos
                    'reason': '', // Inicialmente vacío
                    'createdAt': FieldValue.serverTimestamp(),
                  };

                  try {
                    // Guarda los datos en la colección `bookings`
                    await FirebaseFirestore.instance
                        .collection('bookings')
                        .add(bookingData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking successfully created.'),
                      ),
                    );

                    // Navegar a la pantalla de pago
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PaymentScreen(), // Implementa PaymentScreen
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving booking: $e'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceDetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
