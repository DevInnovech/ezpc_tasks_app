// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Testomonial extends Equatable {
  final int id;
  final String name;
  final String image;
  final String designation;
  final String comment;
  final int status;
  const Testomonial({
    required this.id,
    required this.name,
    required this.image,
    required this.designation,
    required this.comment,
    required this.status,
  });

  Testomonial copyWith({
    int? id,
    String? name,
    String? image,
    String? designation,
    String? comment,
    int? status,
  }) {
    return Testomonial(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      designation: designation ?? this.designation,
      comment: comment ?? this.comment,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'designation': designation,
      'comment': comment,
      'status': status,
    };
  }

  factory Testomonial.fromMap(Map<String, dynamic> map) {
    return Testomonial(
      id: map['id'] ?? 0,
      name: map['name'] ?? "",
      image: map['image'] ?? "",
      designation: map['designation'] ?? "",
      comment: map['comment'] ?? "",
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Testomonial.fromJson(String source) =>
      Testomonial.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      image,
      designation,
      comment,
      status,
    ];
  }
}
