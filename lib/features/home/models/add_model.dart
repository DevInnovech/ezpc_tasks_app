// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class AddBannerModel extends Equatable {
  final String banner;
  final String link;
  const AddBannerModel({
    required this.banner,
    required this.link,
  });

  AddBannerModel copyWith({
    String? banner,
    String? link,
  }) {
    return AddBannerModel(
      banner: banner ?? this.banner,
      link: link ?? this.link,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_banner': banner,
      'ad_link': link,
    };
  }

  factory AddBannerModel.fromMap(Map<String, dynamic> map) {
    return AddBannerModel(
      banner: map['ad_banner'] as String,
      link: map['ad_link'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddBannerModel.fromJson(String source) =>
      AddBannerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [banner, link];
}
