// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class OrderDataModel extends Equatable {
  final List<OrderItems> data;

  const OrderDataModel({
    required this.data,
  });

  OrderDataModel copyWith({
    List<OrderItems>? data,
  }) {
    return OrderDataModel(
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  factory OrderDataModel.fromMap(Map<String, dynamic> map) {
    return OrderDataModel(
      data: List<OrderItems>.from(
        (map['data'] as List<dynamic>).map<OrderItems>(
          (x) => OrderItems.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderDataModel.fromJson(String source) =>
      OrderDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [data];
}

class OrderItems extends Equatable {
  final int id;
  final String orderId;
  final int clientId;
  final double totalAmount;
  final String bookingDate;
  final String orderStatus;
  final String serviceName; // Nuevo campo para el nombre del servicio

  const OrderItems({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.totalAmount,
    required this.bookingDate,
    required this.orderStatus,
    required this.serviceName,
  });

  OrderItems copyWith({
    int? id,
    String? orderId,
    int? clientId,
    double? totalAmount,
    String? bookingDate,
    String? orderStatus,
    String? serviceName,
  }) {
    return OrderItems(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      clientId: clientId ?? this.clientId,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingDate: bookingDate ?? this.bookingDate,
      orderStatus: orderStatus ?? this.orderStatus,
      serviceName: serviceName ?? this.serviceName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'order_id': orderId,
      'client_id': clientId,
      'total_amount': totalAmount,
      'booking_date': bookingDate,
      'order_status': orderStatus,
      'service_name': serviceName, // Agregar servicio al mapa
    };
  }

  factory OrderItems.fromMap(Map<String, dynamic> map) {
    return OrderItems(
      id: map['id'] ?? 0,
      orderId: map['order_id'] ?? "",
      clientId:
          map['client_id'] != null ? int.parse(map['client_id'].toString()) : 0,
      totalAmount: map['total_amount'] != null
          ? double.parse(map['total_amount'].toString())
          : 0,
      bookingDate: map['booking_date'] ?? "",
      orderStatus: map['order_status'] ?? "",
      serviceName: map['service_name'] ?? "", // Agregar servicio al constructor
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItems.fromJson(String source) =>
      OrderItems.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      orderId,
      clientId,
      totalAmount,
      bookingDate,
      orderStatus,
      serviceName,
    ];
  }
}
