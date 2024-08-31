import 'dart:convert';
import 'package:equatable/equatable.dart';

class ServiceProductStateModel extends Equatable {
  final String id; // Added field for ID
  final String name;
  final String slug;
  final String price;
  final String categoryId;
  final String subCategoryId; // Added field for SubCategory
  final String details;
  final String image;
  final List<String> packageFeature;
  final List<String> benefits;
  final List<String> whatYouWillProvide;
  final String? licenseDocument; // Added field for License Document
  final List<String>? workingDays; // Added field for Working Days
  final List<Map<String, String>>?
      workingHours; // Added field for Working Hours
  final List<Map<String, String>>? specialDays; // Added field for Special Days
  final String status; // Added field for Status

  const ServiceProductStateModel({
    required this.id, // New ID field
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
  });

  ServiceProductStateModel copyWith({
    String? id, // New ID field
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
    String? status,
  }) {
    return ServiceProductStateModel(
      id: id ?? this.id, // New ID field
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
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id, // New ID field
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
      'status': status,
    };
  }

  factory ServiceProductStateModel.fromMap(Map<String, dynamic> map) {
    return ServiceProductStateModel(
      id: map['id'] ?? '', // New ID field
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
      status: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceProductStateModel.fromJson(String source) =>
      ServiceProductStateModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        id, // New ID field
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
        status,
      ];
}
