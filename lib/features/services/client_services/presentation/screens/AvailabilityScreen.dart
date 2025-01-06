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
  final double taskDuration; // Nuevo parámetro

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
    required this.taskDuration,
  });

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  List<Map<String, dynamic>> relatedTasks = [];
  Map<String, List<Map<String, dynamic>>> taskSlots = {};
  Map<String, dynamic>? selectedCard;
  final ScrollController _scrollController = ScrollController();

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

  List<Map<String, dynamic>> _generateDefaultIntervals(
      Map<String, dynamic> workingHours) {
    final intervals = <Map<String, dynamic>>[];
    final selectedDay = DateFormat('EEEE').format(selectedDate);

    if (!workingHours.containsKey(selectedDay)) {
      debugPrint("Selected day $selectedDay is not in workingHours.");
      return intervals; // Retorna vacío si el día no está configurado
    }

    final hours = workingHours[selectedDay];
    if (hours == null || !(hours is Map<String, dynamic>)) {
      debugPrint("Invalid working hours for $selectedDay.");
      return intervals;
    }

    final start = _parseTime(hours['start']);
    final end = _parseTime(hours['end']);
    if (start == null || end == null) {
      debugPrint("Invalid start or end time for $selectedDay.");
      return intervals;
    }

    var currentTime = start;
    while (currentTime.isBefore(end)) {
      final nextTime = currentTime.add(const Duration(minutes: 30));
      intervals.add({
        "start": DateFormat('h:mm a').format(currentTime),
        "end": DateFormat('h:mm a').format(nextTime),
        "status": "free", // Por defecto libre
      });
      currentTime = nextTime;
    }
    return intervals;
  }

  Future<void> getAvailableIntervalsForTask(String providerId, String day,
      Map<String, dynamic> workingHours, String taskId) async {
    if (taskSlots.containsKey(taskId))
      return; // Evitar recarga si ya se cargaron

    final intervals =
        await getAvailableIntervals(providerId, day, workingHours);
    setState(() {
      taskSlots[taskId] = intervals;
    });
  }

  Future<List<Map<String, dynamic>>> getAvailableIntervals(
      String providerId, String day, Map<String, dynamic> workingHours) async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('providers').doc(providerId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      // Si no existe la colección, todos los intervalos están libres
      return _generateDefaultIntervals(workingHours);
    }

    final data = snapshot.data()!;
    final availability = Map<String, dynamic>.from(data['availability'] ?? {});
    final dayIntervals =
        List<Map<String, dynamic>>.from(availability[day] ?? []);

    // Generar todos los intervalos posibles según las horas de trabajo
    final allIntervals = _generateDefaultIntervals(workingHours);

    // Actualizar el estado de los intervalos según la disponibilidad
    for (var interval in dayIntervals) {
      final index = allIntervals.indexWhere((slot) =>
          slot['start'] == interval['start'] && slot['end'] == interval['end']);
      if (index != -1) {
        allIntervals[index]['status'] =
            interval['status']; // Ocupado o Bloqueado
      }
    }

    return allIntervals;
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
      taskSlots.clear(); // Reiniciar slots cargados
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

  List<List<Map<String, dynamic>>> formatTimeSlotsForDisplay(
      List<Map<String, dynamic>> timeSlots) {
    const int columns = 4;
    final formattedSlots = <List<Map<String, dynamic>>>[];

    // Añadir slots vacíos al inicio para alinear
    while (timeSlots.length % columns != 0) {
      timeSlots.add({"start": "", "end": "", "status": "empty"});
    }

    for (int i = 0; i < timeSlots.length; i += columns) {
      formattedSlots.add(timeSlots.sublist(i, i + columns));
    }

    return formattedSlots;
  }

  void handleSlotSelection(Map<String, dynamic> selectedSlot, String taskId) {
    final timeSlots = taskSlots[taskId];
    if (timeSlots == null) return;

    final requiredSlots = ((widget.taskDuration * 60) / 30).ceil();
    final selectedIndex = timeSlots.indexOf(selectedSlot);

    if (selectedIndex != -1) {
      setState(() {
        // Reiniciar selección previa en la tarjeta activa
        for (var slot in timeSlots) {
          slot['isSelected'] = false;
        }

        // Seleccionar slots consecutivos
        bool canSelectAll = true;
        List<Map<String, dynamic>> selectedSlots = [];
        for (int i = 0; i < requiredSlots; i++) {
          final currentIndex = selectedIndex + i;
          if (currentIndex >= timeSlots.length ||
              timeSlots[currentIndex]['status'] != 'free') {
            canSelectAll = false;
            break;
          }
          selectedSlots.add(timeSlots[currentIndex]);
        }

        if (canSelectAll) {
          for (var slot in selectedSlots) {
            slot['isSelected'] = true;
          }

          // Guardar el tiempo de inicio y fin
          selectedTimeSlot = timeSlots[selectedIndex]['start'];
          final selectedEndTimeSlot =
              timeSlots[selectedIndex + requiredSlots - 1]['end'];
          selectedTask = {
            "start": selectedTimeSlot,
            "end": selectedEndTimeSlot,
          };
        } else {
          // Mostrar mensaje si no se pueden seleccionar slots consecutivos
          selectedTimeSlot = null;
          selectedTask = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "No se pueden seleccionar todos los intervalos consecutivos."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  Widget _buildTimeSlotsGrid(
      List<Map<String, dynamic>> timeSlots, String taskId) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 2.5,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isSelected = slot['isSelected'] ?? false;

        // Resaltar solo los slots seleccionados de la tarjeta activa
        final shouldHighlight =
            selectedCard != null && selectedCard!['id'] == taskId && isSelected;

        return GestureDetector(
          onTap: slot['status'] == 'free'
              ? () {
                  // Cambiar la tarjeta activa si no coincide
                  if (selectedCard == null || selectedCard!['id'] != taskId) {
                    setState(() {
                      // Reiniciar la selección de la tarjeta previa
                      if (selectedCard != null) {
                        final previousTaskId = selectedCard!['id'];
                        for (var slot in taskSlots[previousTaskId] ?? []) {
                          slot['isSelected'] = false;
                        }
                      }

                      // Actualizar la tarjeta activa
                      selectedCard = relatedTasks
                          .firstWhere((task) => task['id'] == taskId);
                      selectedTask = null;
                      selectedTimeSlot = null;

                      // Mover la tarjeta seleccionada al inicio
                      relatedTasks.remove(selectedCard);
                      relatedTasks.insert(0, selectedCard!);

                      // Ajustar el scroll
                      _scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  }

                  // Seleccionar el slot en la tarjeta activa
                  handleSlotSelection(slot, taskId);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: shouldHighlight ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: shouldHighlight ? Colors.blue : Colors.grey,
              ),
            ),
            child: Text(
              slot['start'] ?? "",
              style: TextStyle(
                color: shouldHighlight ? Colors.white : Colors.black,
                fontSize: 14.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> taskData) {
    final taskId = taskData['id'];
    final ProviderId = taskData['providerId'];
    final firstName = taskData['firstName'] ?? 'Unknown';
    final lastName = taskData['lastName'] ?? '';
    final providerName = '$firstName $lastName';
    final isSelected = selectedCard == taskData;
    print(ProviderId);
    if (!taskSlots.containsKey(taskId)) {
      getAvailableIntervalsForTask(
        ProviderId,
        DateFormat('EEEE').format(selectedDate),
        taskData['workingHours'] ?? {},
        taskId,
      );
      return Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 8.0),
              Text("Loading availability..."),
            ],
          ),
        ),
      );
    }

    final timeSlots = taskSlots[taskId]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCard != taskData) {
            providerId = ProviderId;
            // Limpiar selección de slots en la tarjeta anterior
            final previousTaskId = selectedCard?['id'];
            if (previousTaskId != null) {
              for (var slot in taskSlots[previousTaskId] ?? []) {
                slot['isSelected'] = false;
              }
            }

            // Actualizar la tarjeta seleccionada
            selectedCard = taskData;
            selectedTask = null;
            selectedTimeSlot = null;

            relatedTasks.remove(taskData);
            relatedTasks.insert(0, taskData);

            _scrollController.animateTo(
              0.0, // Llevar al inicio de la lista
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      child: Card(
        elevation: isSelected ? 10 : 6,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        shadowColor: isSelected ? Colors.blue : Colors.black38,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      taskData['providerPhoto'] ?? '',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
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
              _buildTimeSlotsGrid(timeSlots, taskId),
            ],
          ),
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
          onPressed: selectedTask != null && providerId != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneralInformationScreen(
                        taskId: widget.taskId,
                        timeSlot: selectedTask!['start'],
                        endSlot: selectedTask!['end'], // Nuevo parámetro
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
                    controller: _scrollController,
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
