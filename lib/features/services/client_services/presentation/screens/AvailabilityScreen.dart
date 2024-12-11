import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/GeneralInformation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AvailabilityScreen extends StatefulWidget {
  final String taskId;
  final String selectedCategory;
  final List<String> selectedSubCategories;
  final Map<String, int> serviceSizes;
  final double totalPrice;

  const AvailabilityScreen({
    super.key,
    required this.taskId,
    required this.selectedCategory,
    required this.selectedSubCategories,
    required this.serviceSizes,
    required this.totalPrice,
  });

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  List<Map<String, dynamic>> relatedTasks = [];
  Map<String, dynamic>? selectedTask;
  String? selectedTimeSlot;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchTaskAndRelatedTasks();
  }

  Future<void> fetchTaskAndRelatedTasks() async {
    try {
      final taskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (taskDoc.exists) {
        final taskData = taskDoc.data()!;
        final category = taskData['category'] as String;

        final relatedTasksSnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('category', isEqualTo: category)
            .get();

        setState(() {
          selectedTask = taskData;
          relatedTasks = relatedTasksSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  List<String> generateTimeSlots(Map<String, dynamic> taskData) {
    final timeSlots = <String>[];
    final workingDays = taskData['workingDays'] as List<dynamic>? ?? [];
    final workingHours = taskData['workingHours'] as Map<String, dynamic>?;

    // Verificar si el día seleccionado está disponible
    final selectedDay =
        DateFormat('EEEE').format(selectedDate); // Ejemplo: "Monday"
    if (!workingDays.contains(selectedDay)) {
      debugPrint("Selected day $selectedDay is not in workingDays.");
      return timeSlots;
    }

    // Obtener horas de trabajo para el día seleccionado
    final hours = workingHours?[selectedDay];
    if (hours == null) {
      debugPrint("Working hours not found for $selectedDay.");
      return timeSlots;
    }

    // Generar los slots de tiempo
    final start = _parseTime(hours['start']); // Ejemplo: "00:00"
    final end = _parseTime(hours['end']); // Ejemplo: "12:00"
    if (start == null || end == null) {
      debugPrint("Invalid start or end time for $selectedDay.");
      return timeSlots;
    }

    var currentTime = start;
    while (currentTime.isBefore(end)) {
      final formattedTime = DateFormat('HH:mm').format(currentTime); // 24 horas
      timeSlots.add(formattedTime);

      // Incrementar en 30 minutos
      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return timeSlots;
  }

  DateTime? _parseTime(String? time) {
    if (time == null) return null;
    try {
      return DateFormat('hh:mm a').parse(time); // Parse AM/PM desde Firebase
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return null;
    }
  }

  void changeDate(int offset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offset));
      selectedTimeSlot = null; // Reiniciar selección de slot
    });
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => changeDate(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(selectedDate),
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('d MMMM yyyy').format(selectedDate),
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => changeDate(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> taskData) {
    final firstName = taskData['firstName'] ?? 'Unknown';
    final lastName = taskData['lastName'] ?? 'Provider';
    final providerName = '$firstName $lastName';
    final timeSlots = generateTimeSlots(taskData);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información principal de la tarea
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    taskData['imageUrl'] ?? '',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskData['subCategory'] ?? 'Task',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16.0),
                          const SizedBox(width: 4.0),
                          Text(
                            "${taskData['averageRating'] ?? '0.0'}",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            "(${taskData['reviewsCount'] ?? 0} Reviews)",
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Slots de Tiempo
            if (timeSlots.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: timeSlots.map((slot) {
                  final isSelected = selectedTimeSlot == slot;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTimeSlot = slot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              const Text(
                "No time slots available for this date.",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0), // Espacio extra abajo
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTimeSlot != null ? Colors.blue : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14.0),
          ),
          onPressed: selectedTimeSlot != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneralInformationScreen(
                        taskId: widget.taskId,
                        timeSlot: selectedTimeSlot!,
                        date: selectedDate,
                        selectedCategory: widget.selectedCategory,
                        selectedSubCategories: widget.selectedSubCategories,
                        serviceSizes: widget.serviceSizes,
                        totalPrice: widget.totalPrice,
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                    ),
                  );
                }
              : null,
          child: const Text(
            "Continue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task Provider Availability",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: relatedTasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de Fecha
                _buildDateSelector(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: relatedTasks
                          .map((task) => _buildTaskCard(task))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Botón de Continuar
                _buildContinueButton(),
              ],
            ),
    );
  }
}
