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

  get pathimage => null;
}
