import 'package:ezpc_tasks_app/features/services/data/category_state.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategorySelector extends ConsumerWidget {
  final void Function(String categoryName) onCategorySelected;

  const CategorySelector({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider.state).state;

    // Cargamos las categorías desde Firebase usando categoryListProvider
    final categoryListAsyncValue = ref.watch(categoryListProvider);

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
      child: categoryListAsyncValue.when(
        data: (categories) {
          // Si hay una categoría seleccionada, verificamos si sigue siendo válida
          Category? validSelectedCategory;
          if (selectedCategory != null) {
            try {
              validSelectedCategory = categories.firstWhere(
                (category) => category.id == selectedCategory.id,
              );
            } catch (e) {
              validSelectedCategory = null;
            }
          }

          return DropdownButtonFormField<Category>(
            hint: const CustomText(text: "Category"),
            isDense: true,
            isExpanded: true,
            value:
                validSelectedCategory, // Si no hay categoría seleccionada, será null
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none, // Elimina el borde
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            ),
            onChanged: (value) {
              if (value != null) {
                ref.read(selectedCategoryProvider.state).state = value;
                ref.read(selectedSubCategoryProvider.state).state = null;
                // Guardamos el nombre de la categoría en lugar del ID
                onCategorySelected(value.name); // Guardar el nombre
              }
            },
            items:
                categories.map<DropdownMenuItem<Category>>((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
          );
        },
        loading: () => const CircularProgressIndicator(), // Indicador de carga
        error: (error, stack) => const Text('Error loading categories'),
      ),
    );
  }
}
