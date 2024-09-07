// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';
import 'package:ezpc_tasks_app/features/services/data/dashboard_user_profile.dart';

class TicketDataModel extends Equatable {
  final List<TicketItems> data;
  const TicketDataModel({
    required this.data,
  });

  TicketDataModel copyWith({
    List<TicketItems>? data,
  }) {
    return TicketDataModel(
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  factory TicketDataModel.fromMap(Map<String, dynamic> map) {
    return TicketDataModel(
      data: List<TicketItems>.from(
        (map['data'] as List<dynamic>).map<TicketItems>(
          (x) => TicketItems.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TicketDataModel.fromJson(String source) =>
      TicketDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [data];
}

class TicketItems extends Equatable {
  final int? id;
  final int? userId;
  final int? orderId;
  final String? subject;
  final int? ticketId;
  final String? ticketFrom;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final int? unSeenUserMessage;
  final DashbaordUserProfile user;
  final OrderItems order;
  const TicketItems({
    this.id,
    this.userId,
    this.orderId,
    this.subject,
    this.ticketId,
    this.ticketFrom,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.unSeenUserMessage,
    required this.user,
    required this.order,
  });

  TicketItems copyWith({
    int? id,
    int? userId,
    int? orderId,
    String? subject,
    int? ticketId,
    String? ticketFrom,
    String? status,
    String? createdAt,
    String? updatedAt,
    int? unSeenUserMessage,
    DashbaordUserProfile? user,
    OrderItems? order,
  }) {
    return TicketItems(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      subject: subject ?? this.subject,
      ticketId: ticketId ?? this.ticketId,
      ticketFrom: ticketFrom ?? this.ticketFrom,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unSeenUserMessage: unSeenUserMessage ?? this.unSeenUserMessage,
      user: user ?? this.user,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'subject': subject,
      'ticket_id': ticketId,
      'ticket_from': ticketFrom,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'unSeenUserMessage': unSeenUserMessage,
      'user': user.toMap(),
      'order': order.toMap(),
    };
  }

  factory TicketItems.fromMap(Map<String, dynamic> map) {
    return TicketItems(
      // id: map['id'] != null ? map['id'] as int : null,
      // userId: map['user_id'] != null ? map['user_id'] as String : null,
      // orderId: map['order_id'] != null ? map['order_id'] as String : null,
      // subject: map['subject'] != null ? map['subject'] as String : null,
      // ticketId: map['ticket_id'] != null ? map['ticket_id'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      userId: map['user_id'] != null ? int.parse(map['user_id'].toString()) : 0,
      orderId:
          map['order_id'] != null ? int.parse(map['order_id'].toString()) : 0,
      subject: map['subject'] != null ? map['subject'] as String : null,
      ticketId:
          map['ticket_id'] != null ? int.parse(map['ticket_id'].toString()) : 0,
      ticketFrom:
          map['ticket_from'] != null ? map['ticket_from'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      createdAt: map['created_at'] != null ? map['created_at'] as String : null,
      updatedAt: map['updated_at'] != null ? map['updated_at'] as String : null,
      unSeenUserMessage: map['unSeenUserMessage'] != null
          ? map['unSeenUserMessage'] as int
          : null,
      user: DashbaordUserProfile.fromMap(map['user'] as Map<String, dynamic>),
      order: OrderItems.fromMap(map['order'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory TicketItems.fromJson(String source) =>
      TicketItems.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id!,
      userId!,
      orderId!,
      subject!,
      ticketId!,
      ticketFrom!,
      status!,
      createdAt!,
      updatedAt!,
      unSeenUserMessage!,
      user,
      order,
    ];
  }
}
