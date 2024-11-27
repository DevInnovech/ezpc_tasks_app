// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class SliderModel extends Equatable {
  final int id;
  final String title;
  final String image;
  final int status;
  final int serial;
  final String createdAt;
  final String updatedAt;
  const SliderModel({
    required this.id,
    required this.title,
    required this.image,
    required this.status,
    required this.serial,
    required this.createdAt,
    required this.updatedAt,
  });

  SliderModel copyWith({
    int? id,
    String? title,
    String? titleTwo,
    String? image,
    int? status,
    int? serial,
    String? createdAt,
    String? updatedAt,
  }) {
    return SliderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      status: status ?? this.status,
      serial: serial ?? this.serial,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'image': image,
      'status': status,
      'serial': serial,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SliderModel.fromMap(Map<String, dynamic> map) {
    return SliderModel(
      id: map['id'] as int,
      title: map['title'] as String,
      image: map['image'] as String,
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
      serial: map['serial'] != null ? int.parse(map['serial'].toString()) : 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SliderModel.fromJson(String source) =>
      SliderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      title,
      image,
      status,
      serial,
      createdAt,
      updatedAt,
    ];
  }
}
