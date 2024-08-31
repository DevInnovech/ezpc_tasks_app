import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';

class Category {
  final String id;
  final String name;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.subCategories,
  });
}

final categories = [
  Category(
    id: '1.1',
    name: 'Cleaning Commercial / Residential Cleaning',
    subCategories: [
      SubCategory(id: '1.1.1', name: 'Deep cleaning'),
      SubCategory(id: '1.1.2', name: 'Move-in/move-out cleaning'),
      SubCategory(id: '1.1.3', name: 'Post-construction cleaning'),
      // Add more subcategories here
    ],
  ),
  Category(
    id: '1.2',
    name: 'Residential Cleaning',
    subCategories: [
      SubCategory(id: '1.2.1', name: 'Chimney cleaning'),
      // Add more subcategories here
    ],
  ),
  Category(
    id: '1.3',
    name: 'Commercial Cleaning',
    subCategories: [
      SubCategory(id: '1.3.1', name: 'Office cleaning'),
      SubCategory(id: '1.3.2', name: 'Janitorial services'),
      SubCategory(
          id: '1.3.3',
          name: 'Type of business (Ex. Restaurant, kitchen, night club, etc)'),
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
          // Add more options here
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
          // Add more options here
        ],
      ),
    ],
  ),
  // Add more categories following the same structure
];
