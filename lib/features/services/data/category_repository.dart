import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import '../models/subcategory_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para guardar una categoría en Firebase (incluyendo subcategorías)
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

  // Método para obtener todas las categorías desde Firebase (incluyendo subcategorías)
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching categories from Firebase: $e');
      rethrow;
    }
  }

  // Método para actualizar una categoría existente en Firebase
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

  // Método para eliminar una categoría en Firebase
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      print('Category deleted successfully');
    } catch (e) {
      print('Error deleting category from Firebase: $e');
      rethrow;
    }
  }

  // Método para guardar todas las categorías predefinidas en Firebase
  Future<void> savePredefinedCategories() async {
    final categories = [
      Category(
        id: '1.1',
        name: 'Cleaning Commercial / Residential Cleaning',
        subCategories: [
          SubCategory(id: '1.1.1', name: 'Deep cleaning'),
          SubCategory(id: '1.1.2', name: 'Move-in/move-out cleaning'),
          SubCategory(id: '1.1.3', name: 'Post-construction cleaning'),
        ],
      ),
      Category(
        id: '1.2',
        name: 'Residential Cleaning',
        subCategories: [
          SubCategory(id: '1.2.1', name: 'Chimney cleaning'),
        ],
      ),
      Category(
        id: '1.3',
        name: 'Commercial Cleaning',
        subCategories: [
          SubCategory(id: '1.3.1', name: 'Office cleaning'),
          SubCategory(id: '1.3.2', name: 'Janitorial services'),
        ],
      ),
      Category(
        id: '1.4',
        name: 'Car Wash',
        subCategories: [
          SubCategory(
            id: '1.4.1',
            name: 'Exterior cleaning',
            additionalOptions: [
              'Hand Washing',
              'Pressure Washing',
              'Pre-Wash Treatment',
              'Wheel and Tire Cleaning',
            ],
          ),
          SubCategory(
            id: '1.4.2',
            name: 'Interior cleaning',
            additionalOptions: [
              'Vacuuming',
              'Interior Wiping',
              'Trunk cleaning',
              'Stain Removal',
            ],
          ),
        ],
      ),
    ];

    // Guardar todas las categorías
    for (var category in categories) {
      await saveCategory(category);
    }
  }
}
