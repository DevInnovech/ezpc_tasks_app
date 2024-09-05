// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/features/Review/review_user.dart';

class ReviewDatModel extends Equatable {
  final List<ReviewItems> data;

  const ReviewDatModel({
    required this.data,
  });

  ReviewDatModel copyWith({
    List<ReviewItems>? data,
  }) {
    return ReviewDatModel(
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  factory ReviewDatModel.fromMap(Map<String, dynamic> map) {
    return ReviewDatModel(
      data: List<ReviewItems>.from(
        (map['data'] as List<dynamic>).map<ReviewItems>(
          (x) => ReviewItems.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewDatModel.fromJson(String source) =>
      ReviewDatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [data];
}

class ReviewItems extends Equatable {
  final int id;
  final int serviceId;
  final int userId;
  final int providerId;
  final String review;
  final double rating;
  final int status;
  final String createdAt;
  final String updatedAt;
  final ReviewService? reviewService;
  final ReviewUser? user;

  const ReviewItems({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.providerId,
    required this.review,
    required this.rating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewService,
    required this.user,
  });

  ReviewItems copyWith({
    int? id,
    int? serviceId,
    int? userId,
    int? providerId,
    String? review,
    double? rating,
    int? status,
    String? createdAt,
    String? updatedAt,
    ReviewService? reviewService,
    ReviewUser? user,
  }) {
    return ReviewItems(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      review: review ?? this.review,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewService: reviewService ?? this.reviewService,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'providerId': providerId,
      'review': review,
      'rating': rating,
      'status': status,
      'createdAt': createdAt,
      'updated_at': updatedAt,
      'service': reviewService?.toMap(),
      'user': user?.toMap(),
    };
  }

  factory ReviewItems.fromMap(Map<String, dynamic> map) {
    return ReviewItems(
      id: map['id'] as int,
      serviceId:
          map['serviceId'] != null ? int.parse(map['serviceId'].toString()) : 0,
      userId: map['userId'] != null ? int.parse(map['userId'].toString()) : 0,
      providerId: map['providerId'] != null
          ? int.parse(map['providerId'].toString())
          : 0,
      review: map['review'] ?? '',
      rating:
          map['rating'] != null ? double.parse(map['rating'].toString()) : 0,
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      reviewService:
          map['service'] != null ? ReviewService.fromMap(map['service']) : null,
      user: map['user'] != null ? ReviewUser.fromMap(map['user']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewItems.fromJson(String source) =>
      ReviewItems.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      serviceId,
      userId,
      providerId,
      review,
      rating,
      status,
      createdAt,
      updatedAt,
      reviewService!,
    ];
  }
}

class ReviewService extends Equatable {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final String? averageRating;
  final int? totalReview;
  final int? totalOrder;

  const ReviewService({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.averageRating,
    this.totalReview,
    this.totalOrder,
  });

  ReviewService copyWith({
    int? id,
    String? name,
    String? slug,
    String? image,
    String? averageRating,
    int? totalReview,
    int? totalOrder,
  }) {
    return ReviewService(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      averageRating: averageRating ?? this.averageRating,
      totalReview: totalReview ?? this.totalReview,
      totalOrder: totalOrder ?? this.totalOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'averageRating': averageRating,
      'totalReview': totalReview,
      'totalOrder': totalOrder,
    };
  }

  factory ReviewService.fromMap(Map<String, dynamic> map) {
    return ReviewService(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      slug: map['slug'] != null ? map['slug'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      averageRating:
          map['averageRating'] != null ? map['averageRating'] as String : null,
      totalReview:
          map['totalReview'] != null ? map['totalReview'] as int : null,
      totalOrder: map['totalOrder'] != null ? map['totalOrder'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewService.fromJson(String source) =>
      ReviewService.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id!,
      name!,
      slug!,
      image!,
      averageRating!,
      totalReview!,
      totalOrder!,
    ];
  }
}
