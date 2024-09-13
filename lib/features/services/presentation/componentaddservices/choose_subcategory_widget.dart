import 'package:ezpc_tasks_app/features/services/data/category_state.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubCategorySelector extends ConsumerWidget {
  const SubCategorySelector(
      {super.key,
      required Null Function(String subCategory) onSubCategorySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider.state).state;
    final selectedSubCategory =
        ref.watch(selectedSubCategoryProvider.state).state;

    if (selectedCategory == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: scaffoldBgColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<SubCategory>(
        hint: const CustomText(text: "SubCategory"),
        isDense: true,
        isExpanded: true,
        value: selectedSubCategory,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide:
                BorderSide.none, // Elimina el borde para dejar solo la sombra
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        ),
        onChanged: (value) {
          if (value != null) {
            ref.read(selectedSubCategoryProvider.state).state = value;
          }
        },
        items: selectedCategory.subCategories
            .map<DropdownMenuItem<SubCategory>>((SubCategory subCategory) {
          return DropdownMenuItem<SubCategory>(
            value: subCategory,
            child: Text(subCategory.name),
          );
        }).toList(),
      ),
    );
  }
}
