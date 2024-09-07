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
