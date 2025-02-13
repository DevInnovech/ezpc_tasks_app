import 'dart:convert';

import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/Map_Screen.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/reviewpop.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/single_expansion_tile.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/features/notification/send.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/button_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  Future<void> _updateTaskStatus(
    String newStatus, {
    String? slot, // Opcional
    String? endSlot, // Opcional
  }) async {
    try {
      // Convertir la fecha del widget a un objeto DateTime
      final String dateStr = widget.order['date'];
      final DateTime currentDate = DateTime.parse(dateStr);

      final String bookingId = widget.order['bookingId'];
      final String providerId = widget.order['providerId'];

      DateTime? startTime;
      DateTime? endTime;

      print("Procesando actualización de estado...");
      print("Slot de inicio: $slot");
      print("Slot de fin: $endSlot");

      // Procesar los slots solo si están disponibles
      if (slot != null) {
        startTime = _parseTime(slot);
        print("Hora de inicio parseada: $startTime");
      }

      if (startTime != null && endSlot != null) {
        endTime = _parseTime(endSlot);
        print("Hora de fin parseada: $endTime");
      } else if (startTime != null &&
          widget.order.containsKey('serviceSizes')) {
        endTime = startTime.add(Duration(
            minutes: (widget.order['serviceSizes']['Hours'] * 60).toInt()));
        print("Hora de fin calculada: $endTime");
      }

      final DocumentReference providerRef =
          FirebaseFirestore.instance.collection('providers').doc(providerId);

      // Actualizar el estado de la reserva
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      // Obtener el nombre del día y la fecha formateada
      final String dayName =
          DateFormat('EEEE').format(currentDate); // e.g., "Monday"
      final String formattedDate =
          DateFormat('M-d-yyyy').format(currentDate); // e.g., "1/7/2025"

      if (newStatus == "accepted" && startTime != null && endTime != null) {
        print("Actualizando disponibilidad para estado 'accepted'...");

        // Generar intervalos ocupados con taskId
        final List<Map<String, dynamic>> occupiedIntervals =
            _generateIntervals(startTime, endTime).map((interval) {
          return {
            'start': interval['start'],
            'end': interval['end'],
            'status': 'occupied',
            'taskId': bookingId, // Añadir taskId
          };
        }).toList();
        print(occupiedIntervals);

        // Generar intervalos bloqueados con taskId
        final List<Map<String, dynamic>> blockedIntervals = _generateIntervals(
          endTime,
          endTime.add(Duration(
              minutes: (widget.order['serviceSizes']['Hours'] * 60).toInt())),
        ).map((interval) {
          return {
            'start': interval['start'],
            'end': interval['end'],
            'status': 'blocked',
            'taskId': bookingId, // Añadir taskId
          };
        }).toList();
        print(blockedIntervals);

        // Actualizar la disponibilidad del proveedor con la clave específica del día y fecha
        await providerRef.update({
          'availability.$dayName.$formattedDate': FieldValue.arrayUnion([
            ...occupiedIntervals,
            ...blockedIntervals,
          ]),
        });
      } else if ((newStatus == "completed" || newStatus == "canceled") &&
          startTime != null &&
          endTime != null) {
        print("Actualizando disponibilidad para estado '$newStatus'...");

        // Generar intervalos ocupados y bloqueados para eliminar
        final List<Map<String, dynamic>> occupiedIntervalsToRemove =
            _generateIntervals(startTime, endTime).map((interval) {
          return {
            'start': interval['start'],
            'end': interval['end'],
            'status': 'occupied',
            'taskId': bookingId, // Añadir taskId para eliminar correctamente
          };
        }).toList();

        final List<Map<String, dynamic>> blockedIntervalsToRemove =
            _generateIntervals(
          endTime,
          endTime.add(Duration(
              minutes: (widget.order['serviceSizes']['Hours'] * 60).toInt())),
        ).map((interval) {
          return {
            'start': interval['start'],
            'end': interval['end'],
            'status': 'blocked',
            'taskId': bookingId, // Añadir taskId
          };
        }).toList();

        print(
            "Intervalos a eliminar: $occupiedIntervalsToRemove y $blockedIntervalsToRemove");

        // Actualizar la disponibilidad del proveedor con la clave específica del día y fecha
        await providerRef.update({
          'availability.$dayName.$formattedDate': FieldValue.arrayRemove([
            ...occupiedIntervalsToRemove,
            ...blockedIntervalsToRemove,
          ]),
        });

        // Llamar a la función secundaria para registrar el rendimiento del proveedor
        await _updateProviderPerformance(
          providerId,
          currentDate,
          newStatus,
          bookingId,
          widget.order,
        );
      }

      // Actualizar el estado local de la tarea
      setState(() {
        taskStatus = newStatus.toLowerCase();
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status updated to $newStatus')),
      );
    } catch (e) {
      debugPrint("Error updating task status: $e");
      // Mostrar mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update task status')),
      );
    }
  }

  Future<void> _updateProviderPerformance(
    String providerId,
    DateTime currentDate,
    String newStatus,
    String bookingId,
    Map<String, dynamic> order,
  ) async {
    try {
      final String currentMonth = DateFormat('yyyy-MM').format(currentDate);

      final DocumentReference providerRef =
          FirebaseFirestore.instance.collection('providers').doc(providerId);

      final providerDoc = await providerRef.get();

      if (!providerDoc.exists) {
        debugPrint("Provider document not found.");
        return;
      }

      // Verificar y convertir el campo 'performance' a un mapa
      final Map<String, dynamic> providerData =
          providerDoc.data() as Map<String, dynamic>;

      Map<String, dynamic> performanceData =
          (providerData['performance'] as Map<String, dynamic>?) ?? {};

      // Obtener los datos del mes actual o inicializar
      Map<String, dynamic> monthlyPerformance =
          performanceData[currentMonth] as Map<String, dynamic>? ??
              {
                'completed': 0,
                'canceled': 0,
                'reschedules': 0,
              };

      if (newStatus == "completed") {
        monthlyPerformance['completed'] += 1;

        // Verificar si es un reprogramado
        bool isRescheduled =
            await _checkIfRescheduled(providerId, bookingId, order);
        if (isRescheduled) {
          monthlyPerformance['reschedules'] += 1;
        }
      } else if (newStatus == "canceled") {
        monthlyPerformance['canceled'] += 1;
      }

      // Actualizar los datos del mes actual en el rendimiento del proveedor
      performanceData[currentMonth] = monthlyPerformance;

      // Guardar los datos actualizados en el documento del proveedor
      await providerRef.update({
        'performance': performanceData,
      });

      debugPrint("Provider performance updated: $performanceData");
    } catch (e) {
      debugPrint("Error updating provider performance: $e");
    }
  }

  Future<bool> _checkIfRescheduled(
    String providerId,
    String currentBookingId,
    Map<String, dynamic> order,
  ) async {
    try {
      final customerId = order['customerId'];
      final selectedTaskName = order['selectedTaskName'];

      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('customerId', isEqualTo: customerId)
          .where('selectedTaskName', isEqualTo: selectedTaskName)
          .where('status', isEqualTo: 'completed')
          .get();

      for (var booking in bookingsQuery.docs) {
        if (booking.id != currentBookingId) {
          return true; // Es reprogramado
        }
      }

      return false;
    } catch (e) {
      debugPrint("Error checking if task is rescheduled: $e");
      return false;
    }
  }

  List<Map<String, dynamic>> _generateIntervals(DateTime start, DateTime end) {
    final intervals = <Map<String, dynamic>>[];

    var currentTime = start;
    while (currentTime.isBefore(end)) {
      final nextTime = currentTime.add(const Duration(minutes: 30));
      intervals.add({
        'start':
            DateFormat('hh:mm a').format(currentTime), // Cambio a 'hh:mm a'
        'end': DateFormat('hh:mm a').format(nextTime), // Cambio a 'hh:mm a'
      });
      currentTime = nextTime;
    }

    return intervals;
  }

  DateTime? _parseTime(String time) {
    try {
      return DateFormat('hh:mm a').parse(time);
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return null;
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

  Widget _buildConditionalButtone(BuildContext context) {
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
          final String? slot = bookingData['timeSlot'];
          final String? endslot = bookingData['endSlot'];
          final providerStatus =
              bookingData['ProviderStatus']?.toLowerCase() ?? 'pending';

          return ElevatedButton(
            onPressed: () async {
// Obtener el token del usuario
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(bookingData['customerId'])
                  .get();

              if (userDoc.exists) {
                String? userToken = userDoc.data()?['fcmToken'];

                if (userToken != null) {
                  EasyLoading.show();
                  SendNotification.sendNotificationToUser(
                      //"fHQ7_j7nRpu-1I-PacmMoC:APA91bH9gHFDQjsAS4A4ZQ15of1_AgGzIoyIm4gGA5WGnIHd2q4utYyMcOg4uWo94CdIie97QXA4JWs8UJiIe5IqBxhZLEVBSm4Iop-rwIN2Lcd8_AZWI_A",
                      userToken,
                      "Task Started",
                      "Your task has been marked as 'In Progress'.",
                      {
                        'bookingId': widget.order['bookingId'],
                        'status': 'in_progress',
                      }); // Enviar notificación
                  EasyLoading.dismiss();
                } else {
                  print("❌ No se encontró el token FCM del usuario.");
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task has started!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              "Send",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        });
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
        final String? slot = bookingData['timeSlot'];
        final String? endslot = bookingData['endSlot'];
        final providerStatus =
            bookingData['ProviderStatus']?.toLowerCase() ?? 'pending';

        if (taskStatus == "pending") {
          // Botones para aceptar o rechazar la tarea
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateTaskStatus("accepted",
                      slot: slot, endSlot: endslot),
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

// Obtener el token del usuario
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(bookingData['customerId'])
                  .get();

              if (userDoc.exists) {
                String? userToken = userDoc.data()?['fcmToken'];

                if (userToken != null) {
                  EasyLoading.show();
                  SendNotification.sendNotificationToUser(
                      //"fHQ7_j7nRpu-1I-PacmMoC:APA91bH9gHFDQjsAS4A4ZQ15of1_AgGzIoyIm4gGA5WGnIHd2q4utYyMcOg4uWo94CdIie97QXA4JWs8UJiIe5IqBxhZLEVBSm4Iop-rwIN2Lcd8_AZWI_A",
                      userToken,
                      "Task Started",
                      "Your task has been marked as 'In Progress'.",
                      {
                        'bookingId': widget.order['bookingId'],
                        'status': 'in_progress',
                      }); // Enviar notificación
                  EasyLoading.dismiss();
                } else {
                  print("❌ No se encontró el token FCM del usuario.");
                }
              }

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
              await _updateTaskStatus("completed",
                  slot: slot, endSlot: endslot);

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
                  Text(
                      "Time: ${widget.order['timeSlot'] ?? 'N/A'}-${widget.order['endSlot'] ?? ''}"),
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
            /*   Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildConditionalButtone(context),
            ),*/
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
          onPressed: () => taskStatus == 'in progress'
              ? _handleExtraTimeRequest(context, ref, widget.order["bookingId"])
              : null,
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
      final bookingData = await ref.read(bookingDataProvider(bookingId).future);
      final extraTimeData = bookingData['extraTime'] ?? {};
      final int rejectionCount = extraTimeData['rejectionCount'] ?? 0;
      final bool extraTimeRequested = extraTimeData.isNotEmpty;

      if (!extraTimeRequested ||
          (extraTimeData['status'] == 'Declined' && rejectionCount < 2)) {
        _openExtraTimeDialog(context, ref, widget.order, bookingId);
      } else {
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
    final int maxHours =
        serviceDuration; // Valor máximo de horas basado en la orden

    // Generar duraciones dinámicas (1 hora hasta el máximo de horas)
    final List<String> availableDurations = List.generate(
      maxHours,
      (index) => '${index + 1} Hour${index + 1 > 1 ? 's' : ''}',
    );

    // Generar slots de tiempo dinámicos
    final List<String> availableTimeSlots = List.generate(
      maxHours,
      (index) {
        final startTime =
            baseTimeSlot.add(Duration(hours: serviceDuration + index));
        final endTime = startTime.add(const Duration(hours: 1));
        return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
      },
    );

    // Seleccionar automáticamente la subcategoría si es única
    String selectedService =
        subCategories.length == 1 ? subCategories.first : '';
    String selectedDuration = extraTimeDetails.selectedDuration;
    String selectedTimeSlot = extraTimeDetails.selectedTimeSlot;
    String reason = extraTimeDetails.reason;
    double fee = extraTimeDetails.fee;

    Map<String, dynamic> taskPricestemp = {};

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
                          taskPricestemp = taskPrices;
                          // Si hay una sola subcategoría, asignar su precio automáticamente
                          if (subCategories.length == 1) {
                            selectedService = subCategories.first;
                            fee = double.parse(
                                    taskPrices[selectedService].toString()) *
                                (availableDurations.indexOf(selectedDuration) +
                                    1);
                          }

                          return DropdownButton<String>(
                            value: selectedService.isNotEmpty
                                ? selectedService
                                : null,
                            isExpanded: true,
                            hint: const Text('Select Service'),
                            onChanged: subCategories.length == 1
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedService = value!;
                                      fee = double.parse(
                                              taskPrices[selectedService]
                                                  .toString()) *
                                          (availableDurations
                                                  .indexOf(selectedDuration) +
                                              1);
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
                            fee = double.parse(taskPricestemp[selectedService]
                                    .toString()) *
                                (availableDurations.indexOf(value) + 1);
                          });
                        },
                        items: availableDurations.map((value) {
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
                      const SizedBox(height: 16),

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
                              errorMessage = 'All fields are required.';
                            });
                            return;
                          }

                          bool confirmRequest = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              title: const Text('Confirm Extra Time Request',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Duration: $selectedDuration'),
                                  Text('Time Slot: $selectedTimeSlot'),
                                  Text('Reason: $reason'),
                                  Text('Fee: \$${fee.toStringAsFixed(2)}'),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Are you sure you want to submit this request?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );

                          if (!confirmRequest) return;

                          final extraTimeRequest = ExtraTimeDetails(
                            selectedDuration: selectedDuration,
                            selectedTimeSlot: selectedTimeSlot,
                            reason: reason,
                            fee: fee,
                          );

                          await sendExtraTimeRequest(context, bookingId,
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
            print(taskPrices[subCategory]);
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

  Future<void> sendExtraTimeRequest(BuildContext context, String bookingId,
      ExtraTimeDetails extraTimeDetails, String clientId) async {
    try {
      // Mostrar confirmación antes de enviar
      bool confirmRequest = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Confirm Extra Time Request',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Duration: ${extraTimeDetails.selectedDuration}'),
              Text('Time Slot: ${extraTimeDetails.selectedTimeSlot}'),
              Text('Reason: ${extraTimeDetails.reason}'),
              Text('Fee: \$${extraTimeDetails.fee.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to submit this request?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (!confirmRequest) return;

      // Obtener estado actual
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();
      final bookingData = bookingSnapshot.data() ?? {};
      final extraTimeData = bookingData['extraTime'] ?? {};
      final int rejectionCount = extraTimeData['rejectionCount'] ?? 0;
      final String currentStatus = extraTimeData['status'] ?? '';

      // Permitir solo dos envíos en caso de rechazo
      if (currentStatus == 'Declined' && rejectionCount >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('You have reached the maximum attempts for extra time.'),
          ),
        );
        return;
      }

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
          'rejectionCount':
              currentStatus == 'Declined' ? rejectionCount + 1 : 0,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Extra time request sent successfully.')),
      );
    } catch (e) {
      debugPrint("Error sending extra time request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send extra time request.')),
      );
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
            final int rejectionCount = extraTimeData['rejectionCount'] ?? 0;

            final bool isAccepted = status == 'Accepted';
            final bool isCancelled = status == 'Cancelled';
            final bool isDeclined = status == 'Declined';
            final bool canCancel = !isAccepted && !isCancelled && !isDeclined;
            final bool canRetry = isCancelled && rejectionCount < 2;

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
                  if (isCancelled && canRetry)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'You can submit one more extra time request.',
                        style: TextStyle(color: Colors.blueGrey),
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
                if (canRetry)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _openExtraTimeDialog(
                          context, ref, widget.order, bookingId);
                    },
                    child: const Text('Retry Request'),
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
