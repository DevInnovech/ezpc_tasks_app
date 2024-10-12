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
  const CategoryPricingStep({super.key});

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceImage(
            onImageSelected: (String imageUrl) {
              if (currentTask != null) {
                ref.read(taskProvider.notifier).updateTask(
                      imageUrl: imageUrl,
                    );
              }
            },
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
                ref.read(isRateAppliedToSubcategoriesProvider.notifier).state =
                    value ?? false;
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

            // Dropdown para seleccionar "Additional Options"
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
                    // Usar Dropdown con isExpanded para evitar overflow
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true, // Esto permite que el texto se ajuste
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

                          // Actualizar en la tarea actual la opción seleccionada
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
          ],
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
    );
  }
}
