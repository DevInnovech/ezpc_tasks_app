import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AvailabilityScreen.dart';

class BookingScreen extends StatefulWidget {
  final String taskId;
  final String taskName; // Nuevo parámetro

  const BookingScreen(
      {super.key, required this.taskId, required this.taskName});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedCategory;
  String? selectedTaskName;
  int hours = 1;
  double baseTaskPrice = 0.0;
  double totalPrice = 0.0;
  String? providerId;
  Map<String, int> serviceHours = {}; // Almacena las horas por servicio

  Map<String, dynamic> taskData = {};
  Map<String, double> selectedServices = {};
  Map<String, double> availableServices = {};
  bool isLoading = true;

  bool isCategoryExpanded = true;
  bool isServicesExpanded = true;
  bool isTaskNameExpanded = true;

  @override
  void initState() {
    super.initState();
    fetchTaskData();
  }

  Future<void> fetchTaskData() async {
    try {
      final taskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (taskDoc.exists) {
        setState(() {
          taskData = taskDoc.data()!;
          selectedCategory = taskData['category'] as String?;
          selectedTaskName = widget.taskName; // Usa el taskName pasado
          baseTaskPrice = (taskData['price'] ?? 0.0).toDouble();
          providerId = taskData['providerId'] as String?;

          // Cargar servicios disponibles
          availableServices = (taskData['selectedTasks']
                  as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, (value as num).toDouble()));

          // Seleccionar automáticamente la tarea predeterminada
          if (selectedTaskName != null &&
              availableServices.containsKey(selectedTaskName)) {
            selectedServices = {
              selectedTaskName!: availableServices[selectedTaskName!]!
            };
          }

          isLoading = false;
          calculateTotalPrice();
        });
      }
    } catch (e) {
      debugPrint('Error fetching task data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateTotalPrice() {
    totalPrice = 0.0;
    int totalHours = 0;

    selectedServices.forEach((serviceName, price) {
      final hours = serviceHours[serviceName] ?? 1; // Por defecto 1 hora
      totalPrice += price * hours;
      totalHours += hours;
    });

    double taxRate = 0.1; // 10% impuestos
    double taxAmount = totalPrice * taxRate;

    totalPrice += taxAmount;
    hours = totalHours; // Actualizar las horas totales
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandableCard(
              title: "Category",
              isExpanded: isCategoryExpanded,
              onExpand: () {
                setState(() {
                  isCategoryExpanded = !isCategoryExpanded;
                });
              },
              child: _buildCategoryContent(),
            ),
            _buildExpandableCard(
              title: "Task(s)",
              isExpanded: isServicesExpanded,
              onExpand: () {
                setState(() {
                  isServicesExpanded = !isServicesExpanded;
                });
              },
              child: _buildServicesContent(),
            ),
            _buildExpandableCard(
              title: "Task Name",
              isExpanded: isTaskNameExpanded,
              onExpand: () {
                setState(() {
                  isTaskNameExpanded = !isTaskNameExpanded;
                });
              },
              child: _buildTaskNameContent(),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Hours"),
            _buildWhiteCard(_buildHoursCard()),
            const SizedBox(height: 20),
            _buildSectionTitle("Price Breakdown"),
            _buildWhiteCard(_buildPriceBreakdown()),
            const SizedBox(height: 20),
            _buildSectionTitle("Total Price"),
            Text(
              "\$${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF404C8C),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF404C8C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 5,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () {
              if (selectedCategory != null &&
                  selectedServices.isNotEmpty &&
                  providerId != null) {
                final updatedServiceSizes = Map<String, int>.from(serviceHours);
                updatedServiceSizes['Hours'] = hours;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvailabilityScreen(
                      taskId: widget.taskId,
                      selectedCategory: selectedCategory!,
                      selectedSubCategories: selectedServices.keys.toList(),
                      serviceSizes: updatedServiceSizes,
                      totalPrice: totalPrice,
                      selectedTaskName: selectedTaskName!,
                      categoryPrice: baseTaskPrice,
                      taskPrice: totalPrice - baseTaskPrice,
                      providerId: providerId!,
                      taskDuration: hours.toDouble(),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please complete all selections"),
                  ),
                );
              }
            },
            child: const Text(
              "Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onExpand,
    required Widget child,
  }) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF404C8C),
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF404C8C),
                ),
                onTap: onExpand,
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: child,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildServicesContent() {
    return Column(
      children: availableServices.entries.map((entry) {
        final serviceName = entry.key;
        final price = entry.value;
        final isSelected = selectedServices.containsKey(serviceName);

        return CheckboxListTile(
          title: Text(
            "$serviceName (\$${price.toStringAsFixed(2)}/hour)",
            style: const TextStyle(fontSize: 16),
          ),
          value: isSelected,
          onChanged: (isSelected) {
            setState(() {
              if (isSelected == true) {
                selectedServices[serviceName] = price;
                serviceHours[serviceName] =
                    1; // Inicializar con 1 hora por defecto
              } else {
                selectedServices.remove(serviceName);
                serviceHours.remove(serviceName); // Eliminar si se deselecciona
              }
              calculateTotalPrice();
            });
          },
        );
      }).toList(),
    );
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

  Widget _buildTaskNameContent() {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF404C8C),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            selectedTaskName ?? "No task name selected",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryContent() {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF404C8C),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            selectedCategory ?? "No category selected",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var entry in selectedServices.entries)
          _buildServiceHoursRow(entry.key, entry.value),
      ],
    );
  }

  Widget _buildServiceHoursRow(String serviceName, double servicePrice) {
    final hoursForService = serviceHours[serviceName] ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF404C8C),
                  ),
                ),
                Text(
                  "\$${servicePrice.toStringAsFixed(2)}/hour",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: hoursForService > 1
                    ? () {
                        setState(() {
                          serviceHours[serviceName] = hoursForService - 1;
                          calculateTotalPrice();
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                "$hoursForService hr${hoursForService > 1 ? 's' : ''}",
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    serviceHours[serviceName] = hoursForService + 1;
                    calculateTotalPrice();
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    double servicesTotal = 0.0;

    // Calcular el total por cada servicio basado en sus horas específicas
    selectedServices.forEach((serviceName, price) {
      final hoursForService =
          serviceHours[serviceName] ?? 1; // Por defecto 1 hora
      servicesTotal += price * hoursForService;
    });

    double taxRate = 0.1; // 10% impuestos
    double taxAmount = servicesTotal * taxRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar el desglose de cada servicio
        ...selectedServices.entries.map((entry) {
          final serviceName = entry.key;
          final price = entry.value;
          final hoursForService = serviceHours[serviceName] ?? 1;

          return _buildPriceRow(
            "$serviceName ($hoursForService hr${hoursForService > 1 ? 's' : ''}):",
            price * hoursForService,
          );
        }).toList(),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow("Tasks Price (Subtotal):", servicesTotal),
        _buildPriceRow("Taxes (10%):", taxAmount),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow(
          "Total:",
          servicesTotal + taxAmount,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false}) {
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
          "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF404C8C) : Colors.black87,
          ),
        ),
      ],
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
}
