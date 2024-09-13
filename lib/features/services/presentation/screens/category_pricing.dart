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
                return Task(
                  id: currentTask?.id ?? const Uuid().v4(),
                  name: currentTask?.name ?? '',
                  category: currentTask?.category ?? '',
                  subCategory: currentTask?.subCategory ?? '',
                  price: currentTask?.price ?? 0.0,
                  imageUrl: imageUrl,
                  requiresLicense: currentTask?.requiresLicense ?? false,
                  workingDays: currentTask?.workingDays ?? [],
                  workingHours: currentTask?.workingHours ?? {},
                  specialDays: currentTask?.specialDays ?? [],
                  licenseType: '',
                  licenseNumber: '',
                  licenseExpirationDate: '',
                );
              });
            },
          ),
          CategorySelector(
            onCategorySelected: (String category) {
              ref.read(taskProvider.notifier).updateTask((currentTask) {
                return Task(
                  id: currentTask?.id ?? const Uuid().v4(),
                  name: currentTask?.name ?? '',
                  category: category,
                  subCategory:
                      '', // Resetear la subcategoría cuando cambie la categoría
                  price: currentTask?.price ?? 0.0,
                  imageUrl: currentTask?.imageUrl ?? '',
                  requiresLicense: currentTask?.requiresLicense ?? false,
                  workingDays: currentTask?.workingDays ?? [],
                  workingHours: currentTask?.workingHours ?? {},
                  specialDays: currentTask?.specialDays ?? [],
                  licenseType: '',
                  licenseNumber: '',
                  licenseExpirationDate: '',
                );
              });
            },
          ),
          if (selectedCategory != null) ...[
            RateInputWidget(
              onRateChanged: (double price) {
                ref.read(taskProvider.notifier).updateTask((currentTask) {
                  return currentTask!.copyWith(price: price);
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
                    return currentTask!.copyWith(price: price);
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
                return Task(
                  id: currentTask?.id ?? const Uuid().v4(),
                  name: currentTask?.name ?? '',
                  category: currentTask?.category ?? '',
                  subCategory: currentTask?.subCategory ?? '',
                  price: currentTask?.price ?? 0.0,
                  imageUrl: currentTask?.imageUrl ?? '',
                  requiresLicense: value ?? false,
                  workingDays: currentTask?.workingDays ?? [],
                  workingHours: currentTask?.workingHours ?? {},
                  specialDays: currentTask?.specialDays ?? [],
                  licenseType: '',
                  licenseNumber: '',
                  licenseExpirationDate: '',
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
                    return currentTask!.copyWith(licenseType: licenseType);
                  });
                },
                onLicenseNumberChanged: (String licenseNumber) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!.copyWith(licenseNumber: licenseNumber);
                  });
                },
                onLicenseExpirationDateChanged: (String expirationDate) {
                  ref.read(taskProvider.notifier).updateTask((currentTask) {
                    return currentTask!
                        .copyWith(licenseExpirationDate: expirationDate);
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
