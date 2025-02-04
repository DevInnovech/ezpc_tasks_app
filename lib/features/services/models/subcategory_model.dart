// subcategory_model.dart
class SubCategory {
  final String id;

  final String name;
  final List<String>? additionalOptions;
  final String? image;
  final String categoryid;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryid,
    this.additionalOptions,
    this.image,
  });

  // Convierte la subcategoría a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'additionalOptions': additionalOptions ?? [],
    };
  }

  // Crea una subcategoría a partir de un mapa
  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      additionalOptions: List<String>.from(map['additionalOptions'] ?? []),
      categoryid: map['categoryid'] ?? '',
    );
  }
}
