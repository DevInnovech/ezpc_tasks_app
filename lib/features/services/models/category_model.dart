import 'dart:convert';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';

class Category {
  final String id;
  final String name;
  final List<SubCategory> subCategories;
  final String? pathimage;

  Category({
    required this.id,
    required this.name,
    required this.subCategories,
    this.pathimage,
  });

  // Convertir la categoría a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subCategories': subCategories.map((sub) => sub.toMap()).toList(),
      'pathimage': pathimage,
    };
  }

  // Crear una categoría a partir de un mapa
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      subCategories: List<SubCategory>.from(
        map['subCategories']?.map((x) => SubCategory.fromMap(x)) ?? [],
      ),
      pathimage: map['pathimage'],
    );
  }

  // Convertir a JSON
  String toJson() => json.encode(toMap());

  // Crear desde JSON
  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));

  // Método para actualizar localmente la lista de categorías
  static void updateLocalCategories(List<Category> updatedCategories) {
    categories.clear();
    categories.addAll(updatedCategories);
    print('Categories updated locally.');
  }
}

// Ejemplo de lista de categorías:
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
