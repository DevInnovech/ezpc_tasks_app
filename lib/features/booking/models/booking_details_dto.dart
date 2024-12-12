import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'booking_data_dto.dart';

class BookingDetailsDto extends Equatable {
  final BookingDataDto orders;
  final BookingAddress bookingAddress;
  final List<String> packageFeatures;
  final List<AdditionalServices> additionalServices;
  const BookingDetailsDto({
    required this.orders,
    required this.bookingAddress,
    required this.packageFeatures,
    required this.additionalServices,
  });

  BookingDetailsDto copyWith({
    BookingDataDto? orders,
    BookingAddress? bookingAddress,
    List<String>? packageFeatures,
    List<AdditionalServices>? additionalServices,
  }) {
    return BookingDetailsDto(
      orders: orders ?? this.orders,
      bookingAddress: bookingAddress ?? this.bookingAddress,
      packageFeatures: packageFeatures ?? this.packageFeatures,
      additionalServices: additionalServices ?? this.additionalServices,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orders': orders.toMap(),
      'booking_address': bookingAddress.toMap(),
      'package_features': packageFeatures,
      'additional_services': additionalServices.map((x) => x.toMap()).toList(),
    };
  }

  factory BookingDetailsDto.fromMap(Map<String, dynamic> map) {
    return BookingDetailsDto(
      orders: BookingDataDto.fromMap(map['order'] as Map<String, dynamic>),
      bookingAddress:
          BookingAddress.fromMap(map['clientAddress'] as Map<String, dynamic>),
      packageFeatures:
          List<String>.from(map['package_features'] as List<dynamic>),
      additionalServices: List<AdditionalServices>.from(
        (map['additional_services'] as List<dynamic>).map<AdditionalServices>(
          (x) => AdditionalServices.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingDetailsDto.fromJson(String source) =>
      BookingDetailsDto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props =>
      [orders, bookingAddress, packageFeatures, additionalServices];
}

class BookingAddress extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String postCode;
  final String orderNote;
  const BookingAddress({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.postCode,
    required this.orderNote,
  });

  BookingAddress copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? postCode,
    String? orderNote,
  }) {
    return BookingAddress(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      postCode: postCode ?? this.postCode,
      orderNote: orderNote ?? this.orderNote,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'post_code': postCode,
      'order_note': orderNote,
    };
  }

  factory BookingAddress.fromMap(Map<String, dynamic> map) {
    return BookingAddress(
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      phone: map['phone'] ?? "",
      address: map['address'] ?? "",
      postCode: map['post_code'] ?? "",
      orderNote: map['order_note'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingAddress.fromJson(String source) =>
      BookingAddress.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      name,
      email,
      phone,
      address,
      postCode,
      orderNote,
    ];
  }
}

class AdditionalServices extends Equatable {
  final int id;
  final int serviceId;
  final String serviceName;
  final String image;
  final int qty;
  final int price;
  final String createdAt;
  final String updatedAt;
  const AdditionalServices({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.image,
    required this.qty,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  AdditionalServices copyWith({
    int? id,
    int? serviceId,
    String? serviceName,
    String? image,
    int? qty,
    int? price,
    String? createdAt,
    String? updatedAt,
  }) {
    return AdditionalServices(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      image: image ?? this.image,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'service_id': serviceId,
      'service_name': serviceName,
      'image': image,
      'qty': qty,
      'price': price,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory AdditionalServices.fromMap(Map<String, dynamic> map) {
    return AdditionalServices(
      id: map['id'] ?? 0,
      serviceId: map['service_id'] != null
          ? int.parse(map['service_id'].toString())
          : 0,
      serviceName: map['service_name'] ?? "",
      image: map['image'] ?? "",
      qty: map['qty'] != null ? int.parse(map['qty'].toString()) : 0,
      price: map['price'] != null ? int.parse(map['price'].toString()) : 0,
      createdAt: map['created_at'] ?? "",
      updatedAt: map['updated_at'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory AdditionalServices.fromJson(String source) =>
      AdditionalServices.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      serviceId,
      serviceName,
      image,
      qty,
      price,
      createdAt,
      updatedAt,
    ];
  }
}
