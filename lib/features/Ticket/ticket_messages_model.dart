// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'ticket_model.dart';

class SingleTicketResponse extends Equatable {
  final TicketItems ticketItems;
  final List<TicketMessages> messages;
  const SingleTicketResponse({
    required this.ticketItems,
    required this.messages,
  });

  SingleTicketResponse copyWith({
    TicketItems? ticketItems,
    List<TicketMessages>? messages,
  }) {
    return SingleTicketResponse(
      ticketItems: ticketItems ?? this.ticketItems,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ticket': ticketItems.toMap(),
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory SingleTicketResponse.fromMap(Map<String, dynamic> map) {
    return SingleTicketResponse(
      ticketItems: TicketItems.fromMap(map['ticket'] as Map<String, dynamic>),
      messages: List<TicketMessages>.from(
        (map['messages'] as List<dynamic>).map<TicketMessages>(
          (x) => TicketMessages.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SingleTicketResponse.fromJson(String source) =>
      SingleTicketResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [ticketItems, messages];
}

class TicketMessages extends Equatable {
  final int id;
  final int ticketId;
  final int userId;
  final int adminId;
  final String message;
  final String messageFrom;
  final int unseenAdmin;
  final int unseenUser;
  final String createdAt;
  final String updatedAt;
  const TicketMessages({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.adminId,
    required this.message,
    required this.messageFrom,
    required this.unseenAdmin,
    required this.unseenUser,
    required this.createdAt,
    required this.updatedAt,
  });

  TicketMessages copyWith({
    int? id,
    int? ticketId,
    int? userId,
    int? adminId,
    String? message,
    String? messageFrom,
    int? unseenAdmin,
    int? unseenUser,
    String? createdAt,
    String? updatedAt,
  }) {
    return TicketMessages(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      message: message ?? this.message,
      messageFrom: messageFrom ?? this.messageFrom,
      unseenAdmin: unseenAdmin ?? this.unseenAdmin,
      unseenUser: unseenUser ?? this.unseenUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'admin_id': adminId,
      'message': message,
      'message_from': messageFrom,
      'unseen_admin': unseenAdmin,
      'unseen_user': unseenUser,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TicketMessages.fromMap(Map<String, dynamic> map) {
    return TicketMessages(
      id: map['id'] as int,
      ticketId:
          map['ticket_id'] != null ? int.parse(map['ticket_id'].toString()) : 0,
      userId: map['user_id'] != null ? int.parse(map['user_id'].toString()) : 0,
      adminId:
          map['admin_id'] != null ? int.parse(map['admin_id'].toString()) : 0,
      message: map['message'] as String,
      messageFrom: map['message_from'] as String,
      unseenAdmin: map['unseen_admin'] != null
          ? int.parse(map['unseen_admin'].toString())
          : 0,
      unseenUser: map['unseen_user'] != null
          ? int.parse(map['unseen_user'].toString())
          : 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TicketMessages.fromJson(String source) =>
      TicketMessages.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      ticketId,
      userId,
      adminId,
      message,
      messageFrom,
      unseenAdmin,
      unseenUser,
      createdAt,
      updatedAt,
    ];
  }
}
