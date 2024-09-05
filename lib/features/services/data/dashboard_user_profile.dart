// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class DashbaordUserProfile extends Equatable {

  final int? id;
  final String? name;
  final String? image;
  final String? email;
  final String? phone;
  final String? address;
  final String status;
  final String isProvider;
  const DashbaordUserProfile({
    required this.id,
    required this.name,
    this.image,
    required this.email,
    this.phone,
    this.address,
    required this.status,
    required this.isProvider,
  });
 

  DashbaordUserProfile copyWith({
    int? id,
    String? name,
    String? image,
    String? email,
    String? phone,
    String? address,
    String? status,
    String? isProvider,
  }) {
    return DashbaordUserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      isProvider: isProvider ?? this.isProvider,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
      'isProvider': isProvider,
    };
  }

  factory DashbaordUserProfile.fromMap(Map<String, dynamic> map) {
    return DashbaordUserProfile(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      status: map['status'] ?? "",
      isProvider: map['isProvider'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory DashbaordUserProfile.fromJson(String source) => DashbaordUserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id!,
      name!,
      image!,
      email!,
      phone!,
      address!,
      status,
      isProvider,
    ];
  }
}
