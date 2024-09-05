// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/features/home/models/add_model.dart';
import 'package:ezpc_tasks_app/features/home/models/counters_model.dart';
import 'package:ezpc_tasks_app/features/home/models/partners.dart';
import 'package:ezpc_tasks_app/features/home/models/service_area.dart';
import 'package:ezpc_tasks_app/features/home/models/service_item.dart';
import 'package:ezpc_tasks_app/features/home/models/service_section.dart';
import 'package:ezpc_tasks_app/features/home/models/slider_model.dart';
import 'package:ezpc_tasks_app/features/home/models/testomonial_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';

class HomeModel extends Equatable {
  // final List<PopularTag> popularTag;
  final List<Category> searchCategories;
  final List<SliderModel> sliders;
  final List<ServiceArea> serviceAreas;
  final ServiceSection categorySection;
  final List<Category> categories;
  final String counterBgImage;
  final List<ServiceItem> featuredServices;
  // final CurrencyIconModel currencyIcon;
  final bool coundownVisibility;
  final AddBannerModel adBanner;
  final List<CounterModel> counters;
  final ServiceSection popularServiceSection;
  final ServiceSection featureServiceSection;
  final List<ServiceItem> popularServices;

  const HomeModel({
    // required this.popularTag,
    required this.searchCategories,
    required this.sliders,
    required this.serviceAreas,
    required this.categorySection,
    required this.counterBgImage,
    required this.categories,
    required this.featuredServices,
    required this.adBanner,
    // required this.currencyIcon,
    required this.coundownVisibility,
    required this.counters,
    required this.popularServiceSection,
    required this.featureServiceSection,
    required this.popularServices,
  });

  HomeModel copyWith({
    // List<PopularTag>? popularTag,
    List<Category>? searchCategories,
    List<SliderModel>? sliders,
    List<ServiceArea>? serviceAreas,
    ServiceSection? categorySection,
    List<Category>? categories,
    List<ServiceItem>? featuredServices,
    // CurrencyIconModel? currencyIcon,
    bool? coundownVisibility,
    String? counterBgImage,
    List<CounterModel>? counters,
    ServiceSection? popularServiceSection,
    AddBannerModel? adBanner,
    ServiceSection? featureServiceSection,
    List<ServiceItem>? popularServices,
    ServiceSection? testimonialSection,
    List<Testomonial>? testimonials,
    List<PartnerModel>? partners,
  }) {
    return HomeModel(
      // popularTag: popularTag ?? this.popularTag,
      searchCategories: searchCategories ?? this.searchCategories,
      sliders: sliders ?? this.sliders,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      categorySection: categorySection ?? this.categorySection,
      adBanner: adBanner ?? this.adBanner,
      categories: categories ?? this.categories,
      counterBgImage: counterBgImage ?? this.counterBgImage,
      featuredServices: featuredServices ?? this.featuredServices,
      // currencyIcon: currencyIcon ?? this.currencyIcon,
      coundownVisibility: coundownVisibility ?? this.coundownVisibility,
      counters: counters ?? this.counters,
      popularServiceSection:
          popularServiceSection ?? this.popularServiceSection,
      featureServiceSection:
          featureServiceSection ?? this.featureServiceSection,
      popularServices: popularServices ?? this.popularServices,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'popular_tag': popularTag.map((x) => x.toMap()).toList(),
      'search_categories': searchCategories.map((x) => x.toMap()).toList(),
      'mobile_sliders': sliders.map((x) => x.toMap()).toList(),
      'service_areas': serviceAreas.map((x) => x.toMap()).toList(),
      'category_section': categorySection.toMap(),
      'ad_banner': adBanner.toMap(),
      'categories': categories.map((x) => x.toMap()).toList(),
      'counter_bg_image': counterBgImage,
      'featured_services': featuredServices.map((x) => x.toMap()).toList(),
      // 'currency_icon': currencyIcon.toMap(),
      'coundown_visibility': coundownVisibility,
      'counters': counters.map((x) => x.toMap()).toList(),
      'popular_service_section': popularServiceSection.toMap(),
      'featured_service_section': featureServiceSection.toMap(),
      'popular_services': popularServices.map((x) => x.toMap()).toList(),
    };
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      // popularTag: List<PopularTag>.from(
      //     map['popular_tag'].map<PopularTag>((x) => PopularTag.fromMap(x))),
      searchCategories: map['search_categories'] != null
          ? List<Category>.from(map['search_categories']
              .map<Category>((x) => Category.fromMap(x)))
          : [],
      sliders: map['mobile_sliders'] != null
          ? List<SliderModel>.from(map['mobile_sliders']
              .map<SliderModel>((x) => SliderModel.fromMap(x)))
          : [],

      counterBgImage: map['counter_bg_image']['image'] as String,
      serviceAreas: map['service_areas'] != null
          ? List<ServiceArea>.from(map['service_areas']
              .map<ServiceArea>((x) => ServiceArea.fromMap(x)))
          : [],
      categorySection: ServiceSection.fromMap(
          map['category_section'] as Map<String, dynamic>),
      adBanner:
          AddBannerModel.fromMap(map['ad_banner'] as Map<String, dynamic>),
      categories: map['categories'] != null
          ? List<Category>.from(
              map['categories'].map<Category>((x) => Category.fromMap(x)))
          : [],
      featuredServices: map['featured_services'] != null
          ? List<ServiceItem>.from(
              map['featured_services'].map((x) => ServiceItem.fromMap(x)))
          : [],
      // currencyIcon: CurrencyIconModel.fromMap(
      //     map['currency_icon'] as Map<String, dynamic>),
      coundownVisibility: map['coundown_visibility'] as bool,
      counters: List<CounterModel>.from(
          map['counters'].map<CounterModel>((x) => CounterModel.fromMap(x))),
      popularServiceSection: ServiceSection.fromMap(
          map['popular_service_section'] as Map<String, dynamic>),
      featureServiceSection: ServiceSection.fromMap(
          map['featured_service_section'] as Map<String, dynamic>),
      popularServices: List<ServiceItem>.from(map['popular_services']
          .map<ServiceItem>((x) => ServiceItem.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeModel.fromJson(String source) =>
      HomeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      // popularTag,
      searchCategories,
      sliders,
      serviceAreas,
      counterBgImage,
      categorySection,
      categories,
      featuredServices,
      adBanner,
      // currencyIcon,
      coundownVisibility,
      counters,
      popularServiceSection,
      popularServices,
      featureServiceSection,
    ];
  }
}
