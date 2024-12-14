class Task {
  String id;
  final String taskId;
  final String taskName;
  final String firstName; // Nuevo campo
  final String lastName; // Nuevo campo
  final String slug; // Nuevo campo
  final String category;
  final String categoryId;
  final String subCategory;
  final double price;
  final double subCategoryprice;
  final String type;
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
  final String? additionalOption;
  final Map<String, String>? questionResponses;
  final int makeFeatured; // Nuevo campo
  final int isBanned; // Nuevo campo
  final int status; // Nuevo campo
  final String createdAt; // Nuevo campo
  final int approveByAdmin; // Nuevo campo
  final String averageRating; // Nuevo campo
  final int totalReview; // Nuevo campo
  final int totalOrder; // Nuevo campo
  final String providerId; // Nuevo campo
  final dynamic provider; // Nuevo campo
  final String details; // Nuevo campo
  final String duration; // Nuevo campo
  final String description; // Nuevo campo
  final String clientName; // Nuevo campo para el nombre del cliente
  final String clientLastName; // Nuevo campo para el apellido del cliente
  final String questions;

  Task({
    required this.id,
    required this.taskId,
    required this.taskName,
    required this.firstName,
    required this.lastName,
    required this.slug,
    required this.categoryId,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.subCategoryprice,
    required this.type,
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
    this.additionalOption,
    this.questionResponses,
    required this.makeFeatured,
    required this.isBanned,
    required this.status,
    required this.createdAt,
    required this.approveByAdmin,
    required this.averageRating,
    required this.totalReview,
    required this.totalOrder,
    required this.providerId,
    this.provider,
    required this.details,
    required this.duration,
    required this.description,
    required this.clientName, // Inicialización del nuevo campo
    required this.clientLastName, // Inicialización del nuevo campo
    required this.questions,
  });

  // Método para copiar la tarea con modificaciones
  Task copyWith({
    String? id,
    String? taskId,
    String? taskName,
    String? firstName,
    String? lastName,
    String? slug,
    String? categoryId,
    String? category,
    String? subCategory,
    double? price,
    double? subCategoryprice,
    String? type,
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
    String? additionalOption,
    Map<String, String>? questionResponses,
    int? makeFeatured,
    int? isBanned,
    int? status,
    String? createdAt,
    int? approveByAdmin,
    String? averageRating,
    int? totalReview,
    int? totalOrder,
    String? providerId,
    dynamic provider,
    String? details,
    String? duration,
    String? description,
    String? userId,
    String? clientName,
    String? clientLastName,
    String? questions,
  }) {
    return Task(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      type: type ?? this.type,
      price: price ?? this.price,
      subCategoryprice: subCategoryprice ?? this.subCategoryprice,
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
      questionResponses: questionResponses ?? this.questionResponses,
      makeFeatured: makeFeatured ?? this.makeFeatured,
      isBanned: isBanned ?? this.isBanned,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approveByAdmin: approveByAdmin ?? this.approveByAdmin,
      averageRating: averageRating ?? this.averageRating,
      totalReview: totalReview ?? this.totalReview,
      totalOrder: totalOrder ?? this.totalOrder,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
      details: details ?? this.details,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      clientLastName: clientLastName ?? this.clientLastName,
      questions: questions ?? this.questions,
    );
  }

  // Método para convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskName': taskName,
      'firstName': firstName,
      'lastName': lastName,
      'slug': slug,
      'categoryId': categoryId,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'subCategoryprice': subCategoryprice,
      'type': type,
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
      'questionResponses': questionResponses,
      'makeFeatured': makeFeatured,
      'isBanned': isBanned,
      'status': status,
      'createdAt': createdAt,
      'approveByAdmin': approveByAdmin,
      'averageRating': averageRating,
      'totalReview': totalReview,
      'totalOrder': totalOrder,
      'providerId': providerId,
      'provider': provider,
      'details': details,
      'duration': duration,
      'description': description,
      'clientName': clientName, // Conversión del nuevo campo
      'clientLastName': clientLastName, // Conversión del nuevo campo
      'questions': questions, // Conversión del nuevo campo
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskName: map['taskName'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      slug: map['slug'] ?? '',
      categoryId: map['categoryId'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      subCategoryprice: (map['subCategoryprice'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      requiresLicense: map['requiresLicense'] ?? false,
      licenseType: map['licenseType'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      licenseExpirationDate: map['licenseExpirationDate'] ?? '',
      workingDays: List<String>.from(map['workingDays'] ?? []),
      questions: map['questions'] ?? '',
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
      makeFeatured: map['makeFeatured'] ?? 0,
      isBanned: map['isBanned'] ?? 0,
      status: map['status'] ?? 1,
      createdAt: map['createdAt'] ?? '',
      approveByAdmin: map['approveByAdmin'] ?? 0,
      averageRating: map['averageRating'] ?? '0.0',
      totalReview: map['totalReview'] ?? 0,
      totalOrder: map['totalOrder'] ?? 0,
      providerId: map['providerId'] ?? '',
      provider: map['provider'],
      details: map['details'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
      clientName: map['clientName'] ?? '',
      clientLastName: map['clientLastName'] ?? '',
    );
  }
}
