class Category {
  final String id;
  final String name;
  final String imageUrl;
  final bool isFeatured;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isFeatured,
    required this.subcategories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'subcategories': subcategories.map((sub) => sub.toMap()).toList(),
    };
  }
}

class Subcategory {
  final String name;
  final List<String> services;

  Subcategory({
    required this.name,
    required this.services,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'services': services,
    };
  }
}
