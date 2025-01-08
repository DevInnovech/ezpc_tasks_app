import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart'; // Para el skeleton loader

class ProviderCalendarScreen extends StatefulWidget {
  const ProviderCalendarScreen({Key? key}) : super(key: key);

  @override
  _ProviderCalendarScreenState createState() => _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState extends State<ProviderCalendarScreen> {
  late Map<String, Map<String, List<Map<String, dynamic>>>> _events;
  late DateTime _selectedDate;
  late String _selectedDateKey;
  late String _selectedDayKey;
  List<Map<String, dynamic>> _bookingsDetails = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDate = DateTime.now();
    _selectedDateKey = _formatDateKey(_selectedDate);
    _selectedDayKey = _formatDayKey(_selectedDate);
    _fetchAvailability();
  }

  String _formatDateKey(DateTime date) {
    return "${date.month}-${date.day}-${date.year}";
  }

  String _formatDayKey(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  Future<void> _fetchAvailability() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("No provider logged in.");
        return;
      }

      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .get();

      if (!providerDoc.exists) {
        debugPrint("No availability data found for the provider.");
        return;
      }

      final availability =
          providerDoc.data()?['availability'] as Map<String, dynamic>? ?? {};

      setState(() {
        _events = availability.map((dayKey, dateMap) {
          final dateMapCasted = dateMap as Map<String, dynamic>;
          return MapEntry(
            dayKey,
            dateMapCasted.map((dateKey, bookings) {
              final bookingsList = List<Map<String, dynamic>>.from(bookings);
              return MapEntry(dateKey, bookingsList);
            }),
          );
        });
      });

      // Cargar tareas del día actual automáticamente
      _loadBookingsForSelectedDate();
      debugPrint("Events loaded: $_events");
    } catch (e) {
      debugPrint("Error fetching availability: $e");
    }
  }

  void _loadBookingsForSelectedDate() {
    final bookings = _events[_selectedDayKey]?[_selectedDateKey] ?? [];
    final bookingIds =
        bookings.map((booking) => booking['taskId'].toString()).toList();

    // Limpia los detalles antes de cargar nuevas tareas
    setState(() {
      _bookingsDetails = [];
      _isLoading = true; // Muestra el skeleton loader
    });

    if (bookingIds.isEmpty) {
      // Si no hay tareas, detén la carga y deja la lista vacía
      setState(() {
        _isLoading = false;
        _bookingsDetails = [];
      });
      return;
    }

    debugPrint(
        "Booking IDs for $_selectedDayKey -> $_selectedDateKey: $bookingIds");

    _fetchBookingDetails(bookingIds);
  }

  Future<void> _fetchBookingDetails(List<String> bookingIds) async {
    try {
      if (bookingIds.isEmpty) return;

      final bookingDocs = await FirebaseFirestore.instance
          .collection('bookings')
          .where(FieldPath.documentId, whereIn: bookingIds)
          .get();

      setState(() {
        _bookingsDetails = bookingDocs.docs.map((doc) {
          return {
            'bookingId': doc.id,
            ...doc.data(),
          };
        }).toList();
        _isLoading = false; // Detén el skeleton loader
      });

      debugPrint("Booking details loaded: $_bookingsDetails");
    } catch (e) {
      debugPrint("Error fetching booking details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booked Tasks',
          style: TextStyle(
            color: primaryColor, // Color del texto de hoy
            fontWeight: FontWeight.bold, // Para que resalte más
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(
                10), // Agrega margen alrededor del calendario
            padding: const EdgeInsets.symmetric(
                vertical: 10), // Opcional, para separación interna
            decoration: BoxDecoration(
              color: Colors.white, // Color de fondo del calendario
              borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Sombra sutil
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Desplazamiento de la sombra
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _selectedDate,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Oculta el botón "2 weeks"
                titleCentered: true, // Centra el título del mes
                titleTextStyle: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: primaryColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: primaryColor,
                ),
              ),
              eventLoader: (date) {
                final dayKey = _formatDayKey(date);
                final dateKey = _formatDateKey(date);
                return _events[dayKey]?[dateKey] ?? [];
              },
              selectedDayPredicate: (date) => isSameDay(_selectedDate, date),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _selectedDateKey = _formatDateKey(selectedDay);
                  _selectedDayKey = _formatDayKey(selectedDay);
                });
                _loadBookingsForSelectedDate();
              },
              calendarStyle: CalendarStyle(
                todayTextStyle: TextStyle(
                  color: primaryColor, // Color del texto de hoy
                  fontWeight: FontWeight.bold, // Para que resalte más
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent, // Fondo transparente
                  shape: BoxShape.circle, // Forma circular
                  border: Border.all(
                    // Borde con color primaryColor
                    color: primaryColor,
                    width: 2, // Grosor del borde
                  ),
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading ? _buildSkeletonLoader() : _buildBookingList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    if (_bookingsDetails.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: CustomImage(
                path: KImages.emptyBookingImage,
                url: null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Bookings for This Day",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Try selecting another date.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        itemCount: _bookingsDetails.length,
        itemBuilder: (context, index) {
          final booking = _bookingsDetails[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                booking['selectedTaskName'] ?? "Booking Name Not Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              subtitle: Text(
                "Client: ${booking['clientName'] ?? 'N/A'}\nTime: ${booking['timeSlot'] ?? 'N/A'} - ${booking['endSlot'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 14),
              ),
              leading: Icon(
                booking['status'] == 'pending'
                    ? Icons.hourglass_empty
                    : Icons.check_circle,
                color: booking['status'] == 'pending'
                    ? Colors.orange
                    : Colors.green,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.all(16),
                title: SizedBox(
                  width: 150,
                  height: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                subtitle: SizedBox(
                  width: 100,
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
