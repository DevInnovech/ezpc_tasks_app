import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';

class ServiceModel {
  final String id;
  final String name;
  final String slug;
  final String price;
  final num? discount;
  final Category categoryId;
  final String subCategoryId;
  final String details;
  final String image;
  final List<String> packageFeature;
  final List<String> benefits;
  final List<String> whatYouWillProvide;
  final String? licenseDocument;
  final List<String>? workingDays;
  final List<Map<String, String>>? workingHours;
  final List<Map<String, String>>? specialDays;
  final String status;
  final ProviderModel? provider; // Proveedor asociado
  final String? type; // Tipo de servicio (horario, fijo, etc.)
  final bool? isFeatured;
  final num? totalRating;
  final num? totalReview;
  final num? isSlot;
  final String? duration;
  final String? visitType;
  final List<String>? attachments;
  final List<Map<String, dynamic>>? servicePackage; // Paquetes del servicio
  final int? providerId; // Nuevo campo agregado

  // Propiedades calculadas
  bool get isSlotAvailable => isSlot == 1;
  bool get isHourlyService => type == 'hourly';
  bool get isFixedService => type == 'fixed';
  bool get isFreeService => price == 0;

  ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discount,
    required this.categoryId,
    required this.subCategoryId,
    required this.details,
    required this.image,
    required this.packageFeature,
    required this.benefits,
    required this.whatYouWillProvide,
    this.licenseDocument,
    this.workingDays,
    this.workingHours,
    this.specialDays,
    required this.status,
    required this.provider,
    this.type,
    this.isFeatured,
    this.totalRating,
    this.totalReview,
    this.isSlot,
    this.duration,
    this.visitType,
    this.attachments,
    this.servicePackage,
    this.providerId, // Inicialización de providerId
  });

  // Factory method to convert from map
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      price: map['price'] ?? 0,
      discount: map['discount'],
      categoryId: Category.fromMap(map['category_id'] ?? {}),
      subCategoryId: map['sub_category_id'] ?? '',
      details: map['details'] ?? '',
      image: map['image'] ?? '',
      packageFeature: List<String>.from(map['package_feature'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      whatYouWillProvide: List<String>.from(map['what_you_will_provide'] ?? []),
      licenseDocument: map['license_document'],
      workingDays: List<String>.from(map['working_days'] ?? []),
      workingHours: List<Map<String, String>>.from(map['working_hours'] ?? []),
      specialDays: List<Map<String, String>>.from(map['special_days'] ?? []),
      status: map['status'] ?? '',
      provider: map['provider'] != null
          ? ProviderModel.fromMap(map['provider'])
          : null,
      type: map['type'],
      isFeatured: map['is_featured'],
      totalRating: map['total_rating'],
      totalReview: map['total_review'],
      isSlot: map['is_slot'],
      duration: map['duration'],
      visitType: map['visit_type'],
      attachments: List<String>.from(map['attachments'] ?? []),
      servicePackage:
          List<Map<String, dynamic>>.from(map['service_package'] ?? []),
      providerId: map['provider_id'], // Asignación de providerId
    );
  }

  // Method to convert the model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'discount': discount,
      'category_id': categoryId.toMap(),
      'sub_category_id': subCategoryId,
      'details': details,
      'image': image,
      'package_feature': packageFeature,
      'benefits': benefits,
      'what_you_will_provide': whatYouWillProvide,
      'license_document': licenseDocument,
      'working_days': workingDays,
      'working_hours': workingHours,
      'special_days': specialDays,
      'status': status,
      'provider': provider?.toMap(),
      'type': type,
      'is_featured': isFeatured,
      'total_rating': totalRating,
      'total_review': totalReview,
      'is_slot': isSlot,
      'duration': duration,
      'visit_type': visitType,
      'attachments': attachments,
      'service_package': servicePackage,
      'provider_id': providerId, // Conversión de providerId a Map
    };
  }
}
