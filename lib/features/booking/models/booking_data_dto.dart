import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/features/home/models/service_item.dart';
import 'client_info_dto.dart';

class BookingDataDto extends Equatable {
  final int id;
  final int orderId;
  final int clientId;
  final int providerId;
  final int serviceId;
  final double packageAmount;
  final double totalAmount;
  final String bookingDate;
  final String appointmentSchedule;
  final String scheduleTimeSlot;
  final double additionalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final int refundStatus;
  final String transectionId;
  final String orderStatus;
  final String orderApprovalDate;
  final String orderCompletedDate;
  final String orderDeclinedDate;
  final String packageFeatures;
  final String additionalServices;
  final String clientAddress;
  final String orderNote;
  final String completeByAdmin;
  final String createdAt;
  final String updatedAt;
  final ClientInfoDto client;
  final ServiceItem? service;

  const BookingDataDto({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.providerId,
    required this.serviceId,
    required this.packageAmount,
    required this.totalAmount,
    required this.bookingDate,
    required this.appointmentSchedule,
    required this.scheduleTimeSlot,
    required this.additionalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.refundStatus,
    required this.transectionId,
    required this.orderStatus,
    required this.orderApprovalDate,
    required this.orderCompletedDate,
    required this.orderDeclinedDate,
    required this.packageFeatures,
    required this.additionalServices,
    required this.clientAddress,
    required this.orderNote,
    required this.completeByAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.client,
    required this.service,
  });

  // Copy constructor for immutability
  BookingDataDto copyWith({
    int? id,
    int? orderId,
    int? clientId,
    int? providerId,
    int? serviceId,
    double? packageAmount,
    double? totalAmount,
    String? bookingDate,
    String? appointmentSchedule,
    String? scheduleTimeSlot,
    double? additionalAmount,
    String? paymentMethod,
    String? paymentStatus,
    int? refundStatus,
    String? transectionId,
    String? orderStatus,
    String? orderApprovalDate,
    String? orderCompletedDate,
    String? orderDeclinedDate,
    String? packageFeatures,
    String? additionalServices,
    String? clientAddress,
    String? orderNote,
    String? completeByAdmin,
    String? createdAt,
    String? updatedAt,
    ClientInfoDto? client,
    ServiceItem? service,
  }) {
    return BookingDataDto(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      packageAmount: packageAmount ?? this.packageAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingDate: bookingDate ?? this.bookingDate,
      appointmentSchedule: appointmentSchedule ?? this.appointmentSchedule,
      scheduleTimeSlot: scheduleTimeSlot ?? this.scheduleTimeSlot,
      additionalAmount: additionalAmount ?? this.additionalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      refundStatus: refundStatus ?? this.refundStatus,
      transectionId: transectionId ?? this.transectionId,
      orderStatus: orderStatus ?? this.orderStatus,
      orderApprovalDate: orderApprovalDate ?? this.orderApprovalDate,
      orderCompletedDate: orderCompletedDate ?? this.orderCompletedDate,
      orderDeclinedDate: orderDeclinedDate ?? this.orderDeclinedDate,
      packageFeatures: packageFeatures ?? this.packageFeatures,
      additionalServices: additionalServices ?? this.additionalServices,
      clientAddress: clientAddress ?? this.clientAddress,
      orderNote: orderNote ?? this.orderNote,
      completeByAdmin: completeByAdmin ?? this.completeByAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
      service: service ?? this.service,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'client_id': clientId,
      'provider_id': providerId,
      'service_id': serviceId,
      'package_amount': packageAmount,
      'total_amount': totalAmount,
      'booking_date': bookingDate,
      'appointment_schedule': appointmentSchedule,
      'schedule_time_slot': scheduleTimeSlot,
      'additional_amount': additionalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'refund_status': refundStatus,
      'transection_id': transectionId,
      'order_status': orderStatus,
      'order_approval_date': orderApprovalDate,
      'order_completed_date': orderCompletedDate,
      'order_declined_date': orderDeclinedDate,
      'package_features': packageFeatures,
      'additional_services': additionalServices,
      'client_address': clientAddress,
      'order_note': orderNote,
      'complete_by_admin': completeByAdmin,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'client': client.toMap(),
      'service': service?.toMap(),
    };
  }

  factory BookingDataDto.fromMap(Map<String, dynamic> map) {
    return BookingDataDto(
      id: map['id'] ?? 0,
      orderId:
          map['order_id'] != null ? int.parse(map['order_id'].toString()) : 0,
      clientId:
          map['client_id'] != null ? int.parse(map['client_id'].toString()) : 0,
      providerId: map['provider_id'] != null
          ? int.parse(map['provider_id'].toString())
          : 0,
      serviceId: map['service_id'] != null
          ? int.parse(map['service_id'].toString())
          : 0,
      packageAmount: map['package_amount'] != null
          ? double.parse(map['package_amount'].toString())
          : 0.0,
      totalAmount: map['total_amount'] != null
          ? double.parse(map['total_amount'].toString())
          : 0.0,
      bookingDate: map['booking_date'] ?? "",
      appointmentSchedule: map['appointment_schedule'] ?? "",
      scheduleTimeSlot: map['schedule_time_slot'] ?? "",
      additionalAmount: map['additional_amount'] != null
          ? double.parse(map['additional_amount'].toString())
          : 0.0,
      paymentMethod: map['payment_method'] ?? "",
      paymentStatus: map['payment_status'] ?? '',
      refundStatus: map['refund_status'] != null
          ? int.parse(map['refund_status'].toString())
          : 0,
      transectionId: map['transection_id'] ?? "",
      orderStatus: map['order_status'] ?? '',
      orderApprovalDate: map['order_approval_date'] ?? "",
      orderCompletedDate: map['order_completed_date'] ?? "",
      orderDeclinedDate: map['order_declined_date'] ?? "",
      packageFeatures: map['package_features'] ?? "",
      additionalServices: map['additional_services'] ?? "",
      clientAddress: map['client_address'] ?? "",
      orderNote: map['order_note'] ?? "",
      completeByAdmin: map['complete_by_admin'] ?? "",
      createdAt: map['created_at'] ?? "",
      updatedAt: map['updated_at'] ?? "",
      client: ClientInfoDto.fromMap(map['client'] as Map<String, dynamic>),
      service: map['service'] != null
          ? ServiceItem.fromMap(map['service'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingDataDto.fromJson(String source) =>
      BookingDataDto.fromMap(json.decode(source));

  @override
  List<Object> get props {
    return [
      id,
      orderId,
      clientId,
      providerId,
      serviceId,
      packageAmount,
      totalAmount,
      bookingDate,
      appointmentSchedule,
      scheduleTimeSlot,
      additionalAmount,
      paymentMethod,
      paymentStatus,
      refundStatus,
      transectionId,
      orderStatus,
      orderApprovalDate,
      orderCompletedDate,
      orderDeclinedDate,
      packageFeatures,
      additionalServices,
      clientAddress,
      orderNote,
      completeByAdmin,
      createdAt,
      updatedAt,
      client,
      service!,
    ];
  }
}
