import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';

// Custom CheckboxListTile for categories and tasks

class PremierServiceScreen extends ConsumerStatefulWidget {
  final ServiceModel selectedService; // Selected service
  final List<Category> availableCategories; // Available categories

  const PremierServiceScreen({
    Key? key,
    required this.selectedService,
    required this.availableCategories,
  }) : super(key: key);

  @override
  _PremierServiceScreenState createState() => _PremierServiceScreenState();
}

class _PremierServiceScreenState extends ConsumerState<PremierServiceScreen> {
  String? selectedSize;
  int sizeQuantity = 0;
  late Category selectedCategory;
  late List<SubCategory> selectedSubCategories;
  late Map<String, int> sizeQuantities = {}; // Track quantities for each size

  // Available sizes with properties
  final List<Map<String, dynamic>> serviceSizes = [
    {'size': 'Small', 'price': 25.0, 'hours': '1 H'},
    {'size': 'Medium', 'price': 50.0, 'hours': '2-3 H'},
    {'size': 'Large', 'price': 75.0, 'hours': '+4 H'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedCategoryAndSubCategories();
  }

  // Method to load the category and subcategories related to the selected service
  void _loadSelectedCategoryAndSubCategories() {
    // Find the category corresponding to the selected service
    selectedCategory = widget.availableCategories.firstWhere(
      (category) => category.id == widget.selectedService.categoryId,
      orElse: () => widget.availableCategories.first, // Fallback if not found
    );

    // Find the related subcategories for the selected service
    selectedSubCategories = selectedCategory.subCategories.where((subCategory) {
      return subCategory.id == widget.selectedService.subCategoryId;
    }).toList();

    // Initialize quantities for each size
    for (var sizeOption in serviceSizes) {
      sizeQuantities[sizeOption['size']] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Cleaning Service"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCategorySection(), // Category section
              const SizedBox(height: 16),
              selectedSubCategories.isNotEmpty
                  ? _buildSubcategorySection()
                  : SizedBox(), // Task section
              const SizedBox(height: 16),
              _buildSizeSection(), // Size section
              const SizedBox(height: 16),
              _buildContinueButton(), // Continue button
            ],
          ),
        ),
      ),
    );
  }

  // Category Section with CustomCheckboxListTile
  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: widget.availableCategories.isNotEmpty
                ? widget.availableCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: CustomCheckboxListTile(
                        title: category.name,
                        value: selectedCategory.id == category.id,
                        onChanged: (bool? value) {
                          // Do nothing, only display
                        },
                      ),
                    );
                  }).toList()
                : const [Text("No categories available")],
          ),
        ],
      ),
    );
  }

  // Task (Subcategory) Section with CustomCheckboxListTile
  Widget _buildSubcategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Category Tasks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: selectedSubCategories.isNotEmpty
                ? selectedSubCategories.map((subCategory) {
                    return CustomCheckboxListTile(
                      title: subCategory.name,
                      value: true, // Mark selected tasks as checked
                      onChanged: (bool? value) {
                        // Do nothing, only display
                      },
                    );
                  }).toList()
                : [const Text('No tasks available')],
          ),
        ],
      ),
    );
  }

  // Size Section with independent selection and quantity control
  Widget _buildSizeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Size",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView(
            shrinkWrap: true, // Prevent RenderBox overflow
            physics: const NeverScrollableScrollPhysics(),
            children: serviceSizes.map((sizeOption) {
              return ListTile(
                leading: Checkbox(
                  value: selectedSize == sizeOption['size'],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedSize = sizeOption['size'];
                    });
                  },
                ),
                title: Text(
                    '${sizeOption['size']} - \$${sizeOption['price']} (${sizeOption['hours']})'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: selectedSize == sizeOption['size'] &&
                              sizeQuantities[sizeOption['size']]! > 0
                          ? () {
                              setState(() {
                                sizeQuantities[sizeOption['size']] =
                                    sizeQuantities[sizeOption['size']]! - 1;
                              });
                            }
                          : null,
                    ),
                    Text(sizeQuantities[sizeOption['size']].toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: selectedSize == sizeOption['size']
                          ? () {
                              setState(() {
                                sizeQuantities[sizeOption['size']] =
                                    sizeQuantities[sizeOption['size']]! + 1;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Continue button
  Widget _buildContinueButton() {
    return PrimaryButton(
      text: "Continue",
      onPressed: selectedSize != null && sizeQuantities[selectedSize]! > 0
          ? () {
              final selectedHours = serviceSizes
                  .firstWhere((s) => s['size'] == selectedSize)['hours'];

              // Navigate to the next screen (seconServiceScreen) with service, size, hours, and quantity
              Navigator.pushNamed(
                context,
                RouteNames
                    .seconServiceScreen, // Use the correct route name here
                arguments: {
                  'selectedService':
                      widget.selectedService, // Pass the selected service
                  'selectedSize': selectedSize, // Pass the selected size
                  'hours': selectedHours, // Pass the selected hours
                  'quantity': sizeQuantities[selectedSize], // Pass the quantity
                },
              );
            }
          : null,
    );
  }
}
