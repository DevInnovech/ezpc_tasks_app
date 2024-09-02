import 'package:ezpc_tasks_app/features/services/data/add_repositoey.dart';
import 'package:ezpc_tasks_app/features/services/data/category_state.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider.state).state;

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
      child: DropdownButtonFormField<Category>(
        hint: const CustomText(text: "Category"),
        isDense: true,
        isExpanded: true,
        value: selectedCategory,
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
            ref.read(selectedCategoryProvider.state).state = value;
            ref.read(selectedSubCategoryProvider.state).state = null;
            ref.read(isLicenseRequiredProvider.state).state =
                false; // Reset license requirement
          }
        },
        items: categories.map<DropdownMenuItem<Category>>((Category category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Text(category.name),
          );
        }).toList(),
      ),
    );
  }
}
