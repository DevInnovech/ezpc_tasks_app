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
<<<<<<< HEAD

  // Convertir la subcategoría a un mapa (para almacenar en Firebase)
=======
>>>>>>> 86dd372e60725d9cff4da8f5df06b684f428abd7
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
<<<<<<< HEAD
      'additionalOptions': additionalOptions ?? [],
    };
  }

  // Crear una subcategoría a partir de un mapa (al leer desde Firebase)
=======
      'additionalOptions': additionalOptions,
    };
  }

>>>>>>> 86dd372e60725d9cff4da8f5df06b684f428abd7
  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      additionalOptions: List<String>.from(map['additionalOptions'] ?? []),
    );
  }
<<<<<<< HEAD

  // Convertir la subcategoría a JSON
  String toJson() => json.encode(toMap());

  // Crear una subcategoría a partir de JSON
  factory SubCategory.fromJson(String source) =>
      SubCategory.fromMap(json.decode(source));
=======
>>>>>>> 86dd372e60725d9cff4da8f5df06b684f428abd7
}
