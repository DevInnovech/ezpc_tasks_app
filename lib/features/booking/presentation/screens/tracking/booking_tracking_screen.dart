import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/tracking/open_maps.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/booking_details_component.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/single_expansion_tile.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/SupportChatScreen.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/button_state.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

// Import your chat screen

class BookingTrackingScreen extends ConsumerStatefulWidget {
  const BookingTrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  _BookingTrackingScreenState createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends ConsumerState<BookingTrackingScreen>
    with WidgetsBindingObserver {
  // Agregamos una variable para controlar si hemos abierto el mapa
  bool hasOpenedMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detectamos cuando la aplicación vuelve al primer plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && hasOpenedMap) {
      // Actualizamos el estado al regresar de la aplicación de mapas
      setState(() {
        hasOpenedMap = false; // Reseteamos la bandera
        // Si estamos en el estado 'started', cambiamos el estado interno para que el botón muestre 'Start Task'
        final serviceState = ref.read(serviceStateProvider);
        if (serviceState == ServiceState.started) {
          hasOpenedMap = true;
          // No cambiamos el estado del servicio, solo forzamos la reconstrucción
          // El botón tomará el texto correcto basado en el estado actual
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingDetailsProvider(widget.bookingId));
    final serviceState = ref.watch(serviceStateProvider);

    Widget buildTrackingActionButton(
        BuildContext context, WidgetRef ref, ServiceState serviceState) {
      String buttonText = 'Start';
      bool isButtonEnabled = true;

      // Actualiza el texto del botón basado en el estado actual
      if (serviceState == ServiceState.initial) {
        buttonText = 'Start';
      } else if (serviceState == ServiceState.started) {
        // Si hemos abierto el mapa, cambiamos el texto a 'Start Task'
        buttonText = hasOpenedMap ? 'Start Task' : 'Drive to Destination';
      } else if (serviceState == ServiceState.inProgress) {
        buttonText = 'Complete Task';
      } else if (serviceState == ServiceState.completed) {
        buttonText = 'Completed';
        isButtonEnabled = false; // Deshabilita el botón
      }

      return PrimaryButton(
        onPressed: isButtonEnabled
            ? () async {
                if (serviceState == ServiceState.initial) {
                  // Transición a "Started"
                  ref.read(serviceStateProvider.notifier).state =
                      ServiceState.started;
                } else if (serviceState == ServiceState.started) {
                  if (!hasOpenedMap) {
                    // Abrimos el mapa y marcamos que lo hemos abierto
                    final bookingDetails = ref
                        .read(bookingDetailsProvider(widget.bookingId))
                        .maybeWhen(
                          data: (details) => details,
                          orElse: () => null,
                        );

                    if (bookingDetails != null) {
                      final address = bookingDetails.bookingAddress.address;
                      await launchMaps(context, address); // Abre el mapa
                      setState(() {
                        hasOpenedMap =
                            true; // Indicamos que el mapa ha sido abierto
                      });
                    }
                  } else {
                    // Cambiamos a "inProgress" cuando se presiona "Start Task"
                    ref.read(serviceStateProvider.notifier).state =
                        ServiceState.inProgress;
                    setState(() {
                      hasOpenedMap = false; // Reseteamos la bandera
                    });
                  }
                } else if (serviceState == ServiceState.inProgress) {
                  // Transición a "Completed" cuando la tarea se complete
                  ref.read(serviceStateProvider.notifier).state =
                      ServiceState.completed;
                  _showCompletionReviewPopup(context);
                }
              }
            : null,
        text: buttonText,
        enabled: isButtonEnabled,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Your Booking',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
      ),
      body: bookingState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (bookingDetails) =>
            _buildTrackingDetails(context, ref, bookingDetails),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildTrackingActionButton(context, ref, serviceState),
      ),
    );
  }

  // Building the buttons below
// Actualización de los botones utilizando EstadoButton

  Widget _buildButtonSection(BuildContext context, WidgetRef ref) {
    final extraTimeRequested = ref.watch(extraTimeRequestedProvider);

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
          //  activeColor: Colors.green,
          normalBorderColor: const Color.fromARGB(255, 15, 121, 208),
          // activeBorderColor: Colors.greenAccent,
        ),

        const SizedBox(height: 10),

        // Botón de "Extra Time" con dos estados visuales
        EstadoButton(
          text: 'Extra Time',
          icon: Icons.access_time,
          onPressed: () => _handleExtraTimeRequest(context, ref),
          enabled: true, // El botón está habilitado
          isActive:
              extraTimeRequested, // Cambia el estado visual si ya se ha solicitado extra time
          normalColor: primaryColor,
          //activeShadowColor: redColor,
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
          // activeColor: Colors.green,
          normalBorderColor: primaryColor,
          //   activeBorderColor: Colors.greenAccent,
        ),
      ],
    );
  }

  // Function to build booking details with the additional sections
  Widget _buildTrackingDetails(
      BuildContext context, WidgetRef ref, BookingDetailsDto bookingDetails) {
    final headingText = [
      'Included Service',
      'Booking Information',
      'Client Details',
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleExpansionTile(
            heading: headingText[0],
            isExpand: true,
            child: IncludeService(service: bookingDetails),
          ),
          SingleExpansionTile(
            heading: headingText[1],
            child: BookingDetailsAddress(service: bookingDetails),
          ),
          SingleExpansionTile(
            heading: headingText[2],
            child: ClientInformation(service: bookingDetails),
          ),
          // Existing expandable sections, now add Service State and Bill Details
          _buildExpandableSection(
            context,
            title: 'Bill Details',
            child: _buildBillDetails(bookingDetails),
          ),
          _buildExpandableSection(
            context,
            title: 'Service State',
            child: _buildServiceState(ref),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: _buildButtonSection(context, ref),
          ),
        ],
      ),
    );
  }

  // Building the service state section
  Widget _buildServiceState(WidgetRef ref) {
    final serviceState = ref.watch(serviceStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckboxListTile(
          title: 'Started',
          value: serviceState.index >= ServiceState.started.index,
          onChanged: (bool? value) {
            // Do nothing, only display
          }, // Prevent direct state change
          activeColor: Colors.blue,
        ),
        CustomCheckboxListTile(
          title: 'In Progress',
          value: serviceState.index >= ServiceState.inProgress.index,
          onChanged: (bool? value) {
            // Do nothing, only display
          }, // Prevent direct state change
          activeColor: Colors.blue,
        ),
        CustomCheckboxListTile(
          title: 'Completed',
          value: serviceState == ServiceState.completed,
          onChanged: (bool? value) {
            // Do nothing, only display
          }, // Prevent direct state change
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  // Build Bill Details section
  Widget _buildBillDetails(BookingDetailsDto bookingDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBillItem('Package Fee', bookingDetails.orders.totalAmount),
        _buildBillItem('Extra Service', bookingDetails.orders.additionalAmount),
        const Divider(),
        _buildBillItem(
            'Total Amount',
            bookingDetails.orders.totalAmount +
                bookingDetails.orders.additionalAmount),
      ],
    );
  }

  Widget _buildBillItem(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, fontSize: 16, fontWeight: FontWeight.w500),
        CustomText(
            text: '\$$amount', fontSize: 16, fontWeight: FontWeight.w500),
      ],
    );
  }

  // Main action button that changes state
// Main action button that changes state

  // Method to show completion review popup
  void _showCompletionReviewPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Implement your review dialog here
        return AlertDialog(
          title: const Text('Task Completed'),
          content: const Text('Please leave a review.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
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
  void _handleExtraTimeRequest(BuildContext context, WidgetRef ref) {
    final extraTimeRequested = ref.read(extraTimeRequestedProvider);

    if (!extraTimeRequested) {
      // Open the popup for choosing extra time
      _openExtraTimeDialog(context, ref);
    } else {
      // Show the status of the extra time request
      _openExtraTimeStatusPopup(context, ref);
    }
  }

  // Dialog for requesting extra time
  void _openExtraTimeDialog(BuildContext context, WidgetRef ref) {
    final extraTimeDetails = ref.read(extraTimeDetailsProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedDuration = extraTimeDetails.selectedDuration;
        String selectedTimeSlot = extraTimeDetails.selectedTimeSlot;
        String reason = extraTimeDetails.reason;

        return AlertDialog(
          title: const Text('Choose Extra Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedDuration.isNotEmpty ? selectedDuration : null,
                hint: const Text('Select Duration'),
                onChanged: (value) {
                  selectedDuration = value!;
                },
                items: <String>['1 Hour', '2 Hours', '3 Hours']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedTimeSlot.isNotEmpty ? selectedTimeSlot : null,
                hint: const Text('Select Time Slot'),
                onChanged: (value) {
                  selectedTimeSlot = value!;
                },
                items: <String>['2:00 PM - 3:00 PM', '4:00 PM - 5:00 PM']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                onChanged: (value) => reason = value,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter reason for extra time',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save extra time details and mark request as made
                extraTimeDetails.selectedDuration = selectedDuration;
                extraTimeDetails.selectedTimeSlot = selectedTimeSlot;
                extraTimeDetails.reason = reason;

                ref.read(extraTimeDetailsProvider.notifier).state =
                    extraTimeDetails;
                ref.read(extraTimeRequestedProvider.notifier).state = true;

                Navigator.pop(context);
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  // Status Popup for extra time request
  void _openExtraTimeStatusPopup(BuildContext context, WidgetRef ref) {
    final extraTimeDetails = ref.watch(extraTimeDetailsProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Extra Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Time Requested:'),
                  Text(extraTimeDetails.selectedDuration),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:'),
                  Text(extraTimeDetails.status),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fee:'),
                  Text('\$${extraTimeDetails.fee}'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                // Cancel extra time request
                ref.read(extraTimeRequestedProvider.notifier).state = false;
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
                      _openSupportChat(context);
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
  void _openChatWithCustomer(BuildContext context) {
    Navigator.pushNamed(
      context,
      RouteNames
          .customerChatScreen, // Usa el nombre de ruta adecuado para CustomerChatScreen
      arguments: {
        'chatRoomId':
            'chat_room_id', // Reemplaza con el ID de la sala de chat real
        'customerId': 'customer_id', // Reemplaza con el ID del cliente real
        'providerId': 'provider_id', // Reemplaza con el ID del proveedor real
        'isFakeData': true,
      },
    );
  }

  void _openSupportChat(BuildContext context) {
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
}
