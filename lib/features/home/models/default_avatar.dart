// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class DefaultAvatar extends Equatable {
  final String image;
  const DefaultAvatar({
    required this.image,
  });

  DefaultAvatar copyWith({
    String? image,
  }) {
    return DefaultAvatar(
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
    };
  }

  factory DefaultAvatar.fromMap(Map<String, dynamic> map) {
    return DefaultAvatar(
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DefaultAvatar.fromJson(String source) =>
      DefaultAvatar.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [image];
}
