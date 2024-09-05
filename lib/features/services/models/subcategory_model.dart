class SubCategory {
  final String id;
  final String name;
  final List<String> additionalOptions;

  SubCategory({
    required this.id,
    required this.name,
    this.additionalOptions = const [],
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'additionalOptions': additionalOptions,
    };
  }

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      additionalOptions: List<String>.from(map['additionalOptions'] ?? []),
    );
  }
}
