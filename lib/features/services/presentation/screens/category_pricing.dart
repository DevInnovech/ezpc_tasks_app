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
import 'package:uuid/uuid.dart';
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
    final task = ref.watch(taskProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceImage(
            onImageSelected: (String imageUrl) {
              ref.read(taskProvider.notifier).updateTask((currentTask) {
                // Actualizar el Task existente con la imagen seleccionada
                return currentTask!
                    .copyWith(imageUrl: imageUrl, documentUrl: '');
              });
            },
          ),
          CategorySelector(
            onCategorySelected: (String category) {
              ref.read(taskProvider.notifier).updateTask((currentTask) {
                // Crear un nuevo Task si no existe
                return currentTask != null
                    ? currentTask.copyWith(
                        category: category,
                        subCategory: '',
                        documentUrl: '', // Resetear subcategoría
                      )
                    : Task(
                        id: const Uuid().v4(),
                        name: '',
                        category: category,
                        subCategory: '',
                        price: 0.0,
                        imageUrl: '',
                        requiresLicense: false,
                        licenseType: '',
                        licenseNumber: '',
                        licenseExpirationDate: '',
                        workingDays: const [],
                        workingHours: const {},
                        specialDays: const [],
                        documentUrl: '',
                        phone: '',
                        service: '',
                        issueDate: '',
                      );
              });
            },
          ),
          if (selectedCategory != null) ...[
            RateInputWidget(
              onRateChanged: (double price) {
                ref.read(taskProvider.notifier).updateTask((currentTask) {
                  // Actualizar el Task existente con el nuevo precio
                  return currentTask!.copyWith(price: price, documentUrl: '');
                });
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
                ref.read(taskProvider.notifier).updateTask((currentTask) {
                  return currentTask!.copyWith(subCategory: subCategory);
                });
              },
            ),
            if (selectedSubCategory != null && !isRateAppliedToSubcategories)
              RateInputWidget(
                onRateChanged: (double price) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    // Actualizar el Task existente con el precio de la subcategoría
                    return currentTask!.copyWith(price: price, documentUrl: '');
                  });
                },
              ),
          ],
          CustomCheckboxListTile(
            title: 'I hold a professional license',
            value: isLicenseRequired,
            onChanged: (bool? value) {
              ref.read(isLicenseRequiredProvider.notifier).state =
                  value ?? false;

              ref.read(taskProvider.notifier).updateTask((currentTask) {
                // Asegúrate de que el valor de requiresLicense se mantenga actualizado
                return currentTask!.copyWith(
                  requiresLicense:
                      value ?? false, // Mantén este valor actualizado
                  licenseType: currentTask
                      .licenseType, // Mantén otros campos sin modificar
                  licenseNumber: currentTask.licenseNumber,
                  licenseExpirationDate: currentTask.licenseExpirationDate,
                  phone: currentTask.phone,
                  service: currentTask.service,
                  issueDate: currentTask.issueDate,
                  documentUrl: currentTask
                      .documentUrl, // Mantener si ya se guardó un documento
                );
              });
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
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!
                        .copyWith(licenseType: licenseType, documentUrl: '');
                  });
                },
                onLicenseNumberChanged: (String licenseNumber) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!.copyWith(
                        licenseNumber: licenseNumber, documentUrl: '');
                  });
                },
                onPhoneChanged: (String phone) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!.copyWith(phone: phone, documentUrl: '');
                  });
                },
                onServiceChanged: (String service) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!
                        .copyWith(service: service, documentUrl: '');
                  });
                },
                onIssueDateChanged: (String issueDate) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!
                        .copyWith(issueDate: issueDate, documentUrl: '');
                  });
                },
                onLicenseExpirationDateChanged: (String expirationDate) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!.copyWith(
                        licenseExpirationDate: expirationDate, documentUrl: '');
                  });
                },
                onDocumentSelected: (File file) {
                  // Aquí puedes manejar el archivo seleccionado y subirlo a tu servidor o almacenamiento en la nube
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!.copyWith(documentUrl: file.path);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
