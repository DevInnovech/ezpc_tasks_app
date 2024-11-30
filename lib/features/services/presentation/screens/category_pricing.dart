import 'dart:io';
import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
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
  final GlobalKey<FormState> formKey;

  const CategoryPricingStep({super.key, required this.formKey});

  @override
  _CategoryPricingStepState createState() => _CategoryPricingStepState();
}

class _CategoryPricingStepState extends ConsumerState<CategoryPricingStep> {
  String? _selectedAdditionalOption;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    final isLicenseRequired = ref.watch(isLicenseRequiredProvider);
    final isRateAppliedToSubcategories =
        ref.watch(isRateAppliedToSubcategoriesProvider);
    final taskState = ref.watch(taskProvider);
    final Task? currentTask = taskState.currentTask;

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
                if (currentTask != null) {
                  ref
                      .read(taskProvider.notifier)
                      .updateTask(imageUrl: imageUrl);
                }
              },
            ),
            if (currentTask?.imageUrl.isEmpty ?? true)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select an image.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Choose Category'),
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
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Set Pricing'),
              RateInputWidget(
                onRateChanged: (double price) {
                  if (currentTask != null) {
                    ref.read(taskProvider.notifier).updateTask(price: price);
                  }
                },
              ),
              CustomCheckboxListTile(
                title: 'Apply pricing to all subcategories',
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
              if (selectedSubCategory != null) ...[
                _buildAdditionalOptions(
                    context, currentTask, selectedSubCategory),
                const SizedBox(height: 16),
                _buildSectionTitle(context, 'Subcategory Pricing'),
                RateInputWidget(
                  onRateChanged: (double subCategoryPrice) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            subCategoryprice: subCategoryPrice,
                          );
                    }
                  },
                ),
              ],
            ],
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Professional License'),
            CustomCheckboxListTile(
              title: 'I hold a professional license',
              value: isLicenseRequired,
              onChanged: (bool? value) {
                ref.read(isLicenseRequiredProvider.notifier).state =
                    value ?? false;

                if (currentTask != null) {
                  ref.read(taskProvider.notifier).updateTask(
                        requiresLicense: value ?? false,
                      );
                }
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
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            licenseType: licenseType,
                          );
                    }
                  },
                  onLicenseNumberChanged: (String licenseNumber) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            licenseNumber: licenseNumber,
                          );
                    }
                  },
                  onPhoneChanged: (String phone) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            phone: phone,
                          );
                    }
                  },
                  onIssueDateChanged: (String issueDate) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            issueDate: issueDate,
                          );
                    }
                  },
                  onLicenseExpirationDateChanged: (String expirationDate) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            licenseExpirationDate: expirationDate,
                          );
                    }
                  },
                  onDocumentSelected: (File file) {
                    if (currentTask != null) {
                      ref.read(taskProvider.notifier).updateTask(
                            documentUrl: file.path,
                          );
                    }
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

  Widget _buildAdditionalOptions(
      BuildContext context, Task? currentTask, var selectedSubCategory) {
    final List<String> additionalOptions =
        List<String>.from(selectedSubCategory.additionalOptions ?? []);

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Additional Options'),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedAdditionalOption,
            hint: const Text('Select an additional option'),
            items: additionalOptions
                .map((option) => DropdownMenuItem<String>(
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
        ],
      ),
    );
  }
}
