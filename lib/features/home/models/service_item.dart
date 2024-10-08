import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../services/models/category_model.dart';
import 'provider_model.dart';

class ServiceItem extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String image;
  final double price;
  final Category categoryId; // Cambiado a tipo Category
  final int providerId;
  final int makeFeatured;
  final int isBanned;
  final String details;
  final int status;
  final String createdAt;
  final int approveByAdmin;
  final String averageRating;
  final int totalReview;
  final int totalOrder;
  final Category? category; // Opcional
  final ProviderModel provider; // Opcional

  const ServiceItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.price,
    required this.categoryId, // Ahora es de tipo Category
    required this.providerId,
    required this.makeFeatured,
    required this.isBanned,
    required this.status,
    required this.details,
    required this.createdAt,
    required this.approveByAdmin,
    required this.averageRating,
    required this.totalReview,
    required this.totalOrder,
    this.category, // Hacemos opcional category para evitar errores
    required this.provider, // Hacemos opcional provider para evitar errores
  });

  ServiceItem copyWith({
    int? id,
    String? name,
    String? slug,
    String? image,
    double? price,
    Category? categoryId, // Cambiado también a tipo Category
    int? providerId,
    int? makeFeatured,
    int? isBanned,
    String? details,
    String? createdAt,
    int? status,
    int? approveByAdmin,
    String? averageRating,
    int? totalReview,
    int? totalOrder,
    Category? category,
    ProviderModel? provider,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId, // Cambiado
      providerId: providerId ?? this.providerId,
      makeFeatured: makeFeatured ?? this.makeFeatured,
      isBanned: isBanned ?? this.isBanned,
      status: status ?? this.status,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      approveByAdmin: approveByAdmin ?? this.approveByAdmin,
      averageRating: averageRating ?? this.averageRating,
      totalReview: totalReview ?? this.totalReview,
      totalOrder: totalOrder ?? this.totalOrder,
      category: category ?? this.category,
      provider: provider ?? this.provider,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'price': price,
      'category_id': categoryId.toMap(), // Aquí cambiamos a categoryId
      'providerId': providerId,
      'make_featured': makeFeatured,
      'is_banned': isBanned,
      'status': status,
      'details': details,
      'createdAt': createdAt,
      'approve_by_admin': approveByAdmin,
      'averageRating': averageRating,
      'totalReview': totalReview,
      'totalOrder': totalOrder,
      'category': category?.toMap(), // Mapeamos category si existe
      'provider': provider.toMap(),
    };
  }

  factory ServiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceItem(
      id: map['id'] as int,
      name: map['name'] ?? "",
      slug: map['slug'] ?? "",
      image: map['image'] ?? "",
      price: map['price'] != null ? double.parse(map['price'].toString()) : 0,
      categoryId:
          Category.fromMap(map['category_id']), // Convertimos categoryId
      providerId: map['providerId'] != null
          ? int.parse(map['providerId'].toString())
          : 0,
      makeFeatured: map['make_featured'] != null
          ? int.parse(map['make_featured'].toString())
          : 0,
      details: map['details'] ?? "",
      createdAt: map['createdAt'] ?? "",
      isBanned:
          map['is_banned'] != null ? int.parse(map['is_banned'].toString()) : 0,
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
      approveByAdmin: map['approveByAdmin'] != null
          ? int.parse(map['approveByAdmin'].toString())
          : 0,
      averageRating: map['averageRating'] ?? '',
      totalReview: map['totalReview'] as int,
      totalOrder: map['totalOrder'] as int,
      category: map['category'] != null
          ? Category.fromMap(map['category'] as Map<String, dynamic>)
          : null,
      provider: ProviderModel.fromMap(map['provider'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceItem.fromJson(String source) =>
      ServiceItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      slug,
      image,
      price,
      categoryId, // Cambiado para reflejar el nuevo tipo
      providerId,
      makeFeatured,
      isBanned,
      status,
      createdAt,
      details,
      approveByAdmin,
      averageRating,
      totalReview,
      totalOrder,
      category!, // Debería ser opcional pero se fuerza para evitar errores
      provider,
    ];
  }
}
