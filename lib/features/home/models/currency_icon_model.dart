import 'dart:convert';

import 'package:equatable/equatable.dart';

class CurrencyIconModel extends Equatable {
  final String icon;

  const CurrencyIconModel({
    required this.icon,
  });

  CurrencyIconModel copyWith({
    String? icon,
  }) {
    return CurrencyIconModel(
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon,
    };
  }

  factory CurrencyIconModel.fromMap(Map<String, dynamic> map) {
    return CurrencyIconModel(
      icon: map['icon'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrencyIconModel.fromJson(String source) =>
      CurrencyIconModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [icon];
}
