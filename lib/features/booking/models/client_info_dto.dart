// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ClientInfoDto extends Equatable {
  final int id;
  final String name;
  final String email;
  final String image;
  final String phone;
  final String address;
  const ClientInfoDto({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.phone,
    required this.address,
  });

  ClientInfoDto copyWith({
    int? id,
    String? name,
    String? email,
    String? image,
    String? phone,
    String? address,
  }) {
    return ClientInfoDto(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'phone': phone,
      'address': address,
    };
  }

  factory ClientInfoDto.fromMap(Map<String, dynamic> map) {
    return ClientInfoDto(
      id: map['id'] as int,
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      image: map['image'] ?? "",
      phone: map['phone'] ?? "",
      address: map['address'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ClientInfoDto.fromJson(String source) => ClientInfoDto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      email,
      image,
      phone,
      address,
    ];
  }
}
