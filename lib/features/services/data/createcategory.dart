class Category {
  final String id;
  final String name;
  final String imageUrl;
  final bool isFeatured;
  final List<Subcategory> subcategories;
  final List<Question> questions; // Nueva lista de preguntas

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isFeatured,
    required this.subcategories,
    required this.questions, // Agregar al constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'subcategories': subcategories.map((sub) => sub.toMap()).toList(),
      'questions': questions
          .map((question) => question.toMap())
          .toList(), // Mapear las preguntas
    };
  }
}

class Subcategory {
  final String name;
  final List<String> services;
  final List<Question> questions; // Nueva lista de preguntas

  Subcategory({
    required this.name,
    required this.services,
    required this.questions, // Agregar al constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'services': services,
      'questions': questions
          .map((question) => question.toMap())
          .toList(), // Mapear las preguntas
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<String>? options; // Opciones de respuesta, si las hay

  Question({
    required this.id,
    required this.text,
    this.options, // Opcional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
    };
  }
}
