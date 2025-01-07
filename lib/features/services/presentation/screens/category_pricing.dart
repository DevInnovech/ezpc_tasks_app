import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/license_document_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/service_image.dart';

class CategoryPricingStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const CategoryPricingStep({super.key, required this.formKey});

  @override
  _CategoryPricingStepState createState() => _CategoryPricingStepState();
}

class _CategoryPricingStepState extends ConsumerState<CategoryPricingStep> {
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  final List<String> _selectedServices = [];
  bool _isLoadingCategories = true;

  bool _applyGeneralPrice = false;
  double? _generalPrice;
  final Map<String, double> _servicePrices = {};

  bool _showProfessionalLicense = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final categories =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories: $e")),
      );
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _loadServices(String categoryId) {
    final category = _categories.firstWhere((cat) => cat['id'] == categoryId);
    final services =
        List<Map<String, dynamic>>.from(category['services'] ?? []);

    setState(() {
      _services = services;
      _selectedServices.clear();
      _servicePrices.clear();
      _generalPrice = null;
      _applyGeneralPrice = false;
    });
  }

  Widget _buildServiceDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text("Select Services"),
      value: null,
      items: _services.map((service) {
        return DropdownMenuItem<String>(
          value: service['name'],
          child: StatefulBuilder(
            builder: (context, setStateCheckbox) {
              return CheckboxListTile(
                title: Text(service['name']),
                value: _selectedServices.contains(service['name']),
                onChanged: (bool? isChecked) {
                  setState(() {
                    if (isChecked == true) {
                      _selectedServices.add(service['name']);
                    } else {
                      _selectedServices.remove(service['name']);
                      _servicePrices.remove(service['name']);
                    }
                    _applyGeneralPrice = false;
                  });
                  setStateCheckbox(() {});
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        );
      }).toList(),
      onChanged: (_) {},
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      });

                      if (categoryId != null) {
                        _loadServices(categoryId);
                      }
                    },
                  ),
            const SizedBox(height: 16),
            if (_services.isNotEmpty) ...[
              _buildSectionTitle(context, 'Select Services'),
              _buildServiceDropdown(),
            ],
            if (_selectedServices.length > 1)
              _buildRadioButton(
                "Apply General Price for All Services",
                _applyGeneralPrice,
                (value) {
                  setState(() {
                    _applyGeneralPrice = value ?? false;
                    if (_applyGeneralPrice) _servicePrices.clear();
                  });
                },
              ),
            if (_applyGeneralPrice)
              TextFormField(
                initialValue: _generalPrice?.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter General Price',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _generalPrice = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            if (!_applyGeneralPrice)
              ..._selectedServices.map((service) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    initialValue:
                        _servicePrices[service]?.toStringAsFixed(2) ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price for $service',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _servicePrices[service] = double.tryParse(value) ?? 0.0;

                        // Filtrar preguntas solo de los servicios seleccionados
                        Map<String, String> questionR = {};
                        for (final selectedService in _selectedServices) {
                          final serviceData = _services.firstWhere(
                            (s) => s['name'] == selectedService,
                            orElse: () => {},
                          );

                          if (serviceData.isNotEmpty &&
                              serviceData.containsKey('questions')) {
                            final questions = List<dynamic>.from(
                                serviceData['questions'] ?? []);
                            for (final question in questions) {
                              questionR[question] =
                                  selectedService; // Respuesta inicial
                            }
                          }
                        }
                        ref.read(taskProvider.notifier).updateTask(
                            category: _categories.firstWhere((category) =>
                                category['id'] == _selectedCategoryId)['name'],
                            categoryId: _selectedCategoryId,
                            selectedTasks: _servicePrices,
                            questions: questionR);
                      });
                    },
                  ),
                );
              }),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Professional License'),
            _buildRadioButton(
              "I hold a professional license",
              _showProfessionalLicense,
              (value) {
                setState(() {
                  _showProfessionalLicense = value ?? false;
                });
              },
            ),
            if (_showProfessionalLicense)
              LicenseDocumentInput(
                onLicenseTypeChanged: (String licenseType) {},
                onLicenseNumberChanged: (String licenseNumber) {},
                onPhoneChanged: (String phone) {},
                onIssueDateChanged: (String issueDate) {},
                onLicenseExpirationDateChanged: (String expirationDate) {},
                onDocumentSelected: (File file) {},
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: value,
          onChanged: onChanged,
        ),
        Text(title),
      ],
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
