import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/AvailabilityScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final String taskId;

  const BookingScreen({super.key, required this.taskId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedCategory;
  final List<String> selectedSubCategories = [];
  final Map<String, int> serviceSizes = {
    "Small": 0,
    "Medium": 0,
    "Large": 0,
  };
  double baseTaskPrice = 0.0;
  double subCategoryPrice = 0.0;
  double totalPrice = 0.0;

  Map<String, List<Map<String, dynamic>>> categories = {};

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
        final data = taskDoc.data()!;
        baseTaskPrice = (data['price'] ?? 0.0).toDouble();
        final category = data['category'] as String?;
        final subCategory = data['subCategory'] as String?;

        final querySnapshot =
            await FirebaseFirestore.instance.collection('categories').get();

        final Map<String, List<Map<String, dynamic>>> loadedCategories = {};
        for (var doc in querySnapshot.docs) {
          final categoryName = doc['name'] as String;
          final subCategories = (doc['subCategories'] as List)
              .map((sub) => {'name': sub['name'], 'price': sub['price'] ?? 0.0})
              .toList();

          loadedCategories[categoryName] = subCategories;
        }

        setState(() {
          categories = loadedCategories;
          selectedCategory = category;
          if (selectedCategory != null && subCategory != null) {
            selectedSubCategories.add(subCategory);
            subCategoryPrice = loadedCategories[selectedCategory]!
                .firstWhere((sub) => sub['name'] == subCategory)['price']
                .toDouble();
          }
          calculateTotalPrice();
        });
      }
    } catch (e) {
      debugPrint('Error fetching task data: $e');
    }
  }

  void toggleSubCategory(String subCategory, double price) {
    setState(() {
      if (selectedSubCategories.contains(subCategory)) {
        selectedSubCategories.remove(subCategory);
        subCategoryPrice -= price;
      } else {
        selectedSubCategories.add(subCategory);
        subCategoryPrice += price;
      }
      calculateTotalPrice();
    });
  }

  void calculateTotalPrice() {
    double sizePrice = 0.0;

    // Calculamos el precio adicional basado en los tamaños seleccionados
    serviceSizes.forEach((size, quantity) {
      if (size == "Small") {
        sizePrice += quantity * 25.0;
      } else if (size == "Medium") {
        sizePrice += quantity * 50.0;
      } else if (size == "Large") {
        sizePrice += quantity * 75.0;
      }
    });

    totalPrice = baseTaskPrice + subCategoryPrice + sizePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            // Categories Section
            _buildSectionTitle("Task:"),
            if (categories.isNotEmpty)
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedSubCategories.clear();
                    subCategoryPrice = 0.0;
                    calculateTotalPrice();
                  });
                },
              ),

            const SizedBox(height: 16),

            // Subcategories Section
            if (selectedCategory != null) _buildSectionTitle("Cleaning Tasks"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories[selectedCategory]?.map((subCategory) {
                    final isSelected =
                        selectedSubCategories.contains(subCategory['name']);
                    final price = subCategory['price'].toDouble();
                    return FilterChip(
                      label: Text(
                          "${subCategory['name']} (\$${price.toStringAsFixed(2)})"),
                      selected: isSelected,
                      onSelected: (_) =>
                          toggleSubCategory(subCategory['name'], price),
                      selectedColor: Colors.blue.shade100,
                      checkmarkColor: Colors.blue,
                      backgroundColor: Colors.grey.shade200,
                    );
                  }).toList() ??
                  [],
            ),

            const SizedBox(height: 16),

            // Service Sizes Section
            _buildSectionTitle("Size"),
            Column(
              children: serviceSizes.keys.map((size) {
                final int quantity = serviceSizes[size] ?? 0;
                final String price = size == "Small"
                    ? "\$25"
                    : size == "Medium"
                        ? "\$50"
                        : "\$75";

                final String duration = size == "Small"
                    ? "1 H"
                    : size == "Medium"
                        ? "2-3 H"
                        : "4+ H";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                size,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                price,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                duration,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (quantity > 0) {
                                    serviceSizes[size] = quantity - 1;
                                  }
                                  calculateTotalPrice();
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  serviceSizes[size] = quantity + 1;
                                  calculateTotalPrice();
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Total Price Section
            _buildSectionTitle("Total Price"),
            Text(
              "\$${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),

            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF404C8C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                onPressed: () {
                  if (selectedCategory != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailabilityScreen(
                          taskId: widget.taskId,
                          selectedCategory: selectedCategory ??
                              "Default Category", // Valor por defecto
                          selectedSubCategories: selectedSubCategories,
                          serviceSizes: serviceSizes,
                          totalPrice: totalPrice,
                        ),
                      ),
                    );
                  } else {
                    // Muestra un mensaje de error si selectedCategory es nulo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a category")),
                    );
                  }
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
