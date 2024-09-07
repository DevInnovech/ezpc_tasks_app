import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/category_repository.dart';

// Provider para manejar el repositorio de categorías
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// Provider para cargar las categorías desde Firebase
final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final categoryRepo = ref.read(categoryRepositoryProvider);
  return await categoryRepo.getCategories();
});

// Provider para la categoría seleccionada
final selectedCategoryProvider = StateProvider<Category?>((ref) {
  return null; // Estado inicial es null
});

// Provider para la subcategoría seleccionada
final selectedSubCategoryProvider = StateProvider<SubCategory?>((ref) {
  return null; // Estado inicial es null
});
