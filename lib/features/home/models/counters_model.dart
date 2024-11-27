// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class CounterModel extends Equatable {
  final int id;
  final String title;
  final String icon;
  final String number;
  final int status;
  const CounterModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.number,
    required this.status,
  });

  CounterModel copyWith({
    int? id,
    String? title,
    String? icon,
    String? number,
    int? status,
  }) {
    return CounterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      number: number ?? this.number,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'icon': icon,
      'number': number,
      'status': status,
    };
  }

  factory CounterModel.fromMap(Map<String, dynamic> map) {
    return CounterModel(
      id: map['id'] as int,
      title: map['title'] as String,
      icon: map['icon'] as String,
      number: map['number'] as String,
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CounterModel.fromJson(String source) =>
      CounterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      title,
      icon,
      number,
      status,
    ];
  }
}
