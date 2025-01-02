import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AvailabilityScreen.dart';

class BookingScreen extends StatefulWidget {
  final String taskId;

  const BookingScreen({super.key, required this.taskId});

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
          selectedTaskName = taskData['taskName'] as String?;
          baseTaskPrice = (taskData['price'] ?? 0.0).toDouble();
          providerId = taskData['providerId'] as String?;
          availableServices = (taskData['selectedTasks']
                  as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, (value as num).toDouble()));
          selectedServices = {selectedTaskName!: baseTaskPrice};
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
    double servicesTotal = selectedServices.values.fold(0.0, (a, b) => a + b);
    double taxRate = 0.1; // 10% impuestos
    double taxAmount = servicesTotal * hours * taxRate;
    totalPrice = servicesTotal * hours + taxAmount;
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvailabilityScreen(
                      taskId: widget.taskId,
                      selectedCategory: selectedCategory!,
                      selectedSubCategories: selectedServices.keys.toList(),
                      serviceSizes: {'Hours': hours},
                      totalPrice: totalPrice,
                      selectedTaskName: selectedTaskName!,
                      categoryPrice: baseTaskPrice,
                      taskPrice: totalPrice - baseTaskPrice,
                      providerId: providerId!,
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

        return CheckboxListTile(
          title: Text(
            "$serviceName (\$${price.toStringAsFixed(2)}/hour)",
            style: const TextStyle(fontSize: 16),
          ),
          value: selectedServices.containsKey(serviceName),
          onChanged: (isSelected) {
            setState(() {
              if (isSelected == true) {
                selectedServices[serviceName] = price;
              } else {
                selectedServices.remove(serviceName);
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
    return Row(
      children: [
        Expanded(
          child: Text(
            "$hours Hour${hours > 1 ? 's' : ''}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF404C8C),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (hours > 1) {
                    hours--;
                    calculateTotalPrice();
                  }
                });
              },
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$hours',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  hours++;
                  calculateTotalPrice();
                });
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    double servicesTotal = selectedServices.values.fold(0.0, (a, b) => a + b);
    double taxRate = 0.1;
    double taxAmount = servicesTotal * hours * taxRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceRow("Tasks Price:", servicesTotal * hours),
        _buildPriceRow("Taxes (10%):", taxAmount),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow(
          "Total:",
          totalPrice,
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
