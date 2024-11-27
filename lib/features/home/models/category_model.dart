class Category {
  final String id;
  final String categoryId;
  final String name;
  final String? pathImage;
  final List<SubCategory>? subCategories;

  Category({
    required this.categoryId,
    required this.id,
    required this.name,
    this.pathImage,
    this.subCategories,
  });
}

class SubCategory {
  final List<String> additionalOptions;

  SubCategory({required this.additionalOptions});
}
