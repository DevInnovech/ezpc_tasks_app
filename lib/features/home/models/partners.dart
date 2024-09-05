// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class PartnerModel extends Equatable {
  final int id;
  final String link;
  final String logo;
  final int status;
  final String createdAt;
  final String updatedAt;
  const PartnerModel({
    required this.id,
    required this.link,
    required this.logo,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  PartnerModel copyWith({
    int? id,
    String? link,
    String? logo,
    int? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      link: link ?? this.link,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'link': link,
      'logo': logo,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      id: map['id'] ?? 0,
      link: map['link'] ?? "",
      logo: map['logo'] ?? "",
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
      createdAt: map['created_at'] ?? "",
      updatedAt: map['updated_at'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory PartnerModel.fromJson(String source) =>
      PartnerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      link,
      logo,
      status,
      createdAt,
      updatedAt,
    ];
  }
}
