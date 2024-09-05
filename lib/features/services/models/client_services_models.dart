import 'dart:convert';
import 'package:equatable/equatable.dart';

// Modelo adaptado de los servicios para el cliente (sin campos internos como providerId, status, etc.)
class ServiceClientModel extends Equatable {
  final String name;
  final String slug;
  final String price;
  final String categoryId;
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

  const ServiceClientModel({
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
  });

  ServiceClientModel copyWith({
    String? name,
    String? slug,
    String? price,
    String? categoryId,
    String? subCategoryId,
    String? details,
    String? image,
    List<String>? packageFeature,
    List<String>? benefits,
    List<String>? whatYouWillProvide,
    String? licenseDocument,
    List<String>? workingDays,
    List<Map<String, String>>? workingHours,
    List<Map<String, String>>? specialDays,
  }) {
    return ServiceClientModel(
      name: name ?? this.name,
      slug: slug ?? this.slug,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      details: details ?? this.details,
      image: image ?? this.image,
      packageFeature: packageFeature ?? this.packageFeature,
      benefits: benefits ?? this.benefits,
      whatYouWillProvide: whatYouWillProvide ?? this.whatYouWillProvide,
      licenseDocument: licenseDocument ?? this.licenseDocument,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      specialDays: specialDays ?? this.specialDays,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'slug': slug,
      'price': price,
      'category_id': categoryId,
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
    };
  }

  factory ServiceClientModel.fromMap(Map<String, dynamic> map) {
    return ServiceClientModel(
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      price: map['price'] ?? '',
      categoryId: map['category_id'] ?? '',
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
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceClientModel.fromJson(String source) =>
      ServiceClientModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        name,
        slug,
        price,
        categoryId,
        subCategoryId,
        details,
        image,
        packageFeature,
        benefits,
        whatYouWillProvide,
        licenseDocument,
        workingDays,
        workingHours,
        specialDays,
      ];
}
