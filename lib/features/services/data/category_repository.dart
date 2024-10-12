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
      print(snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList());

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
        id: '1',
        name: 'Cleaning',
        subCategories: [
          SubCategory(
            id: '1.1',
            name: 'Commercial / Residential Cleaning',
            additionalOptions: [
              'Deep cleaning',
              'Move-in/move-out cleaning',
              'Post-construction cleaning',
              'Carpet cleaning',
              'Window cleaning',
              'Floor cleaning and maintenance',
              'Air duct cleaning',
              'Pressure washing',
              'Post-event cleaning',
              'Laundry and ironing',
              'Blind and curtain cleaning',
              'Gutter cleaning',
            ],
          ),
          SubCategory(
            id: '1.2',
            name: 'Residential Cleaning',
            additionalOptions: [
              'Chimney cleaning',
            ],
          ),
          SubCategory(
            id: '1.3',
            name: 'Commercial Cleaning',
            additionalOptions: [
              'Office cleaning',
              'Janitorial services',
              'Type of business (e.g., Restaurant, kitchen, night club, etc.)',
            ],
          ),
          SubCategory(
            id: '1.4',
            name: 'Car Wash',
            additionalOptions: [
              'Exterior Cleaning',
              'Hand Washing',
              'Pressure Washing',
              'Pre-Wash Treatment: Wheel and Tire Cleaning',
              'Hand Drying',
              'Paint Protection',
              'Glass Cleaning',
              'Underbody Wash',
              'Waxing',
              'Interior Cleaning',
              'Vacuuming',
              'Interior Wiping',
              'Trunk Cleaning',
              'Stain Removal',
              'Window Cleaning',
              'Leather Conditioning',
              'Odor Elimination',
              'Floor Mat Cleaning',
              'Interior Protection',
            ],
          ),
        ],
      ),
      Category(
        id: '2',
        name: 'Yard Work / Landscaping',
        subCategories: [
          SubCategory(id: '2.1', name: 'Lawn Mowing'),
          SubCategory(
            id: '2.2',
            name: 'Lawn Care',
            additionalOptions: [
              'Mowing',
              'Fertilizing',
              'Edging',
              'Weed control',
              'Weed removal',
              'Hedge trimming',
              'Tree pruning',
              'Leaf raking and removal',
              'Mulching',
              'Planting and transplanting',
              'Garden bed maintenance',
              'Lawn aeration',
              'Irrigation system installation and maintenance',
              'Sod installation',
              'Lawn dethatching',
              'Pest control',
              'Spring/fall cleanup',
              'Garden design and landscaping',
              'Edging and border installation',
              'Fertilization',
              'Lawn renovation',
              'Outdoor lighting installation',
            ],
          ),
        ],
      ),
      Category(
        id: '3',
        name: 'Help Moving / Assembly',
        subCategories: [
          SubCategory(id: '3.1', name: 'Furniture Assembly'),
          SubCategory(id: '3.2', name: 'Appliance Installation'),
          SubCategory(
            id: '3.3',
            name: 'Moving Assistance',
            additionalOptions: [
              'Address From / Address To',
              'How many rooms?',
              'How many floors?',
              'Need a truck?',
              'Need a car?',
              'Loading',
              'Unloading',
              'Transporting belongings during a move',
              'Residential / Commercial relocation',
              'Packing',
              'Unpacking',
              'Heavy lifting',
              'Disassembly',
              'Reassembly',
              'Specialty Item Handling (e.g., pianos, antiques, artwork)',
              'Customized Services (e.g., packing fragile items, setting up home theater systems, arranging furniture)',
            ],
          ),
        ],
      ),
      Category(
        id: '4',
        name: 'Handyman',
        subCategories: [
          SubCategory(
            id: '4.1',
            name: 'Plumbing Repairs',
            additionalOptions: [
              'Fixing leaky faucets',
              'Unclogging drains',
              'Repairing toilets',
              'Installing fixtures',
              'Other minor plumbing issues',
            ],
          ),
          SubCategory(
            id: '4.2',
            name: 'Electrical Repairs',
            additionalOptions: [
              'Replacing light switches',
              'Outlets',
              'Light fixtures',
              'Ceiling fans',
              'Other electrical components',
              'Troubleshooting electrical problems',
            ],
          ),
          SubCategory(
            id: '4.3',
            name: 'Painting',
            additionalOptions: ['Interior', 'Exterior', 'Wood', 'Drywall'],
          ),
          SubCategory(id: '4.4', name: 'Drywall Repair'),
          SubCategory(id: '4.5', name: 'Minor Repairs'),
          SubCategory(id: '4.6', name: 'Home Maintenance Tasks'),
        ],
      ),
      Category(
        id: '5',
        name: 'Errands',
        subCategories: [
          SubCategory(id: '5.1', name: 'Need a Car?'),
          SubCategory(id: '5.2', name: 'Need a Truck?'),
        ],
      ),
    ];

    try {
      // Paso 1: Borrar todas las categorías existentes
      final collectionRef = _firestore.collection('categories');
      final snapshot = await collectionRef.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('All categories deleted successfully.');

      // Paso 2: Guardar las nuevas categorías predefinidas
      for (var category in categories) {
        await saveCategory(category);
      }

      print('All predefined categories saved successfully.');
    } catch (e) {
      print('Error deleting or saving categories: $e');
      rethrow;
    }
  }
}
