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
        id: '1.1',
        name: 'Commercial / Residential Cleaning',
        subCategories: [
          SubCategory(id: '1.1.1', name: 'Deep cleaning'),
          SubCategory(id: '1.1.2', name: 'Move-in/move-out cleaning'),
          SubCategory(id: '1.1.3', name: 'Post-construction cleaning'),
          SubCategory(id: '1.1.4', name: 'Carpet cleaning'),
          SubCategory(id: '1.1.5', name: 'Window cleaning'),
          SubCategory(id: '1.1.6', name: 'Floor cleaning and maintenance'),
          SubCategory(id: '1.1.7', name: 'Air duct cleaning'),
          SubCategory(id: '1.1.8', name: 'Pressure washing'),
          SubCategory(id: '1.1.9', name: 'Post-event cleaning'),
          SubCategory(id: '1.1.10', name: 'Laundry and ironing'),
          SubCategory(id: '1.1.11', name: 'Blind and curtain cleaning'),
          SubCategory(id: '1.1.12', name: 'Gutter cleaning'),
        ],
      ),
      Category(
        id: '1.2',
        name: 'Residential Cleaning',
        subCategories: [
          SubCategory(id: '1.2.1', name: 'Chimney cleaning'),
        ],
        // pathimage: null, // No tiene imagen.
      ),
      Category(
        id: '1.3',
        name: 'Commercial Cleaning',
        subCategories: [
          SubCategory(id: '1.3.1', name: 'Office cleaning'),
          SubCategory(id: '1.3.2', name: 'Janitorial services'),
          SubCategory(
              id: '1.3.3',
              name:
                  'Type of business (e.g., Restaurant, kitchen, night club, etc.)'),
        ],
      ),
      Category(
        id: '1.4',
        name: 'Car Wash',
        subCategories: [
          SubCategory(
            id: '1.4.1',
            name: 'Exterior Cleaning',
            additionalOptions: [
              'Hand Washing',
              'Pressure Washing',
              'Pre-Wash Treatment: Wheel and Tire Cleaning',
              'Hand Drying',
              'Paint Protection',
              'Glass Cleaning',
              'Underbody Wash',
              'Waxing',
            ],
          ),
          SubCategory(
            id: '1.4.2',
            name: 'Interior Cleaning',
            additionalOptions: [
              'Vacuuming',
              'Interior Wiping',
              'Trunk Cleaning',
              'Stain Removal',
              'Window Cleaning',
              'Leather Conditioning',
              'Odor Elimination',
              'Floor Mat Cleaning',
              'Interior Protection',
              'Make (e.g., Toyota, Chevrolet)',
              'Model (e.g., Corolla, 4Runner)',
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
              additionalOptions: ['Interior', 'Exterior', 'Wood', 'Drywall']),
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

    // Guardar todas las categorías
    for (var category in categories) {
      await saveCategory(category);
    }
  }
}
