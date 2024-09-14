import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';

class ServiceModel {
  final String id;
  final String name;
  final String slug;
  final String price;
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
  late final ProviderModel provider; // Nuevo parámetro para el proveedor

  ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
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
    required this.provider, // Inicialización del proveedor
  });

  // Factory method to convert from map
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      price: map['price'] ?? '',
      categoryId: Category.fromMap(map['category_id'] ??
          {}), // Actualización para aceptar Category completo
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
      provider: ProviderModel.fromMap(
          map['provider'] ?? []), // Asignación del proveedor
    );
  }

  // Method to convert the model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'category_id': categoryId.toMap(), // Conversión de Category a Map
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
      'provider': provider.toMap(), // Conversión del proveedor a Map
    };
  }
}
