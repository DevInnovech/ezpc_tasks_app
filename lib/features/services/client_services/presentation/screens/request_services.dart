import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class PremierServiceScreen extends ConsumerStatefulWidget {
  final String taskId;

  const PremierServiceScreen({
    super.key,
    required this.taskId,
    required ServiceModel selectedService,
    required List<Category> availableCategories,
  });

  @override
  _PremierServiceScreenState createState() => _PremierServiceScreenState();
}

class _PremierServiceScreenState extends ConsumerState<PremierServiceScreen> {
  late ServiceModel selectedService = ServiceModel(
    id: '',
    name: 'Default Service',
    slug: '',
    price: '0.0',
    categoryId: Category(
      id: '',
      name: 'Default Category',
      subCategories: [],
      pathimage: null,
      categoryId: '',
    ),
    subCategoryId: '',
    details: '',
    image: '',
    packageFeature: [],
    benefits: [],
    whatYouWillProvide: [],
    licenseDocument: '',
    workingDays: [],
    workingHours: [],
    specialDays: [],
    status: 'Inactive',
    provider: null,
  );

  late List<Category> availableCategories = [];
  late List<SubCategory> selectedSubCategories = [];
  bool isLoading = true;

  String? selectedSize;
  int sizeQuantity = 0;
  late Map<String, int> sizeQuantities = {}; // Track quantities for each size

  List<Map<String, dynamic>> serviceSizes = []; // Empty initially

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    try {
      // Cargar datos del servicio desde Firebase
      final doc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      // Cargar categorías desde Firebase

      if (doc.exists) {
        final data = doc.data()!;
        selectedService = ServiceModel(
          id: doc.id,
          name: data['name'] ?? '',
          slug: data['slug'] ?? '',
          price: data['price']?.toString() ?? '0.0',
          categoryId: data['categoryId'] ?? '',
          subCategoryId: data['subCategoryId'] ?? '',
          details: data['details'] ?? '',
          image: data['imageUrl'] ?? '',
          packageFeature: data['packageFeature'] != null
              ? List<String>.from(data['packageFeature'])
              : [],
          benefits: data['benefits'] != null
              ? List<String>.from(data['benefits'])
              : [],
          whatYouWillProvide: data['whatYouWillProvide'] != null
              ? List<String>.from(data['whatYouWillProvide'])
              : [],
          licenseDocument: data['licenseDocument'] ?? '',
          workingDays: data['workingDays'] != null
              ? List<String>.from(data['workingDays'])
              : [],
          workingHours: data['workingHours'] != null
              ? List<Map<String, String>>.from(data['workingHours']
                  .map((hour) => Map<String, String>.from(hour)))
              : [],
          specialDays: data['specialDays'] != null
              ? List<Map<String, String>>.from(data['specialDays']
                  .map((day) => Map<String, String>.from(day)))
              : [],
          status: data['status'] ?? 'Inactive',
          provider: null,
        );

        // Calcular tamaños dinámicamente basados en el precio del task
        final double basePrice = double.tryParse(selectedService.price) ?? 0.0;
        serviceSizes = [
          {'size': 'Small', 'price': basePrice, 'hours': '1 H'},
          {'size': 'Medium', 'price': basePrice * 2, 'hours': '2 H'},
          {'size': 'Large', 'price': basePrice * 3, 'hours': '3 H'},
        ];

        for (var sizeOption in serviceSizes) {
          sizeQuantities[sizeOption['size']] = 0;
        }

        // Cargar categorías desde Firebase
        final categoryDocs =
            await FirebaseFirestore.instance.collection('categories').get();

        availableCategories = categoryDocs.docs.map((doc) {
          final categoryData = doc.data();
          final subCategories = (categoryData['subCategories'] as List? ?? [])
              .map((sub) => SubCategory.fromMap(sub))
              .toList();

          return Category(
            id: doc.id,
            name: categoryData['subCategory'] ?? '',
            subCategories: subCategories,
            pathimage: null,
            categoryId: '',
          );
        }).toList();

        // Obtener subcategorías relacionadas
        selectedSubCategories = availableCategories
            .firstWhere(
              (category) => category.id == selectedService.categoryId,
              orElse: () => availableCategories.first,
            )
            .subCategories
            .where((subCategory) =>
                subCategory.id == selectedService.subCategoryId)
            .toList();
      }
    } catch (e) {
      debugPrint('Error al cargar los datos del servicio: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: selectedService.name),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCategorySection(),
              const SizedBox(height: 16),
              selectedSubCategories.isNotEmpty
                  ? _buildSubcategorySection()
                  : const SizedBox(),
              const SizedBox(height: 16),
              _buildSizeSection(),
              const SizedBox(height: 16),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            children: availableCategories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: CustomCheckboxListTile(
                  title: category.name,
                  value: selectedService.categoryId == category.id,
                  onChanged: (bool? value) {},
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
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
                      value: true, // Marcar como seleccionada por defecto
                      onChanged: (bool? value) {
                        // Implementar la lógica si es necesario
                      },
                    );
                  }).toList()
                : [
                    const Text(
                      'No tasks available',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
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
            shrinkWrap: true,
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
                    '${sizeOption['size']} - \$${sizeOption['price'].toStringAsFixed(2)} (${sizeOption['hours']})'),
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

  Widget _buildContinueButton() {
    return PrimaryButton(
      text: "Continue",
      onPressed: selectedSize != null && sizeQuantities[selectedSize]! > 0
          ? () {
              final selectedHours = serviceSizes
                  .firstWhere((s) => s['size'] == selectedSize)['hours'];

              Navigator.pushNamed(
                context,
                RouteNames.seconServiceScreen,
                arguments: {
                  'selectedService': selectedService,
                  'selectedSize': selectedSize,
                  'hours': selectedHours,
                  'quantity': sizeQuantities[selectedSize],
                },
              );
            }
          : null,
    );
  }
}
