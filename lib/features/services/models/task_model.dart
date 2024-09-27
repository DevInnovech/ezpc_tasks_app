import 'dart:convert';
import 'package:equatable/equatable.dart';

class Task extends Equatable {
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
  final String issueDate;
  final String phone;
  final String service;
  final String documentUrl;
  final List<String>? workingDays;
  final Map<String, Map<String, String>>? workingHours;
  final List<Map<String, String>>? specialDays;

  const Task({
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
    required this.issueDate,
    required this.phone,
    required this.service,
    required this.documentUrl,
    this.workingDays,
    this.workingHours,
    this.specialDays,
  });

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
    String? issueDate,
    String? phone,
    String? service,
    String? documentUrl,
    List<String>? workingDays,
    Map<String, Map<String, String>>? workingHours,
    List<Map<String, String>>? specialDays,
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
      issueDate: issueDate ?? this.issueDate,
      phone: phone ?? this.phone,
      service: service ?? this.service,
      documentUrl: documentUrl ?? this.documentUrl,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      specialDays: specialDays ?? this.specialDays,
    );
  }

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
      'issueDate': issueDate,
      'phone': phone,
      'service': service,
      'documentUrl': documentUrl,
      'workingDays': workingDays ?? [],
      'workingHours': workingHours != null
          ? workingHours!.map((key, value) => MapEntry(key, value))
          : {},
      'specialDays': specialDays != null
          ? specialDays!.map((day) => Map<String, String>.from(day)).toList()
          : [],
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      requiresLicense: map['requiresLicense'] ?? false,
      licenseType: map['licenseType'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      licenseExpirationDate: map['licenseExpirationDate'] ?? '',
      issueDate: map['issueDate'] ?? '',
      phone: map['phone'] ?? '',
      service: map['service'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workingHours: map['workingHours'] != null
          ? Map<String, Map<String, String>>.from(map['workingHours'])
          : {},
      specialDays: map['specialDays'] != null
          ? List<Map<String, String>>.from(map['specialDays'])
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        subCategory,
        price,
        imageUrl,
        requiresLicense,
        licenseType,
        licenseNumber,
        licenseExpirationDate,
        issueDate,
        phone,
        service,
        documentUrl,
        workingDays,
        workingHours,
        specialDays,
      ];
}
