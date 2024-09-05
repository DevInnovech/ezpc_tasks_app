import 'dart:convert';

import 'package:equatable/equatable.dart';

class ReviewUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String image;
  final String phone;
  final String designation;
  final int status;
  final int isProvider;
  final int stateId;
  final int cityId;
  final String address;
  final String createdAt;
  const ReviewUser({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.phone,
    required this.designation,
    required this.status,
    required this.isProvider,
    required this.stateId,
    required this.cityId,
    required this.address,
    required this.createdAt,
  });

  ReviewUser copyWith({
    int? id,
    String? name,
    String? email,
    String? image,
    String? phone,
    String? designation,
    int? status,
    int? isProvider,
    int? stateId,
    int? cityId,
    String? address,
    String? createdAt,
  }) {
    return ReviewUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      status: status ?? this.status,
      isProvider: isProvider ?? this.isProvider,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'phone': phone,
      'designation': designation,
      'status': status,
      'is_provider': isProvider,
      'state_id': stateId,
      'stateId': cityId,
      'address': address,
      'createdAt': createdAt,
    };
  }

  factory ReviewUser.fromMap(Map<String, dynamic> map) {
    return ReviewUser(
      id: map['id'] as int,
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      image: map['image'] ?? "",
      phone: map['phone'] ?? "",
      designation: map['designation'] ?? "",
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
      isProvider: map['is_provider'] != null
          ? int.parse(map['is_provider'].toString())
          : 0,
      stateId:
          map['state_id'] != null ? int.parse(map['state_id'].toString()) : 0,
      cityId: map['stateId'] != null ? int.parse(map['stateId'].toString()) : 0,
      address: map['address'] ?? "",
      createdAt: map['created_at'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewUser.fromJson(String source) =>
      ReviewUser.fromMap(json.decode(source) as Map<String, dynamic>);

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
      designation,
      status,
      isProvider,
      stateId,
      cityId,
      address,
      createdAt,
    ];
  }
}
