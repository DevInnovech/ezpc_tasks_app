// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ServiceArea extends Equatable {
  final int id;
  final String name;
  final String slug;
  const ServiceArea({
    required this.id,
    required this.name,
    required this.slug,
  });



  ServiceArea copyWith({
    int? id,
    String? name,
    String? slug,
  }) {
    return ServiceArea(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
    };
  }

  factory ServiceArea.fromMap(Map<String, dynamic> map) {
    return ServiceArea(
      id: map['id'] as int,
      name: map['name'] as String,
      slug: map['slug'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceArea.fromJson(String source) => ServiceArea.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, name, slug];
}
