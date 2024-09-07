import 'dart:convert';

// Modelo de subcategoría
class SubCategory {
  final String id;
  final String name;
  final List<String>? additionalOptions;

  SubCategory({
    required this.id,
    required this.name,
    this.additionalOptions,
  });

  // Convertir la subcategoría a un mapa (para almacenar en Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'additionalOptions': additionalOptions ?? [],
    };
  }

  // Crear una subcategoría a partir de un mapa (al leer desde Firebase)
  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      additionalOptions: List<String>.from(map['additionalOptions'] ?? []),
    );
  }

  // Convertir la subcategoría a JSON
  String toJson() => json.encode(toMap());

  // Crear una subcategoría a partir de JSON
  factory SubCategory.fromJson(String source) =>
      SubCategory.fromMap(json.decode(source));
}
