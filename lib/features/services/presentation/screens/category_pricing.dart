import 'dart:io';
/*import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/data/category_state.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/choose_category_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/choose_subcategory_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/license_document_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/rate_input_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/service_image.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import '../../data/task_provider.dart';

class CategoryPricingStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey; // Añadimos el formKey para validar*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
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

  double? _categoryRate; // Se asigna al modelo como `price`.
  double? _serviceRate; // Se asigna al modelo como `subCategoryprice`.

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final categories =
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
    });

    final category = _categories.firstWhere((cat) => cat['id'] == categoryId);
    final subCategories =
        List<Map<String, dynamic>>.from(category['subcategories'] ?? []);

    setState(() {
      _subCategories = subCategories;
      _isLoadingSubCategories = false;
      _services = []; // Reiniciar servicios al cargar nuevas subcategorías
    });
  }

  void _loadServices(String subCategoryName) {
    final subCategory =
        _subCategories.firstWhere((sub) => sub['name'] == subCategoryName);

    setState(() {
      _services = List<String>.from(subCategory['services'] ?? []);
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
            /*    ServiceImage(
              onImageSelected: (String imageUrl) {
                if (currentTask != null) {
                  ref.read(taskProvider.notifier).updateTask(
                        imageUrl: imageUrl,
                      );
                }
              },
            ),
            if (currentTask?.imageUrl.isEmpty ?? true)
              const Text(
                'Please select an image.',
                style: TextStyle(color: Colors.red),
              ),
            CategorySelector(
              onCategorySelected: (String category) {
                if (currentTask != null) {
                  ref.read(taskProvider.notifier).updateTask(
                        category: category,
                        subCategory: '',
                      );
                }
              },
            ),
            if (selectedCategory != null) ...[
              RateInputWidget(
                onRateChanged: (double price) {
                  if (currentTask != null) {
                    ref.read(taskProvider.notifier).updateTask(
                          price: price,
                        );
                  }
                },
              ),
              CustomCheckboxListTile(
                title: 'Apply to all sub-category',
                value: isRateAppliedToSubcategories,
                onChanged: (bool? value) {
                  ref
                      .read(isRateAppliedToSubcategoriesProvider.notifier)
                      .state = value ?? false;
                },
                activeColor: primaryColor,
                checkColor: Colors.white,
              ),
              SubCategorySelector(
                onSubCategorySelected: (String subCategory) {
                  if (currentTask != null) {
                    ref.read(taskProvider.notifier).updateTask(
                          subCategory: subCategory,
                        );
                  }
                },
              ),
              if (selectedSubCategory != null && !isRateAppliedToSubcategories)
                RateInputWidget(
                  onRateChanged: (double price) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            price: price,
                          );
                    }
                  },
                ),
              if (selectedSubCategory != null &&
                  selectedSubCategory.additionalOptions != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Options:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedAdditionalOption,
                          hint: const Text('Select an additional option'),
                          items: selectedSubCategory.additionalOptions!
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedAdditionalOption = newValue;
                            });

                            if (currentTask != null) {
                              ref.read(taskProvider.notifier).updateTask(
                                    service: newValue!,
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],*/
            _buildSectionTitle(context, 'Upload Service Image'),
            const SizedBox(height: 8),
            ServiceImage(
              onImageSelected: (String imageUrl) {
                // Actualizar el estado con la URL de la imagen
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
              activeColor: primaryColor,
              checkColor: Colors.white,
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
