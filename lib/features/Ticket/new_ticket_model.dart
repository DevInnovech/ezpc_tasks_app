// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class NewTicketModel extends Equatable {
  final String id;
  final String subject;
  final String message;
  const NewTicketModel({
    required this.id,
    required this.subject,
    required this.message,
  });

  NewTicketModel copyWith({
    String? id,
    String? subject,
    String? message,
  }) {
    return NewTicketModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'order_id': id,
      'subject': subject,
      'message': message,
    };
  }

  factory NewTicketModel.fromMap(Map<String, dynamic> map) {
    return NewTicketModel(
      id: map['order_id'] as String,
      subject: map['subject'] as String,
      message: map['message'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NewTicketModel.fromJson(String source) =>
      NewTicketModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, subject, message];
}


class SendingMessageModel extends Equatable {
  final String id;
  final String message;
  const SendingMessageModel({
    required this.id,
    required this.message,
  });

  SendingMessageModel copyWith({
    String? id,
    String? subject,
    String? message,
  }) {
    return SendingMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ticket_id': id,
      'message': message,
    };
  }

  factory SendingMessageModel.fromMap(Map<String, dynamic> map) {
    return SendingMessageModel(
      id: map['ticket_id'] as String,
      message: map['message'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SendingMessageModel.fromJson(String source) =>
      SendingMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, message];
}
