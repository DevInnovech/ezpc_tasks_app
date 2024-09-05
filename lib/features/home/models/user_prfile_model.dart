// import 'dart:convert';
//
// import 'package:equatable/equatable.dart';
//
// class UserProfileModel extends Equatable {
//   final int id;
//   final String name;
//   final String? image;
//   final String email;
//   final String? phone;
//   final int? countryId;
//   final int? stateId;
//   final int? cityId;
//   final String? zipCode;
//   final String? emailVerifiedAt;
//   final int status;
//   final String? address;
//   final String isVendor;
//   final String emailVerified;
//   final String? verifyToken;
//   final String createdAt;
//   final String updatedAt;
//   const UserProfileModel({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.email,
//     this.phone,
//     this.countryId,
//     this.stateId,
//     this.cityId,
//     this.zipCode,
//     this.emailVerifiedAt,
//     required this.status,
//     this.address,
//     required this.isVendor,
//     required this.emailVerified,
//     this.verifyToken,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   @override
//   List<Object?> get props {
//     return [
//       id,
//       name,
//       image,
//       email,
//       phone,
//       countryId,
//       stateId,
//       emailVerifiedAt,
//       status,
//       zipCode,
//       address,
//       isVendor,
//       emailVerified,
//       verifyToken,
//       createdAt,
//       updatedAt,
//     ];
//   }
//
//   UserProfileModel copyWith({
//     int? id,
//     String? name,
//     String? image,
//     String? email,
//     String? phone,
//     String? countryId,
//     String? stateId,
//     String? cityId,
//     String? zipCode,
//     String? emailVerifiedAt,
//     String? status,
//     String? address,
//     String? isVendor,
//     String? emailVerified,
//     String? verifyToken,
//     String? createdAt,
//     String? updatedAt,
//   }) {
//     return UserProfileModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       image: image ?? this.image,
//       email: email ?? this.email,
//       phone: phone ?? this.phone,
//       countryId: countryId ?? this.countryId,
//       stateId: stateId ?? this.stateId,
//       cityId: cityId ?? this.cityId,
//       emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
//       status: status ?? this.status,
//       address: address ?? this.address,
//       zipCode: zipCode ?? this.zipCode,
//       isVendor: isVendor ?? this.isVendor,
//       emailVerified: emailVerified ?? this.emailVerified,
//       verifyToken: verifyToken ?? this.verifyToken,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};
//
//     result.addAll({'id': id});
//     result.addAll({'name': name});
//     // if (image != null) {
//     result.addAll({'image': image});
//     // }
//     result.addAll({'email': email});
//     if (phone != null) {
//       result.addAll({'phone': phone});
//     }
//     if (zipCode != null) {
//       result.addAll({'zip_code': zipCode});
//     }
//     if (countryId != null) {
//       result.addAll({'country_id': countryId});
//     }
//     if (stateId != null) {
//       result.addAll({'state_id': stateId});
//     }
//     if (cityId != null) {
//       result.addAll({'city_id': cityId});
//     }
//     if (emailVerifiedAt != null) {
//       result.addAll({'email_verified_at': emailVerifiedAt});
//     }
//     result.addAll({'status': status});
//     if (address != null) {
//       result.addAll({'address': address});
//     }
//     result.addAll({'is_vendor': isVendor});
//     result.addAll({'email_verified': emailVerified});
//     if (verifyToken != null) {
//       result.addAll({'verify_token': verifyToken});
//     }
//     result.addAll({'created_at': createdAt});
//     result.addAll({'updated_at': updatedAt});
//
//     return result;
//   }
//
//   factory UserProfileModel.fromMap(Map<String, dynamic> map) {
//     return UserProfileModel(
//       id: map['id']?.toInt() ?? 0,
//       name: map['name'] ?? '',
//       image: map['image'] ?? '',
//       email: map['email'] ?? '',
//       phone: map['phone'],
//       countryId: map['country_id'],
//       stateId: map['state_id'],
//       cityId: map['city_id'],
//       zipCode: map['zip_code'],
//       emailVerifiedAt: map['email_verified_at'],
//       status: map['status'] ?? '',
//       address: map['address'],
//       isVendor: map['is_vendor'] ?? '',
//       emailVerified: map['email_verified'] ?? '',
//       verifyToken: map['verify_token'],
//       createdAt: map['created_at'] ?? '',
//       updatedAt: map['updated_at'] ?? '',
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory UserProfileModel.fromJson(String source) =>
//       UserProfileModel.fromMap(json.decode(source));
//
//   @override
//   String toString() {
//     return 'UserProfileModel(id: $id, name: $name, image: $image, email: $email, phone: $phone, country_id: $countryId, state_id: $stateId, cityId: $cityId, email_verified_at: $emailVerifiedAt, status: $status, address: $address, zipCode: $zipCode, is_vendor: $isVendor, email_verified: $emailVerified, verify_token: $verifyToken, created_at: $createdAt, updated_at: $updatedAt)';
//   }
// }
import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final int id;
  final String name;
  final String? image;
  final String email;
  final String? phone;
  final String? designation;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? zipCode;
  final String? emailVerifiedAt;
  final int status;
  final String? address;
  final String isVendor;
  final String emailVerified;
  final String? verifyToken;
  final String createdAt;
  final String updatedAt;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
    required this.designation,
    this.phone,
    this.countryId,
    this.stateId,
    this.cityId,
    this.zipCode,
    this.emailVerifiedAt,
    required this.status,
    this.address,
    required this.isVendor,
    required this.emailVerified,
    this.verifyToken,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      email,
      phone,
      designation,
      countryId,
      stateId,
      emailVerifiedAt,
      status,
      zipCode,
      address,
      isVendor,
      emailVerified,
      verifyToken,
      createdAt,
      updatedAt,
    ];
  }

  UserProfileModel copyWith({
    int? id,
    String? name,
    String? image,
    String? email,
    String? phone,
    String? designation,
    int? countryId,
    int? stateId,
    int? cityId,
    String? zipCode,
    String? emailVerifiedAt,
    int? status,
    String? address,
    String? isVendor,
    String? emailVerified,
    String? verifyToken,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      status: status ?? this.status,
      address: address ?? this.address,
      zipCode: zipCode ?? this.zipCode,
      isVendor: isVendor ?? this.isVendor,
      emailVerified: emailVerified ?? this.emailVerified,
      verifyToken: verifyToken ?? this.verifyToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    // if (image != null) {
    result.addAll({'image': image});
    // }
    result.addAll({'email': email});
    result.addAll({'designation': designation});
    if (phone != null) {
      result.addAll({'phone': phone});
    }
    if (zipCode != null) {
      result.addAll({'zip_code': zipCode});
    }
    if (countryId != null) {
      result.addAll({'country_id': countryId});
    }
    if (stateId != null) {
      result.addAll({'state_id': stateId});
    }
    if (cityId != null) {
      result.addAll({'city_id': cityId});
    }
    if (emailVerifiedAt != null) {
      result.addAll({'email_verified_at': emailVerifiedAt});
    }
    result.addAll({'status': status});
    if (address != null) {
      result.addAll({'address': address});
    }
    result.addAll({'is_vendor': isVendor});
    result.addAll({'email_verified': emailVerified});
    if (verifyToken != null) {
      result.addAll({'verify_token': verifyToken});
    }
    result.addAll({'created_at': createdAt});
    result.addAll({'updated_at': updatedAt});

    return result;
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      designation: map['designation'],
      countryId: map['country_id'] != null
          ? int.parse(map['country_id'].toString())
          : 0,
      stateId:
          map['state_id'] != null ? int.parse(map['state_id'].toString()) : 0,
      cityId: map['city_id'] != null ? int.parse(map['city_id'].toString()) : 0,
      zipCode: map['zip_code'],
      emailVerifiedAt: map['email_verified_at'] ?? '',
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
      address: map['address'] ?? '',
      isVendor: map['is_vendor'] ?? '',
      emailVerified: map['email_verified'] ?? '',
      verifyToken: map['verify_token'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfileModel(id: $id, name: $name, image: $image, email: $email, phone: $phone, country_id: $countryId, state_id: $stateId, cityId: $cityId, email_verified_at: $emailVerifiedAt, status: $status, address: $address, zipCode: $zipCode, is_vendor: $isVendor, email_verified: $emailVerified, verify_token: $verifyToken, created_at: $createdAt, updated_at: $updatedAt)';
  }
}
