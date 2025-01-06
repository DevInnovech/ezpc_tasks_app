import 'dart:convert';

import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/Map_Screen.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/reviewpop.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/single_expansion_tile.dart';
import 'package:ezpc_tasks_app/features/chat/data/chat_repository.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/button_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>
    with WidgetsBindingObserver {
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

  Future<void> addPendingFeedback(String clientId, String bookingId,
      Map<String, dynamic> bookingData) async {
    try {
      await FirebaseFirestore.instance
          .collection('pendingFeedbacks')
          .doc(clientId)
          .collection('feedbackList')
          .doc(bookingId)
          .set(bookingData); // Agrega los datos necesarios de la booking
    } catch (e) {
      debugPrint("Error adding pending feedback: $e");
    }
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
    final currentStep = stepLabels[taskStatus.toLowerCase()] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isCompleted = index <= currentStep;
          final isLast = index == steps.length - 1;

          return Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: index < currentStep || index == 1
                                    ? [Colors.blue, Colors.blue]
                                    : index == currentStep
                                        ? [Colors.blue, Colors.grey[300]!]
                                        : [
                                            Colors.grey[300]!,
                                            Colors.grey[300]!
                                          ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              isCompleted ? Colors.blue : Colors.grey[300],
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          steps[index],
                          style: TextStyle(
                            color: isCompleted ? Colors.blue : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (!isLast)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: index < currentStep
                                  ? const LinearGradient(
                                      colors: [Colors.blue, Colors.blue],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                  : index == currentStep
                                      ? LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.grey[300]!
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey[300]!,
                                            Colors.grey[300]!,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
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

  Future<Map<String, double>?> getCoordinatesFromAddress(
      String address, String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'latitude': location['lat'],
            'longitude': location['lng'],
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching coordinates: $e');
    }
    return null;
  }

  Widget _buildConditionalButton(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.order['bookingId'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final bookingData = snapshot.data!.data() as Map<String, dynamic>;
        final taskStatus = bookingData['status']?.toLowerCase() ?? 'pending';
        final providerStatus =
            bookingData['ProviderStatus']?.toLowerCase() ?? 'pending';

        if (taskStatus == "pending") {
          // Botones para aceptar o rechazar la tarea
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
        } else if (taskStatus == "accepted" && providerStatus != "arrived") {
          // Botón para navegar a la tarea (Drive to Task)
          return ElevatedButton(
            onPressed: () async {
              final String address =
                  widget.order['clientAddress'] ?? 'Unknown Address';
              final bookingId = widget.order['bookingId'];

              double latitude = widget.order['latitude'] ?? 0.0;
              double longitude = widget.order['longitude'] ?? 0.0;

              if (latitude == 0.0 && longitude == 0.0) {
                final coordinates = await getCoordinatesFromAddress(
                    address, 'AIzaSyAniwsNy7RlHjkeU8x_k44dPsw4isyK-d0');
                if (coordinates != null) {
                  latitude = coordinates['latitude']!;
                  longitude = coordinates['longitude']!;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to fetch location.')),
                  );
                  return;
                }
              }

              // Navegar al MapScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    latitude: latitude,
                    longitude: longitude,
                    address: address,
                    providerId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    bookingId: bookingId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              "Drive to Task",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        } else if (providerStatus == "arrived" && taskStatus == "accepted") {
          // Botón para iniciar la tarea (Start Task)
          return ElevatedButton(
            onPressed: () async {
              await _updateTaskStatus("in progress");

              await FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(widget.order['bookingId'])
                  .update({
                'ProviderStatus': 'in_progress',
                'updatedAt': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task has started!')),
              );
            },
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
          // Botón para completar la tarea (Complete Task)
          return ElevatedButton(
            onPressed: () async {
              await _updateTaskStatus("completed");

              await FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(widget.order['bookingId'])
                  .update({
                'ProviderStatus': 'completed',
                'updatedAt': FieldValue.serverTimestamp(),
              });
              addPendingFeedback(widget.order["customerId"],
                  widget.order["bookingId"], widget.order);
              showCompletionReviewPopup(context, widget.order,
                  isReviewingProvider: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              "Complete Task",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        } else if (taskStatus == "completed") {
          // Botón de soporte técnico
          return ElevatedButton(
            onPressed: () => _showTechnicalSupportOptions(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              "Technical Support",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
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
            // Extra Time Information Card
            _buildExtraTimeInfoCard(context, ref),

            // Conditional Buttons

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildButtonSection(context, ref),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildConditionalButton(context),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, WidgetRef ref) {
    final extraTimeRequested =
        ref.watch(extraTimeRequestedProvider(widget.order['bookingId']));

    // Ocultar botones si la tarea está en estado "pending" o "completed"
    if (taskStatus == 'pending' || taskStatus == 'completed') {
      return const SizedBox.shrink(); // Retorna un espacio vacío
    }

    // Si no es nulo, mostrar los botones correspondientes
    return Column(
      children: [
        // Botón de "Technical Support"
        EstadoButton(
          text: 'Technical Support',
          icon: Icons.support_agent,
          onPressed: () => _showTechnicalSupportOptions(context),
          enabled: true, // El botón está habilitado
          isActive: false, // El botón no tiene estado visual activo
          normalColor: const Color.fromARGB(255, 18, 139, 237),
          normalBorderColor: const Color.fromARGB(255, 15, 121, 208),
        ),

        const SizedBox(height: 10),

        // Botón de "Extra Time" con dos estados visuales
        EstadoButton(
          text: 'Extra Time',
          icon: Icons.access_time,
          onPressed: () =>
              _handleExtraTimeRequest(context, ref, widget.order["bookingId"]),
          enabled: true, // El botón está habilitado
          isActive:
              extraTimeRequested, // Cambia el estado visual según el valor de isRequested
          normalColor: primaryColor,
          activeColor: primaryColor, // Color si extraTimeRequested es true
          normalBorderColor: primaryColor,
          activeBorderColor: redColor, // Borde si extraTimeRequested es true
        ),

        const SizedBox(height: 10),

        // Botón de "Chat with Customer"
        EstadoButton(
          text: 'Chat with Customer',
          icon: Icons.chat,
          onPressed: () => _openChatWithCustomer(context),
          enabled: true, // El botón está habilitado
          isActive: false, // No necesita estado visual activo
          normalColor: primaryColor,
          normalBorderColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildExtraTimeInfoCard(BuildContext context, WidgetRef ref) {
    final extraTimeDetails =
        ref.watch(extraTimeDetailsProvider(widget.order['bookingId']));

    if (extraTimeDetails.status == "Accepted") {
      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Extra Time Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF404C8C),
                ),
              ),
              const SizedBox(height: 8),
              _buildPriceRow(
                  'Selected Duration', extraTimeDetails.selectedDuration),
              _buildPriceRow(
                  'Fee', '\$${extraTimeDetails.fee.toStringAsFixed(2)}'),
              _buildPriceRow('Time Slot', extraTimeDetails.selectedTimeSlot),
              _buildPriceRow('Reason', extraTimeDetails.reason),
            ],
          ),
        ),
      );
    }

    // Devuelve un espacio vacío si no está aceptado
    return const SizedBox.shrink();
  }

  // Implement the expandable section method
  Widget _buildExpandableSection(BuildContext context,
      {required String title, required Widget child}) {
    return SingleExpansionTile(
      heading: title,
      child: child,
    );
  }

  // Handle Extra Time Request
  void _handleExtraTimeRequest(
      BuildContext context, WidgetRef ref, String bookingId) async {
    try {
      // Fetch the booking data directly
      final bookingData = await ref.read(bookingDataProvider(bookingId).future);

      // Check if extra time is requested
      final extraTimeRequested = bookingData['extraTime'] != null;

      if (!extraTimeRequested) {
        // Open the dialog for choosing extra time
        _openExtraTimeDialog(context, ref, widget.order, bookingId);
      } else {
        // Show the status of the extra time request
        _openExtraTimeStatusPopup(context, ref, bookingId);
      }
    } catch (e) {
      debugPrint("Error handling extra time request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to fetch extra time request status.')),
      );
    }
  }

  void _openExtraTimeDialog(BuildContext context, WidgetRef ref,
      Map<String, dynamic> orderDetails, String bookingId) {
    final extraTimeDetails = ref.watch(extraTimeDetailsProvider(bookingId));

    // Obtener subcategorías
    final List<String> subCategories =
        List<String>.from(orderDetails['selectedSubCategories'] ?? []);
    final String taskId = orderDetails['taskId'];

    // Calcular los horarios disponibles
    final DateFormat timeFormat = DateFormat('hh:mm a');
    final DateTime baseTimeSlot = timeFormat.parse(orderDetails['timeSlot']);
    final Map<String, dynamic> serviceSizes =
        orderDetails['serviceSizes'] ?? {};
    final int serviceDuration =
        serviceSizes.values.whereType<int>().reduce((a, b) => a + b);
    final DateTime estimatedTime =
        baseTimeSlot.add(Duration(hours: serviceDuration));

    final List<String> availableTimeSlots = List.generate(
      5,
      (index) {
        final startTime = estimatedTime.add(Duration(hours: index));
        final endTime = startTime.add(const Duration(hours: 1));
        return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
      },
    );

    String selectedDuration = extraTimeDetails.selectedDuration;
    String selectedTimeSlot = extraTimeDetails.selectedTimeSlot;
    String selectedService = '';
    String reason = extraTimeDetails.reason;
    double fee = extraTimeDetails.fee;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String errorMessage = ''; // Variable para el mensaje de error

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Choose Extra Time',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      const SizedBox(height: 16),

                      // Dropdown para servicios
                      const Text('Select Service',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _fetchTaskPrices(subCategories, taskId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Error fetching task prices',
                                style: TextStyle(color: Colors.red));
                          }

                          final taskPrices = snapshot.data!;
                          return DropdownButton<String>(
                            value: selectedService.isNotEmpty
                                ? selectedService
                                : null,
                            isExpanded: true,
                            hint: const Text('Select Service'),
                            onChanged: (value) {
                              setState(() {
                                selectedService = value!;
                                fee = taskPrices[selectedService] ?? 0.0;
                              });
                            },
                            items: taskPrices.keys.map((String service) {
                              return DropdownMenuItem<String>(
                                value: service,
                                child: Text(service,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown para duración
                      const Text('Select Duration',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      DropdownButton<String>(
                        value: selectedDuration.isNotEmpty
                            ? selectedDuration
                            : null,
                        isExpanded: true,
                        hint: const Text('Select Duration'),
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value!;
                          });
                        },
                        items: ['1 Hour', '2 Hours', '3 Hours'].map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown para seleccionar horario
                      const Text('Select Time Slot',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      DropdownButton<String>(
                        value: selectedTimeSlot.isNotEmpty
                            ? selectedTimeSlot
                            : null,
                        isExpanded: true,
                        hint: const Text('Select Time Slot'),
                        onChanged: (value) {
                          setState(() {
                            selectedTimeSlot = value!;
                          });
                        },
                        items: availableTimeSlots.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                      // Campo de texto para motivo
                      const Text('Reason',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      TextField(
                        onChanged: (value) => reason = value,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter reason for extra time',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mensaje de error (si existe)
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Botón de enviar solicitud
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedDuration.isEmpty ||
                              selectedTimeSlot.isEmpty ||
                              selectedService.isEmpty ||
                              reason.isEmpty) {
                            setState(() {
                              if (selectedDuration.isEmpty &&
                                  selectedTimeSlot.isEmpty &&
                                  selectedService.isEmpty &&
                                  reason.isEmpty) {
                                errorMessage = 'All fields are required.';
                              } else if (selectedDuration.isEmpty) {
                                errorMessage = 'Please select a duration.';
                              } else if (selectedTimeSlot.isEmpty) {
                                errorMessage = 'Please select a time slot.';
                              } else if (selectedService.isEmpty) {
                                errorMessage = 'Please select a service.';
                              } else if (reason.isEmpty) {
                                errorMessage = 'Please provide a reason.';
                              }
                            });
                            return;
                          }

                          final extraTimeRequest = ExtraTimeDetails(
                            selectedDuration: selectedDuration,
                            selectedTimeSlot: selectedTimeSlot,
                            reason: reason,
                            fee: fee,
                          );
                          await sendExtraTimeRequest(bookingId,
                              extraTimeRequest, orderDetails['customerId']);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor),
                        child: const Text('Send Request',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchTaskPrices(
      List<String> subCategories, String taskid) async {
    final Map<String, dynamic> taskPrices = {};
    try {
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskid)
          .get();

      if (taskSnapshot.exists) {
        final taskData = taskSnapshot.data();

        for (String subCategory in subCategories) {
          if (taskData != null && taskData['selectedTasks'] != null) {
            final selectedTasks =
                taskData['selectedTasks'] as Map<String, dynamic>;
            taskPrices[subCategory] = selectedTasks[subCategory] ?? 0.0;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching task prices: $e");
    }
    return taskPrices;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> sendExtraTimeRequest(String bookingId,
      ExtraTimeDetails extraTimeDetails, String clientId) async {
    try {
      // Actualizar la información de extra time en la reserva
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'extraTime': {
          'selectedDuration': extraTimeDetails.selectedDuration,
          'selectedTimeSlot': extraTimeDetails.selectedTimeSlot,
          'reason': extraTimeDetails.reason,
          'status': 'Pending',
          'fee': extraTimeDetails.fee,
        },
      });

      // Registrar la notificación interna en Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'extra_time_request',
        'bookingId': bookingId,
        'message': 'You have a new extra time request.',
        'status': 'unread',
        'clientId': clientId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ref.refresh(bookingDataProvider(bookingId));
      debugPrint("Extra time request sent successfully.");
    } catch (e) {
      debugPrint("Error sending extra time request: $e");
    }
  }

  // Status Popup for extra time request
  void _openExtraTimeStatusPopup(
      BuildContext context, WidgetRef ref, String bookingId) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to load extra time status.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            final extraTimeData = (snapshot.data!.data()
                    as Map<String, dynamic>?)?['extraTime'] ??
                {};
            final String selectedDuration =
                extraTimeData['selectedDuration'] ?? 'Not specified';
            final String selectedTimeSlot =
                extraTimeData['selectedTimeSlot'] ?? 'Not specified';
            final String status = extraTimeData['status'] ?? 'Pending';
            final double fee = extraTimeData['fee']?.toDouble() ?? 0.0;

            final bool isAccepted = status == 'Accepted';
            final bool isCancelled = status == 'Cancelled';
            final bool isDeclined = status == 'Declined';
            final bool canCancel = !isAccepted && !isCancelled && !isDeclined;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text(
                'Extra Time Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow('Duration:', selectedDuration),
                  const SizedBox(height: 8),
                  _buildStatusRow('Time Slot:', selectedTimeSlot),
                  const SizedBox(height: 8),
                  _buildStatusRow('Fee:', '\$$fee'),
                  const SizedBox(height: 8),
                  _buildStatusRow('Status:', status),
                  const SizedBox(height: 12),
                  if (isAccepted)
                    const Text(
                      'Your request has been accepted.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isCancelled)
                    const Text(
                      'Your request was cancelled.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              actions: [
                if (canCancel)
                  TextButton(
                    onPressed: () async {
                      await _cancelExtraTimeRequest(context, bookingId);
                    },
                    child: const Text(
                      'Cancel Request',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Future<void> _cancelExtraTimeRequest(
      BuildContext context, String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'extraTime.status': 'Cancelled',
        'extraTime.cancelledAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Cierra el popup actual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Extra time request has been cancelled.')),
      );
    } catch (e) {
      debugPrint('Error cancelling extra time request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel extra time request.'),
        ),
      );
    }
  }

  Future<void> deleteAllChatRooms() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final chatRoomsSnapshot = await firestore.collection('chats').get();

      for (var chatRoomDoc in chatRoomsSnapshot.docs) {
        final chatRoomId = chatRoomDoc.id;

        // Elimina los mensajes asociados en la subcolección 'messages'
        final messagesSnapshot = await firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .get();

        for (var messageDoc in messagesSnapshot.docs) {
          await firestore
              .collection('chats')
              .doc(chatRoomId)
              .collection('messages')
              .doc(messageDoc.id)
              .delete();
        }

        // Elimina la sala de chat
        await firestore.collection('chats').doc(chatRoomId).delete();
      }

      print("Todas las salas de chat y sus mensajes han sido eliminados.");
    } catch (e) {
      print("Error al eliminar las salas de chat: $e");
    }
  }

  // Show Technical Support Options
  void _showTechnicalSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Message Option
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      Navigator.pop(context);
                      openSupportChat(context);
                    },
                  ),
                  const Text('Message'),
                ],
              ),
              // Call Option
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      // Open phone dialer
                      Navigator.pop(context);
                      makePhoneCall(
                          'tel:+1234567890'); // Replace with support number
                    },
                  ),
                  const Text('Call'),
                ],
              ),
              // Email Option
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.email),
                    onPressed: () {
                      // Open email client
                      Navigator.pop(context);
                      sendEmail(
                          'support@example.com'); // Replace with support email
                    },
                  ),
                  const Text('Email'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Open chat with customer
// Open chat with customer
  // Open chat with customer
  void _openChatWithCustomer(BuildContext context) async {
    final clientId = widget.order['customerId']; // ID del cliente
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    final orderId = widget.order['bookingId']; // ID de la orden (o bookingId)

    if (clientId == null || providerId == null || orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start chat: Missing IDs')),
      );
      return;
    }

    final chatRoomId = _generateChatRoomId(clientId, providerId, orderId);

    try {
      // Crear o actualizar la sala de chat
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chats').doc(chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        // Crear la sala de chat si no existe
        await chatRoomRef.set({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'customerId': clientId,
          'providerId': providerId,
          'orderId': orderId, // Asociar la sala de chat con el orderId
          'unreadCounts': {}, // Inicializar contadores de no leídos
          'onlineUsers': [], // Inicializar usuarios en línea
        });
      } else {
        // Verificar y agregar el orderId si falta
        final chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>;
        if (!chatRoomData.containsKey('orderId')) {
          await chatRoomRef.update({'orderId': orderId});
        }
      }

      // Navegar a la pantalla de chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerChatScreen(
            chatRoomId: chatRoomId,
            customerId: clientId,
            providerId: providerId,
            orderId: orderId, // Pasar el orderId a la pantalla de chat
            isFakeData: false,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
      print('Error opening chat: $e');
    }
  }

  String _generateChatRoomId(
      String customerId, String providerId, String orderId) {
    return '${_generateChatRoomIdForUsers(customerId, providerId)}_$orderId';
  }

  String _generateChatRoomIdForUsers(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }

  double calculateFee(String selectedDuration, double prices) {
    final hours = int.tryParse(selectedDuration.split(' ')[0]) ?? 0;
    return hours * prices * 0.1;
  }
}

void openSupportChat(BuildContext context) {
  Navigator.pushNamed(
    context,
    RouteNames
        .supportChatScreen, // Usa el nombre de ruta adecuado para SupportChatScreen
    arguments: {
      'chatRoomId':
          'supportChatRoomId', // ID del chat de soporte, puede ser único
      'userId': FirebaseAuth.instance.currentUser?.uid ??
          'guest_user', // ID del usuario actual o 'guest_user'
    },
  );
}

// Make a phone call
Future<void> makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    // Handle error
  }
}

// Send an email
Future<void> sendEmail(String email) async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: email,
    query: '', // Add subject and body if needed
  );
  String url = params.toString();
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    // Handle error
  }
}
