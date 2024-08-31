import 'package:ezpc_tasks_app/features/services/data/add_repositoey.dart';
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

class CategoryPricingStep extends ConsumerWidget {
  const CategoryPricingStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    final isLicenseRequired = ref.watch(isLicenseRequiredProvider);
    final isRateAppliedToSubcategories =
        ref.watch(isRateAppliedToSubcategoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceImage(),
          const CategorySelector(),
          if (selectedCategory != null) ...[
            const PriceInputWidget(),
            CustomCheckboxListTile(
              title: 'Apply to all sub-category',
              value: isRateAppliedToSubcategories,
              onChanged: (bool? value) {
                ref.read(isRateAppliedToSubcategoriesProvider.notifier).state =
                    value ?? false;
              },
              activeColor:
                  primaryColor, // Puedes pasar cualquier color que desees
              checkColor:
                  Colors.white, // Puedes personalizar el color del check
            ),

            const SubCategorySelector(),
            if (selectedSubCategory != null && !isRateAppliedToSubcategories)
              const PriceInputWidget(), // Rate for SubCategory if not applied to all
          ],
          CustomCheckboxListTile(
            title: 'I hold a professional license',
            value: isLicenseRequired,
            onChanged: (bool? value) {
              ref.read(isLicenseRequiredProvider.notifier).state =
                  value ?? false;
            },
            activeColor:
                primaryColor, // Puedes pasar cualquier color que desees
            checkColor: Colors.white, // Puedes personalizar el color del check
          ),
          AbsorbPointer(
            absorbing: !isLicenseRequired,
            child: Opacity(
              opacity: isLicenseRequired ? 1.0 : 0.5,
              child: const LicenseDocumentInput(),
            ),
          ),
        ],
      ),
    );
  }
}
