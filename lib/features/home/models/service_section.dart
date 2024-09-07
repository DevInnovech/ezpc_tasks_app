// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ServiceSection extends Equatable {
  final bool visibility;
  final String title;
  final String description;
  const ServiceSection({
    required this.visibility,
    required this.title,
    required this.description,
  });

  ServiceSection copyWith({
    bool? visibility,
    String? title,
    String? description,
  }) {
    return ServiceSection(
      visibility: visibility ?? this.visibility,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'visibility': visibility,
      'title': title,
      'description': description,
    };
  }

  factory ServiceSection.fromMap(Map<String, dynamic> map) {
    return ServiceSection(
      visibility: map['visibility'] as bool,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceSection.fromJson(String source) =>
      ServiceSection.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [visibility, title, description];
}
