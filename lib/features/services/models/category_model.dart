import 'dart:convert';
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

  // Convertir la categoría a un mapa (para almacenar en Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subCategories': subCategories.map((sub) => sub.toMap()).toList(),
    };
  }

  // Crear una categoría a partir de un mapa (al leer desde Firebase)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      subCategories: List<SubCategory>.from(
        map['subCategories']?.map((x) => SubCategory.fromMap(x)) ?? [],
      ),
    );
  }

  // Convertir la categoría a JSON
  String toJson() => json.encode(toMap());

  // Crear una categoría a partir de JSON
  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));
}

// Ejemplo de lista de categorías:par aprobar
final categories = [
  Category(
    id: '1.1',
    name: 'Cleaning Commercial / Residential Cleaning',
    subCategories: [
      SubCategory(id: '1.1.1', name: 'Deep cleaning'),
      SubCategory(id: '1.1.2', name: 'Move-in/move-out cleaning'),
      SubCategory(id: '1.1.3', name: 'Post-construction cleaning'),
    ],
    // pathimage: KImages.service01, // Este tiene imagen.
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
          name: 'Type of business (Ex. Restaurant, kitchen, night club, etc)'),
    ],
    //  pathimage: 'https://example.com/image2.jpg', // Este tiene imagen.
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
    //pathimage: 'https://example.com/image3.jpg', // Este tiene imagen.
  ),
];
