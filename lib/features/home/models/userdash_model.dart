// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/features/Review/review_data_model.dart';
import 'package:ezpc_tasks_app/features/Ticket/ticket_model.dart';
import 'package:ezpc_tasks_app/features/home/models/currency_icon_model.dart';
import 'package:ezpc_tasks_app/features/home/models/default_avatar.dart';
import 'package:ezpc_tasks_app/features/home/models/user_prfile_model.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';

class UserDashBoardModel extends Equatable {
  final UserProfileModel user;
  final DefaultAvatar defaultAvatar;
  final int? completeOrder;
  final int? activeOrder;
  final int? totalOrder;
  final OrderDataModel orders;
  final CurrencyIconModel icon;
  final ReviewDatModel reviews;
  final TicketDataModel tickets;
  const UserDashBoardModel({
    required this.user,
    required this.defaultAvatar,
    this.completeOrder,
    this.activeOrder,
    this.totalOrder,
    required this.orders,
    required this.icon,
    required this.reviews,
    required this.tickets,
  });

  UserDashBoardModel copyWith({
    UserProfileModel? user,
    DefaultAvatar? defaultAvatar,
    int? completeOrder,
    int? activeOrder,
    int? totalOrder,
    OrderDataModel? orders,
    CurrencyIconModel? icon,
    ReviewDatModel? reviews,
    TicketDataModel? tickets,
  }) {
    return UserDashBoardModel(
      user: user ?? this.user,
      defaultAvatar: defaultAvatar ?? this.defaultAvatar,
      completeOrder: completeOrder ?? this.completeOrder,
      activeOrder: activeOrder ?? this.activeOrder,
      totalOrder: totalOrder ?? this.totalOrder,
      orders: orders ?? this.orders,
      icon: icon ?? this.icon,
      reviews: reviews ?? this.reviews,
      tickets: tickets ?? this.tickets,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'default_avatar': defaultAvatar.toMap(),
      'complete_order': completeOrder,
      'active_order': activeOrder,
      'total_order': totalOrder,
      'orders': orders.toMap(),
      'currency_icon': icon.toMap(),
      'reviews': reviews.toMap(),
      'tickets': tickets.toMap(),
    };
  }

  factory UserDashBoardModel.fromMap(Map<String, dynamic> map) {
    return UserDashBoardModel(
      user: UserProfileModel.fromMap(map['user'] as Map<String, dynamic>),
      defaultAvatar:
          DefaultAvatar.fromMap(map['default_avatar'] as Map<String, dynamic>),
      completeOrder:
          map['complete_order'] != null ? map['complete_order'] as int : null,
      activeOrder:
          map['active_order'] != null ? map['active_order'] as int : null,
      totalOrder: map['total_order'] != null ? map['total_order'] as int : null,
      orders: OrderDataModel.fromMap(map['orders'] as Map<String, dynamic>),
      icon: CurrencyIconModel.fromMap(
          map['currency_icon'] as Map<String, dynamic>),
      reviews: ReviewDatModel.fromMap(map['reviews'] as Map<String, dynamic>),
      tickets: TicketDataModel.fromMap(map['tickets'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDashBoardModel.fromJson(String source) =>
      UserDashBoardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      user,
      defaultAvatar,
      completeOrder!,
      activeOrder!,
      totalOrder!,
      orders,
      icon,
      reviews,
      tickets,
    ];
  }
}
