import 'dart:convert';

import 'package:equatable/equatable.dart';

class ProviderModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final String createdAt;
  final String userName;
  const ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.createdAt,
    required this.userName,
  });

  ProviderModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    String? createdAt,
    String? userName,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'createdAt': createdAt,
      'userName': userName,
    };
  }

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
    return ProviderModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      phone: map['phone'] ?? "",
      image: map['image'] ?? "",
      createdAt: map['createdAt'] ?? "",
      userName: map['userName'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ProviderModel.fromJson(String source) =>
      ProviderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      email,
      phone,
      image,
      createdAt,
      userName,
    ];
  }
}
