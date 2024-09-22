import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para guardar una categoría en Firebase
  Future<void> saveCategory(Category category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .set(category.toMap());
      print('Category saved successfully');
    } catch (e) {
      print('Error saving category to Firebase: $e');
      rethrow;
    }
  }

  // Método para obtener todas las categorías desde Firebase
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching categories from Firebase: $e');
      rethrow;
    }
  }

  // Método para actualizar una categoría existente
  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());
      print('Category updated successfully');
    } catch (e) {
      print('Error updating category in Firebase: $e');
      rethrow;
    }
  }

  // Método para eliminar una categoría
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      print('Category deleted successfully');
    } catch (e) {
      print('Error deleting category from Firebase: $e');
      rethrow;
    }
  }
}
