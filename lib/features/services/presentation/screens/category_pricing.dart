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

class CategoryPricingStep extends ConsumerWidget {
  const CategoryPricingStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    final isLicenseRequired = ref.watch(isLicenseRequiredProvider);
    final isRateAppliedToSubcategories =
        ref.watch(isRateAppliedToSubcategoriesProvider);
    final taskState = ref.watch(taskProvider);
    final Task? currentTask =
        taskState.currentTask; // Usar `currentTask` directamente

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceImage(
            onImageSelected: (String imageUrl) {
              // Actualizar solo el campo `imageUrl` de `currentTask`
              if (currentTask != null) {
                ref.read(taskProvider.notifier).updateTask(
                      imageUrl: imageUrl,
                    );
              }
            },
          ),
          CategorySelector(
            onCategorySelected: (String category) {
              // Actualizar `category` y resetear `subCategory`
              if (currentTask != null) {
                ref.read(taskProvider.notifier).updateTask(
                      category: category,
                      subCategory:
                          '', // Resetear subcategoría cuando cambia la categoría
                    );
              }
            },
          ),
          if (selectedCategory != null) ...[
            RateInputWidget(
              onRateChanged: (double price) {
                // Actualizar solo `price` en `currentTask`
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
                // Actualizar solo `subCategory` en `currentTask`
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
          ],
          CustomCheckboxListTile(
            title: 'I hold a professional license',
            value: isLicenseRequired,
            onChanged: (bool? value) {
              ref.read(isLicenseRequiredProvider.notifier).state =
                  value ?? false;

              // Actualizar `requiresLicense` en `currentTask`
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
                  // Actualizar `licenseType` en `currentTask`
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
                onServiceChanged: (String service) {
                  if (currentTask != null) {
                    ref.read(taskProvider.notifier).updateTask(
                          service: service,
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
