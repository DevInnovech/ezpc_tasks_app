class SubCategory {
  final String id;
  final String name;
  final List<String> additionalOptions;

  SubCategory({
    required this.id,
    required this.name,
    this.additionalOptions = const [],
  });
}
