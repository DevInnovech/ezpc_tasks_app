class Task {
  final String id;
  final String taskId;
  final String taskName;
  final Map<String, double> selectedTasks; // NUEVO CAMPO
  final Map<String, String>? assignments; // NUEVO CAMPO
  final String firstName;
  final String lastName;
  final String slug;
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
  final List<Map<String, dynamic>> specialDays;
  final String documentUrl;
  final String phone;
  final String service;
  final String issueDate;
  final String? additionalOption;
  final Map<String, String>? questionResponses;
  final Map<String, String>? questions;
  final int makeFeatured;
  final int isBanned;
  final int status;
  final String createdAt;
  final int approveByAdmin;
  final String averageRating;
  final int totalReview;
  final int totalOrder;
  final String providerId;
  final dynamic provider;
  final String details;
  final String duration;
  final String description;
  final String clientName;
  final String clientLastName;
  final List<Map<String, dynamic>>? collaborators;

  Task({
    required this.id,
    required this.taskId,
    required this.taskName,
    required this.selectedTasks,
    required this.assignments,
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
    required this.questions,
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
    required this.clientName,
    required this.clientLastName,
    this.collaborators,
  });

  // Método copyWith
  Task copyWith({
    String? id,
    String? taskId,
    String? taskName,
    Map<String, double>? selectedTasks, // NUEVO PARÁMETRO
    Map<String, String>? assignments,
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
    List<Map<String, dynamic>>? specialDays,
    String? documentUrl,
    String? phone,
    String? service,
    String? issueDate,
    String? additionalOption,
    Map<String, String>? questionResponses,
    Map<String, String>? questions,
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
    String? clientName,
    String? clientLastName,
    List<Map<String, dynamic>>? collaborators, // NUEVO PARÁMETRO
  }) {
    return Task(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      selectedTasks: selectedTasks ?? this.selectedTasks, // NUEVO CAMPO
      assignments: assignments ?? this.assignments,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      price: price ?? this.price,
      subCategoryprice: subCategoryprice ?? this.subCategoryprice,
      type: type ?? this.type,
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
      questions: questions ?? this.questions,
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
      collaborators: collaborators ?? this.collaborators, // NUEVO CAMPO
    );
  }

  // Convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskName': taskName,
      'selectedTasks': selectedTasks, // NUEVO CAMPO
      'assignments': assignments,
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
      'questions': questions,
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
      'clientName': clientName,
      'clientLastName': clientLastName,
      'collaborators': collaborators, // NUEVO CAMPO
    };
  }

  // Crear desde mapa
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskName: map['taskName'] ?? '',
      selectedTasks: map['selectedTasks'] != null && map['selectedTasks'] is Map
          ? Map<String, double>.from(
              map['selectedTasks']
                  .map((key, value) => MapEntry(key, value.toDouble())),
            )
          : {}, // Ensure default is an empty map if not present or invalid

      assignments: map['assignments'] != null && map['assignments'] is Map
          ? Map<String, String>.from(
              map['assignments']
                  .map((key, value) => MapEntry(key, value.toString())),
            )
          : {}, // Ensure default is an empty map if not present or invalid
      collaborators: map['collaborators'] != null
          ? List<Map<String, dynamic>>.from(map['collaborators'])
          : null, // NUEVO CAMPO

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
      questions: Map<String, String>.from(map['questions'] ?? {}),
      workingHours: (map['workingHours'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as Map<dynamic, dynamic>).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ),
            ),
          ) ??
          {},
      specialDays: List<Map<String, dynamic>>.from(map['specialDays'] ?? []),
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
      averageRating: map['averageRating'] ?? '',
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
