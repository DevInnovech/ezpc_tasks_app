import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/GeneralInformation.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
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
  final String selectedTaskName;
  final double categoryPrice;
  final double taskPrice;
  final String providerId;

  const AvailabilityScreen({
    super.key,
    required this.taskId,
    required this.selectedCategory,
    required this.selectedSubCategories,
    required this.serviceSizes,
    required this.totalPrice,
    required this.selectedTaskName,
    required this.categoryPrice,
    required this.taskPrice,
    required this.providerId,
  });

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  List<Map<String, dynamic>> relatedTasks = [];
  Map<String, dynamic>? selectedTask;
  String? selectedTimeSlot;
  DateTime selectedDate = DateTime.now();
  String? providerId;

  @override
  void initState() {
    super.initState();
    fetchTaskAndRelatedTasks();
  }

  Future<void> fetchTaskAndRelatedTasks() async {
    try {
      // Obtener el documento específico de la tarea seleccionada
      final taskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (taskDoc.exists) {
        final taskData = taskDoc.data()!;
        final category = taskData['category'] as String;
        final provider =
            taskData['providerId'] as String?; // Obtener providerId

        // Inicializar la lista de tareas relacionadas
        List<Map<String, dynamic>> fetchedTasks = [];

        if (taskData.containsKey('assignments')) {
          // Caso de tareas corporativas con `assignments`
          final assignments = taskData['assignments'] as Map<String, dynamic>;

          // Filtrar empleados activos
          final activeProviders = assignments.entries
              .where((entry) => entry.value == true) // Solo empleados activos
              .map((entry) => entry.key) // IDs de empleados
              .toList();

          for (String providerId in activeProviders) {
            print("id:$providerId");
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(providerId)
                .get();

            if (userDoc.exists) {
              fetchedTasks.add({
                'id': taskDoc.id,
                ...taskData, // Datos de la tarea original
                'providerId': providerId,
                'providerName': userDoc.data()?['name'] ?? 'Unknown',
                'lastName': userDoc.data()?['name'] ?? 'Unknown',
                'providerPhoto': userDoc.data()?['profileImageUrl'] ?? '',
              });
            }
          }
        } else {
          // Caso de tareas no corporativas
          final relatedTasksSnapshot = await FirebaseFirestore.instance
              .collection('tasks')
              .where('category', isEqualTo: category)
              .get();

          fetchedTasks = relatedTasksSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        }

        // Actualizar el estado con la información obtenida
        setState(() {
          selectedTask = taskData;
          providerId = provider; // Asignar el providerId extraído
          relatedTasks = fetchedTasks;
        });
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  List<String> generateTimeSlots(Map<String, dynamic> workingHours) {
    final timeSlots = <String>[];

    // Obtener el día seleccionado (e.g., "Monday")
    final selectedDay = DateFormat('EEEE').format(selectedDate);

    // Verificar si el día está en el mapa de workingHours
    if (!workingHours.containsKey(selectedDay)) {
      debugPrint("Selected day $selectedDay is not in workingHours.");
      return timeSlots;
    }

    final hours = workingHours[selectedDay];
    if (hours == null || !(hours is Map<String, dynamic>)) {
      debugPrint("Invalid working hours for $selectedDay.");
      return timeSlots;
    }

    final start = _parseTime(hours['start']);
    final end = _parseTime(hours['end']);
    if (start == null || end == null) {
      debugPrint("Invalid start or end time for $selectedDay.");
      return timeSlots;
    }

    var currentTime = start;
    while (currentTime.isBefore(end)) {
      final formattedTime =
          DateFormat('hh:mm a').format(currentTime); // Formato AM/PM
      timeSlots.add(formattedTime);

      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return timeSlots;
  }

  DateTime? _parseTime(String? time) {
    if (time == null) return null;
    try {
      return DateFormat('hh:mm a').parse(time); // Formato AM/PM
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

    // Generar time slots basados en workingHours
    final workingHours =
        taskData['workingHours'] as Map<String, dynamic>? ?? {};
    final timeSlots = generateTimeSlots(workingHours);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.provideraboutScreen,
                    arguments: {'userId': taskData['providerId']},
                  ),
                  child: ClipRRect(
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
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskData['services'] ?? 'Task',
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
                        providerId = taskData['providerId'];
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
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
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
          onPressed: selectedTimeSlot != null && providerId != null
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
                        selectedTaskName: widget.selectedTaskName,
                        categoryPrice: widget.categoryPrice,
                        taskPrice: widget.taskPrice,
                        providerId: providerId!,
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
                _buildContinueButton(),
              ],
            ),
    );
  }
}
