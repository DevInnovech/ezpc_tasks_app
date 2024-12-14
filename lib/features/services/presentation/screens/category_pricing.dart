import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/license_document_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/service_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';

class CategoryPricingStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const CategoryPricingStep({super.key, required this.formKey});

  @override
  _CategoryPricingStepState createState() => _CategoryPricingStepState();
}

class _CategoryPricingStepState extends ConsumerState<CategoryPricingStep> {
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String? _selectedServiceId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  List<String> _services = [];
  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = false;

  double? _categoryRate; // Asigna al modelo como `price`.
  double? _serviceRate; // Asigna al modelo como `subCategoryPrice`.

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Carga las categorías al iniciar
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    // Obtén todas las categorías desde Firestore
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final categories =
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

    setState(() {
      _categories = categories;
      _isLoadingCategories = false;

      // Reinicia la selección si no es válida
      if (!_categories.any((cat) => cat['id'] == _selectedCategoryId)) {
        _selectedCategoryId = null;
        _subCategories = [];
        _services = [];
      }
    });
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
    });

    // Obtén subcategorías y preguntas para la categoría seleccionada
    final category = _categories.firstWhere((cat) => cat['id'] == categoryId);
    final subCategories =
        List<Map<String, dynamic>>.from(category['subcategories'] ?? []);
    final questions =
        List<Map<String, dynamic>>.from(category['questions'] ?? []);

    setState(() {
      _subCategories = subCategories;
      _isLoadingSubCategories = false;

      // Reinicia las subcategorías y servicios seleccionados
      if (!_subCategories.any((sub) => sub['name'] == _selectedSubCategoryId)) {
        _selectedSubCategoryId = null;
        _services = [];
      }
    });
  }

  void _loadServices(String subCategoryName) {
    final subCategory =
        _subCategories.firstWhere((sub) => sub['name'] == subCategoryName);

    setState(() {
      _services = List<String>.from(subCategory['services'] ?? []);

      // Reinicia el servicio seleccionado si no es válido
      if (!_services.contains(_selectedServiceId)) {
        _selectedServiceId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLicenseRequired = ref.watch(isLicenseRequiredProvider);

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Upload Service Image'),
            const SizedBox(height: 8),
            ServiceImage(
              onImageSelected: (String imageUrl) {
                // Actualiza la URL de la imagen en el estado
                ref.read(taskProvider.notifier).updateTask(imageUrl: imageUrl);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Choose Category'),
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Select a category'),
                    items: _categories
                        .map((category) => DropdownMenuItem<String>(
                              value: category['id'],
                              child: Text(category['name']),
                            ))
                        .toList(),
                    onChanged: (String? categoryId) {
                      setState(() {
                        _selectedCategoryId = categoryId;
                        _selectedSubCategoryId = null;
                        _categoryRate = null;
                        _serviceRate = null;
                      });

                      if (categoryId != null) {
                        _loadSubCategories(categoryId);

                        final category = _categories
                            .firstWhere((cat) => cat['id'] == categoryId);

                        ref.read(taskProvider.notifier).updateTask(
                              category: category['name'],
                              categoryId: categoryId,
                            );
                      }
                    },
                  ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Category Rate'),
            TextFormField(
              initialValue: _categoryRate?.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Category Rate',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final rate = double.tryParse(value) ?? 0.0;
                setState(() {
                  _categoryRate = rate;
                });

                ref.read(taskProvider.notifier).updateTask(price: rate);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Choose Subcategory'),
            _isLoadingSubCategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedSubCategoryId,
                    hint: const Text('Select a subcategory'),
                    items: _subCategories
                        .map((subCategory) => DropdownMenuItem<String>(
                              value: subCategory['name'],
                              child: Text(subCategory['name']),
                            ))
                        .toList(),
                    onChanged: (String? subCategoryName) {
                      setState(() {
                        _selectedSubCategoryId = subCategoryName;
                        _serviceRate = null;
                        _selectedServiceId = null;
                      });

                      if (subCategoryName != null) {
                        _loadServices(subCategoryName);

                        ref.read(taskProvider.notifier).updateTask(
                              subCategory: subCategoryName,
                            );
                      }
                    },
                  ),
            const SizedBox(height: 16),
            if (_services.isNotEmpty)
              _buildSectionTitle(context, 'Choose Service'),
            if (_services.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedServiceId,
                hint: const Text('Select a service'),
                items: _services
                    .map((service) => DropdownMenuItem<String>(
                          value: service,
                          child: Text(service),
                        ))
                    .toList(),
                onChanged: (String? serviceId) {
                  setState(() {
                    _selectedServiceId = serviceId;
                  });

                  ref
                      .read(taskProvider.notifier)
                      .updateTask(service: serviceId);
                },
              ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Service Rate'),
            TextFormField(
              initialValue: _serviceRate?.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Service Rate',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final rate = double.tryParse(value) ?? 0.0;
                setState(() {
                  _serviceRate = rate;
                });

                ref
                    .read(taskProvider.notifier)
                    .updateTask(subCategoryprice: rate);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Professional License'),
            CustomCheckboxListTile(
              title: 'I hold a professional license',
              value: isLicenseRequired,
              onChanged: (bool? value) {
                ref.read(isLicenseRequiredProvider.notifier).state =
                    value ?? false;

                ref.read(taskProvider.notifier).updateTask(
                      requiresLicense: value ?? false,
                    );
              },
              activeColor: Colors.blue,
            ),
            AbsorbPointer(
              absorbing: !isLicenseRequired,
              child: Opacity(
                opacity: isLicenseRequired ? 1.0 : 0.5,
                child: LicenseDocumentInput(
                  onLicenseTypeChanged: (String licenseType) {
                    ref.read(taskProvider.notifier).updateTask(
                          licenseType: licenseType,
                        );
                  },
                  onLicenseNumberChanged: (String licenseNumber) {
                    ref.read(taskProvider.notifier).updateTask(
                          licenseNumber: licenseNumber,
                        );
                  },
                  onPhoneChanged: (String phone) {
                    ref.read(taskProvider.notifier).updateTask(
                          phone: phone,
                        );
                  },
                  onIssueDateChanged: (String issueDate) {
                    ref.read(taskProvider.notifier).updateTask(
                          issueDate: issueDate,
                        );
                  },
                  onLicenseExpirationDateChanged: (String expirationDate) {
                    ref.read(taskProvider.notifier).updateTask(
                          licenseExpirationDate: expirationDate,
                        );
                  },
                  onDocumentSelected: (File file) {
                    ref.read(taskProvider.notifier).updateTask(
                          documentUrl: file.path,
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
