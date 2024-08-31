import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';

// Provider for selected category
final selectedCategoryProvider = StateProvider<Category?>((ref) {
  return null; // Initial state is null
});

// Provider for selected subcategory
final selectedSubCategoryProvider = StateProvider<SubCategory?>((ref) {
  return null; // Initial state is null
});
