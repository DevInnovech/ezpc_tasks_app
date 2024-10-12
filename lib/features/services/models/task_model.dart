class Task {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final double price;
  final String imageUrl;
  final bool requiresLicense;
  final String licenseType;
  final String licenseNumber;
  final String licenseExpirationDate;
  final List<String> workingDays;
  final Map<String, Map<String, String>> workingHours;
  final List<Map<String, String>> specialDays;
  final String documentUrl;
  final String phone;
  final String service;
  final String issueDate;
  final String? additionalOption; // Campo adicional opcional
  final Map<String, String>?
      questionResponses; // Nuevo campo para almacenar respuestas

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.imageUrl,
    required this.requiresLicense,
    required this.licenseType,
    required this.licenseNumber,
    required this.licenseExpirationDate,
    required this.workingDays,
    required this.workingHours,
    required this.specialDays,
    required this.documentUrl,
    required this.phone,
    required this.service,
    required this.issueDate,
    this.additionalOption, // Campo opcional
    this.questionResponses, // Campo opcional para respuestas
  });

  // Método para copiar la tarea con modificaciones
  Task copyWith({
    String? id,
    String? name,
    String? category,
    String? subCategory,
    double? price,
    String? imageUrl,
    bool? requiresLicense,
    String? licenseType,
    String? licenseNumber,
    String? licenseExpirationDate,
    List<String>? workingDays,
    Map<String, Map<String, String>>? workingHours,
    List<Map<String, String>>? specialDays,
    String? documentUrl,
    String? phone,
    String? service,
    String? issueDate,
    String? additionalOption, // Añadimos additionalOption
    Map<String, String>? questionResponses, // Añadimos questionResponses
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      requiresLicense: requiresLicense ?? this.requiresLicense,
      licenseType: licenseType ?? this.licenseType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpirationDate:
          licenseExpirationDate ?? this.licenseExpirationDate,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      specialDays: specialDays ?? this.specialDays,
      documentUrl: documentUrl ?? this.documentUrl,
      phone: phone ?? this.phone,
      service: service ?? this.service,
      issueDate: issueDate ?? this.issueDate,
      additionalOption: additionalOption ?? this.additionalOption,
      questionResponses: questionResponses ??
          this.questionResponses, // Asignamos las respuestas
    );
  }

  // Método para convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'imageUrl': imageUrl,
      'requiresLicense': requiresLicense,
      'licenseType': licenseType,
      'licenseNumber': licenseNumber,
      'licenseExpirationDate': licenseExpirationDate,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'specialDays': specialDays,
      'documentUrl': documentUrl,
      'phone': phone,
      'service': service,
      'issueDate': issueDate,
      'additionalOption': additionalOption,
      'questionResponses':
          questionResponses, // Guardar las respuestas en Firebase
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      requiresLicense: map['requiresLicense'] ?? false,
      licenseType: map['licenseType'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      licenseExpirationDate: map['licenseExpirationDate'] ?? '',
      workingDays: List<String>.from(map['workingDays'] ?? []),
      // Aquí aplicamos la conversión a Map<String, String>
      workingHours: (map['workingHours'] != null)
          ? (map['workingHours'] as Map<String, dynamic>).map((key, value) {
              return MapEntry(key, Map<String, String>.from(value));
            })
          : {},
      specialDays: List<Map<String, String>>.from(map['specialDays'] ?? []),
      documentUrl: map['documentUrl'] ?? '',
      phone: map['phone'] ?? '',
      service: map['service'] ?? '',
      issueDate: map['issueDate'] ?? '',
      additionalOption: map['additionalOption'],
      questionResponses:
          Map<String, String>.from(map['questionResponses'] ?? {}),
    );
  }
}
