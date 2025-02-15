import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/GeneralInformation.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/select_date.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_filter2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'dart:async';

class AvailabilityScreen extends StatefulWidget {
  final String categoryId;
  final String selectedCategory;
  final List<String> selectedSubCategories;
  final Map<String, int> serviceSizes;
  final double totalPrice;
  final String selectedTaskName;
  final double categoryPrice;
  final double taskPrice;
  final String? providerId;
  final double taskDuration; // Nuevo parámetro

  const AvailabilityScreen({
    super.key,
    required this.categoryId,
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
  double totalPrice = 0;
  Timer? _debounce;
  Map<String, dynamic> selectedFilter = {};

  @override
  void initState() {
    super.initState();
    totalPrice = widget.totalPrice;
    fetchTaskAndRelatedTasks();
  }

  List<Map<String, dynamic>> allTasks = [];

  Future<void> fetchTaskAndRelatedTasks() async {
    try {
      // Obtener el documento específico de la tarea seleccionada
      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      if (!categoryDoc.exists) return;

      final categoryData = categoryDoc.data()!;
      final category = categoryData['name'] as String?;
      final subCategoriesSet = widget.selectedSubCategories.toSet();
      List<Map<String, dynamic>> fetchedTasks = [];

      // Obtener todas las tareas en la misma categoría
      final relatedTasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('category', isEqualTo: category)
          .get();

      // Procesar cada tarea
      for (var task in relatedTasksSnapshot.docs) {
        final taskMap = {'id': task.id, ...task.data()};
        final relatedSelectedTasks =
            Map<String, dynamic>.from(taskMap['selectedTasks'] ?? {});
        final relatedSelectedKeys = relatedSelectedTasks.keys.toSet();

        // Verificar si las subcategorías coinciden
        if (subCategoriesSet.difference(relatedSelectedKeys).isNotEmpty) {
          continue;
        }

        if (taskMap.containsKey('assignments') &&
            (taskMap["assignments"] != null &&
                taskMap["assignments"].isNotEmpty)) {
          // Tareas corporativas
          final assignments = taskMap['assignments'] as Map<String, dynamic>;
          final activeProviders = assignments.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key)
              .toList();

          final userDocs = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: activeProviders)
              .get();

          for (var doc in userDocs.docs) {
            final userData = doc.data();
            final rating = userData['rating'] ?? 0.0;
            debugPrint(
                "🔹 Tarea ${taskMap['id']} - Rating obtenido de Firestore: $rating");
            fetchedTasks.add({
              ...taskMap,
              'providerId': doc.id,
              'providerName': userData['name'] ?? 'Unknown',
              'providerPhoto': userData['profileImageUrl'] ?? '',
              'onDemand': userData['onDemand'] ?? false,
              'averageRating': rating ?? 0.0,
            });
          }
        } else {
          // Tareas no corporativas
          final userData = await fetchUserData(taskMap['providerId']);
          final rating = userData['rating'] ?? 0.0;
          debugPrint(
              "🔹 Tarea ${taskMap['id']} - Rating obtenido de Firestore: $rating");
          fetchedTasks.add({
            ...taskMap,
            'providerPhoto': userData['profileImageUrl'] ?? '',
            'onDemand': userData['onDemand'] ?? false,
            'rating': rating,
          });
        }
      }

      // Guardamos la copia original
      allTasks = List.from(fetchedTasks);

      // Aplicamos los filtros con los datos nuevos
      applyFilters();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  void applyFilters() {
    if (allTasks.isEmpty) return; // Si no hay datos, no filtramos

    List<Map<String, dynamic>> filteredTasks = List.from(allTasks);

    debugPrint(
        "🔹 Ratings antes de aplicar cualquier filtro: ${filteredTasks.map((task) => task['averageRating']).toList()}");

    // 1️⃣ Filtro "Same Day"
    if (selectedFilter['onDemand'] == true) {
      filteredTasks =
          filteredTasks.where((task) => task['onDemand'] == true).toList();
    }

    // 2️⃣ Filtro "averageRating" (se aplica ANTES del ordenamiento)
    if (selectedFilter['averageRating'] != null &&
        selectedFilter['averageRating'][0] == true) {
      double minRating = selectedFilter['averageRating'][1] ?? 0.0;
      debugPrint("🔸 Filtrando ratings >= $minRating");

      filteredTasks = filteredTasks.where((task) {
        double rating = 0.0;

        if (task.containsKey('averageRating') &&
            task['averageRating'] != null) {
          if (task['averageRating'] is num) {
            rating = task['averageRating'].toDouble();
          } else if (task['averageRating'] is String) {
            rating = double.tryParse(task['averageRating']) ?? 0.0;
          }
        }

        debugPrint(
            "🔹 Tarea ${task['id']} - Rating: $rating - Pasa filtro: ${rating >= minRating}");
        return rating >= minRating;
      }).toList();

      // 🔥 Si no hay tareas con ese mínimo, reducir al máximo rating disponible
      if (filteredTasks.isEmpty) {
        double maxAvailableRating = allTasks.map((task) {
          if (task.containsKey('averageRating') &&
              task['averageRating'] != null) {
            if (task['averageRating'] is num) {
              return task['averageRating'].toDouble();
            } else if (task['averageRating'] is String) {
              return double.tryParse(task['averageRating']) ?? 0.0;
            }
          }
          return 0.0;
        }).reduce((a, b) => a > b ? a : b);

        debugPrint(
            "⚠️ No hay tareas con rating >= $minRating. Se ajusta a $maxAvailableRating.");

        filteredTasks = allTasks.where((task) {
          double rating = 0.0;
          if (task.containsKey('averageRating') &&
              task['averageRating'] != null) {
            if (task['averageRating'] is num) {
              rating = task['averageRating'].toDouble();
            } else if (task['averageRating'] is String) {
              rating = double.tryParse(task['averageRating']) ?? 0.0;
            }
          }
          return rating >= maxAvailableRating;
        }).toList();
      }
    }

    // 3️⃣ Filtro "Precio más bajo" (se aplica DESPUÉS del filtro de rating)
    if (selectedFilter['Lowest'] == true) {
      filteredTasks.sort((a, b) {
        double getTotalPrice(Map<String, dynamic> task) {
          double totalPrice = 0.0;
          for (var service in widget.selectedSubCategories) {
            final servicePrice =
                (task['selectedTasks'][service] ?? 0.0).toDouble();
            final hoursForService = widget.serviceSizes[service] ?? 1;
            totalPrice += servicePrice * hoursForService;
          }
          return totalPrice * 1.1; // Agregamos el 10% de impuestos
        }

        final priceA = getTotalPrice(a);
        final priceB = getTotalPrice(b);
        return priceA.compareTo(priceB);
      });
    }

    // Aplicamos los cambios al estado
    setState(() {
      relatedTasks = filteredTasks;
    });

    debugPrint("🔹 Tareas después de aplicar filtros: ${relatedTasks.length}");
  }

  Future<Map<String, dynamic>> fetchUserData(String providerId) async {
    try {
      // Obtener el documento del usuario correspondiente
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get();

      if (userDoc.exists) {
        return userDoc.data()!;
      } else {
        debugPrint('User with ID $providerId not found.');
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching user data for $providerId: $e');
      return {};
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
    if (hours == null || hours is! Map<String, dynamic>) {
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
        "start": DateFormat('hh:mm a').format(currentTime),
        "end": DateFormat('hh:mm a').format(nextTime),
        "status": "free", // Por defecto libre
      });
      currentTime = nextTime;
    }
    return intervals;
  }

  void updatePricesForSelectedTask(Map<String, dynamic> task) {
    double updatedTotalPrice = 0.0;

    // Calcular el precio total basado en los servicios seleccionados
    for (var service in widget.selectedSubCategories) {
      final newPrice = (task['selectedTasks'][service] ?? 0.0).toDouble();
      final hoursForService = widget.serviceSizes[service] ?? 1;
      updatedTotalPrice += newPrice * hoursForService;
    }

    double taxRate = 0.1; // 10% impuestos
    double taxAmount = updatedTotalPrice * taxRate;
    updatedTotalPrice += taxAmount;

    setState(() {
      totalPrice = updatedTotalPrice;
    });

    // Notificar al usuario si el precio cambió
    if (updatedTotalPrice != widget.totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "The price has changed based on the selected provider. New price: \$${updatedTotalPrice.toStringAsFixed(2)}",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> getAvailableIntervalsForTask(
      String providerId,
      String dayName,
      String formattedDate,
      Map<String, dynamic> workingHours,
      String taskId) async {
    // Usa una clave única basada en el taskId y providerId
    final key = "$taskId-$providerId";

    if (taskSlots.containsKey(key)) return; // Evitar recarga si ya se cargaron

    final intervals = await getAvailableIntervals(
        providerId, dayName, formattedDate, workingHours);

    setState(() {
      taskSlots[key] = intervals;
    });
  }

  Future<List<Map<String, dynamic>>> getAvailableIntervals(
      String providerId,
      String dayName,
      String formattedDate,
      Map<String, dynamic> workingHours) async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('providers').doc(providerId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      // Si no existe la colección, todos los intervalos están libres
      return _generateDefaultIntervals(workingHours);
    }

    final data = snapshot.data()!;
    final availability = Map<String, dynamic>.from(data['availability'] ?? {});

    // Acceder a la disponibilidad específica del día
    final dayAvailability = availability[dayName];
    if (dayAvailability == null || dayAvailability is! Map<String, dynamic>) {
      // No hay intervalos para este día, retorna los intervalos por defecto
      return _generateDefaultIntervals(workingHours);
    }

    // Acceder a la disponibilidad específica de la fecha
    final dateAvailability = dayAvailability[formattedDate];
    if (dateAvailability == null || dateAvailability is! List) {
      // No hay intervalos para esta fecha, retorna los intervalos por defecto
      return _generateDefaultIntervals(workingHours);
    }

    final List<Map<String, dynamic>> dayIntervals =
        List<Map<String, dynamic>>.from(dateAvailability);

    // Generar todos los intervalos posibles según las horas de trabajo
    final allIntervals = _generateDefaultIntervals(workingHours);

    // Actualizar el estado de los intervalos según la disponibilidad
    for (var interval in dayIntervals) {
      final index = allIntervals.indexWhere((slot) =>
          slot['start'] == interval['start'] && slot['end'] == interval['end']);
      if (index != -1) {
        allIntervals[index]['status'] =
            interval['status']; // Ocupado o Bloqueado
        if (interval.containsKey('taskId')) {
          allIntervals[index]['taskId'] = interval['taskId'];
        }
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
    return WeeklyDateSelector(
      initialDate: selectedDate,
      onDateSelected: (newDate) {
        setState(() {
          selectedDate = newDate;
          changeDate(
              0); // Refrescar los slots y disponibilidad con el nuevo día
        });
      },
      primaryColor: primaryColor,
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
    final key = "$taskId-${selectedCard?['providerId'] ?? ''}";
    final timeSlots = taskSlots[key];
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

        // Determinar el color basado en el estado del slot
        Color slotColor;
        Color borderColor;
        Color textColor = Colors.black;

        switch (slot['status']) {
          case 'free':
            slotColor = Colors.transparent;
            borderColor = primaryColor;
            textColor = primaryColor;
            break;
          case 'occupied':
            slotColor = Colors.grey.shade300;
            borderColor = Colors.grey.shade300;
            textColor = Colors.grey;
            break;
          case 'blocked':
            slotColor = Colors.grey.shade400;
            borderColor = Colors.grey.shade300;
            textColor = Colors.grey;
            break;
          default:
            slotColor = Colors.grey.shade200;
            borderColor = Colors.grey;
        }

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
                        for (var previousSlot
                            in taskSlots[previousTaskId] ?? []) {
                          previousSlot['isSelected'] = false;
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
              : null, // Deshabilitar onTap para 'occupied' y 'blocked'
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: shouldHighlight ? primaryColor : slotColor,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: shouldHighlight ? primaryColor : borderColor,
                width: 1.5,
              ),
            ),
            child: Text(
              slot['start'] ?? "",
              style: TextStyle(
                color: shouldHighlight ? Colors.white : textColor,
                fontSize: 14.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
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

    final key = "$taskId-$ProviderId";

    if (!taskSlots.containsKey(key)) {
      String dayName =
          DateFormat('EEEE').format(selectedDate); // e.g., "Monday"
      String formattedDate =
          DateFormat('M-d-yyyy').format(selectedDate); // e.g., "1-7-2025"

      getAvailableIntervalsForTask(
        ProviderId,
        dayName,
        formattedDate,
        taskData['workingHours'] ?? {},
        taskId,
      );

      return const Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 8.0),
              Text("Loading availability..."),
            ],
          ),
        ),
      );
    }

    final timeSlots = taskSlots[key]!;

    // ✅ Calcular el precio total basado en los servicios seleccionados
    double totalTaskPrice = 0.0;

    for (var service in widget.selectedSubCategories) {
      final servicePrice =
          (taskData['selectedTasks'][service] ?? 0.0).toDouble();
      final hoursForService = widget.serviceSizes[service] ?? 1;
      totalTaskPrice += servicePrice * hoursForService;
    }

    double taxRate = 0.1; // 10% de impuestos
    double taxAmount = totalTaskPrice * taxRate;
    totalTaskPrice += taxAmount;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCard != taskData) {
            providerId = ProviderId;
            // Actualizar precios basados en la tarea seleccionada
            updatePricesForSelectedTask(taskData);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              providerName,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${totalTaskPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
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
                  final Map<String, dynamic> newPrices = {
                    for (var subCategory in widget.selectedSubCategories)
                      subCategory: relatedTasks
                              .firstWhere(
                                (task) => task['id'] == selectedCard!['id'],
                                orElse: () => {},
                              )
                              .containsKey('selectedTasks')
                          ? (relatedTasks.firstWhere(
                                    (task) => task['id'] == selectedCard!['id'],
                                  )['selectedTasks'][subCategory] *
                                  widget.serviceSizes[subCategory] ??
                              0.0)
                          : 0.0,
                  };
                  if (totalPrice != widget.totalPrice) {
                    // Crear un mapa con el desglose de precios por tarea

                    showPriceChangeDialog(totalPrice, newPrices);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneralInformationScreen(
                          taskId: "widget.taskId",
                          timeSlot: selectedTask!['start'],
                          endSlot: selectedTask!['end'],
                          date: selectedDate,
                          selectedCategory: widget.selectedCategory,
                          selectedSubCategories: widget.selectedSubCategories,
                          serviceSizes: widget.serviceSizes,
                          totalPrice: totalPrice,
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                          selectedTaskName: widget.selectedTaskName,
                          categoryPrice: widget.categoryPrice,
                          taskPrice: widget.taskPrice,
                          providerId: providerId!,
                          selectedSubCategoriesmap: newPrices,
                        ),
                      ),
                    );
                  }
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

/*
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
*/
  void showPriceChangeDialog(
      double newTotalPrice, Map<String, dynamic> newPrices) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Oscurece el fondo
      builder: (context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Hace que el diálogo no tenga fondo propio
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: _buildWhiteCard(
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del diálogo
                  const Text(
                    "Price Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF404C8C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Desglose de precios
                  _buildPriceBreakdown(newPrices),

                  const SizedBox(height: 20),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Cancel
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeneralInformationScreen(
                                taskId: "widget.taskId",
                                timeSlot: selectedTask!['start'],
                                endSlot: selectedTask!['end'],
                                date: selectedDate,
                                selectedCategory: widget.selectedCategory,
                                selectedSubCategories:
                                    widget.selectedSubCategories,
                                serviceSizes: widget.serviceSizes,
                                totalPrice: newTotalPrice,
                                userId:
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        '',
                                selectedTaskName: widget.selectedTaskName,
                                categoryPrice: widget.categoryPrice,
                                taskPrice: widget.taskPrice,
                                providerId: providerId!,
                                selectedSubCategoriesmap: newPrices,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(color: Color(0xFF404C8C)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceBreakdown(Map<String, dynamic> newPrices) {
    double servicesTotal =
        newPrices.values.fold(0.0, (sum, price) => sum + price);

    double taxRate = 0.1; // 10% impuestos
    double taxAmount = servicesTotal * taxRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar el desglose de cada servicio
        ...newPrices.entries.map((entry) {
          return _buildPriceRow(
            entry.key, // Nombre del servicio
            entry.value, // Precio sin multiplicar por horas
          );
        }),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow("Tasks Price (Subtotal):", servicesTotal),
        _buildPriceRow(
            "Taxes (10%):", double.parse(taxAmount.toStringAsFixed(2))),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow(
          "Total:",
          (servicesTotal + taxAmount),
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, dynamic value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "\$$value",
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF404C8C) : Colors.black87,
          ),
        ),
      ],
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
                CustomFilterWidgetCopy(
                  onFilterSelected: (selectedFilters) {
                    setState(() {
                      selectedFilter = selectedFilters ?? {};
                      applyFilters();
                    });
                  },
                ),
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

Widget _buildWhiteCard(Widget child) {
  return Card(
    color: Colors.white,
    elevation: 6,
    shadowColor: Colors.grey.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: child,
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF404C8C),
      ),
    ),
  );
}
