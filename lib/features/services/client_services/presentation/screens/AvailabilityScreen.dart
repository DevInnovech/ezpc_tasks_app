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
    Key? key,
    required this.taskId,
    required this.selectedCategory,
    required this.selectedSubCategories,
    required this.serviceSizes,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  Map<String, dynamic>? selectedTask;
  List<Map<String, dynamic>> relatedTasks = [];
  List<String> timeSlots = [];
  String? selectedTimeSlot; // Para almacenar el slot seleccionado
  String?
      currentlySelectedTaskId; // ID de la tarea seleccionada para mostrar slots
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchTaskAndRelatedTasks();
    generateTimeSlots();
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
            .where(FieldPath.documentId, isNotEqualTo: widget.taskId)
            .get();

        setState(() {
          selectedTask = taskData;
          currentlySelectedTaskId =
              widget.taskId; // Inicialmente la tarea principal
          relatedTasks = relatedTasksSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });

        generateTimeSlots();
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  void generateTimeSlots() {
    const startHour = 9; // Start at 9:00 AM
    const endHour = 17; // End at 5:00 PM

    timeSlots.clear(); // Reiniciar la lista de slots

    for (int hour = startHour; hour <= endHour; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour != endHour) {
        timeSlots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }

    setState(() {});
  }

  void changeDate(int offset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offset));
      selectedTimeSlot = null; // Reiniciar selección al cambiar la fecha
    });

    generateTimeSlots();
  }

  Widget _buildDateSelector() {
    return Row(
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
    );
  }

  Widget _buildTimeSlot(String time) {
    final isSelected = selectedTimeSlot == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeSlot = time; // Marcar como seleccionado
        });
        debugPrint('Selected Time Slot: $time');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> taskData,
      {bool isSelectedTask = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentlySelectedTaskId =
              taskData['id']; // Cambiar la tarea seleccionada
          selectedTimeSlot = null; // Reiniciar selección de slot
          generateTimeSlots(); // Regenerar slots
        });
        debugPrint('Selected Task: ${taskData['id']}');
      },
      child: Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Image and Title
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
              const SizedBox(height: 12.0),

              // Time Slots - Solo mostrar seleccionables para la tarea seleccionada
              if (isSelectedTask)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      timeSlots.map((slot) => _buildTimeSlot(slot)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTimeSlot != null ? Colors.blue : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
      onPressed: selectedTimeSlot != null
          ? () async {
              try {
                // Obtiene el usuario actualmente autenticado
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Redirige a la pantalla de información general
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneralInformationScreen(
                        taskId: currentlySelectedTaskId!,
                        timeSlot: selectedTimeSlot!,
                        date: selectedDate,
                        selectedCategory: widget.selectedCategory,
                        selectedSubCategories: widget.selectedSubCategories,
                        serviceSizes: widget.serviceSizes,
                        totalPrice: widget.totalPrice,
                        userId:
                            user.uid, // Pasa el userId del usuario autenticado
                      ),
                    ),
                  );
                } else {
                  // Maneja el caso en que no hay un usuario autenticado
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You must be logged in to continue."),
                    ),
                  );
                }
              } catch (e) {
                // Manejo de errores generales
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("An error occurred: $e"),
                  ),
                );
              }
            }
          : null, // Deshabilitar si no hay un slot seleccionado
      child: const Text(
        "Continue",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
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
      body: selectedTask == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  _buildDateSelector(),

                  const SizedBox(height: 16.0),

                  // Selected Task Card
                  _buildTaskCard(selectedTask!, isSelectedTask: true),

                  const SizedBox(height: 16.0),

                  // Divider and Related Tasks Section
                  if (relatedTasks.isNotEmpty)
                    _buildDividerWithTitle("From other providers"),
                  if (relatedTasks.isNotEmpty)
                    ...relatedTasks
                        .map((task) => _buildTaskCard(task))
                        .toList(),

                  const SizedBox(height: 16.0),

                  // Continue Button
                  _buildContinueButton(),
                ],
              ),
            ),
    );
  }
}
