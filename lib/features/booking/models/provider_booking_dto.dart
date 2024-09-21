import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/features/home/models/currency_icon_model.dart';

import 'booking_data_dto.dart';

class ProviderBookingDto extends Equatable {
  final String title;
  final List<BookingDataDto>? orders;
  final CurrencyIconModel currencyIconModel;
  final int declienedBooking;
  final int totalAwaiting;
  final int activeBooking;
  final int completeBooking;

  const ProviderBookingDto({
    required this.title,
    required this.orders,
    required this.currencyIconModel,
    required this.declienedBooking,
    required this.totalAwaiting,
    required this.activeBooking,
    required this.completeBooking,
  });

  ProviderBookingDto copyWith({
    String? title,
    List<BookingDataDto>? orders,
    CurrencyIconModel? currencyIconModel,
    int? declienedBooking,
    int? totalAwaiting,
    int? activeBooking,
    int? completeBooking,
  }) {
    return ProviderBookingDto(
      title: title ?? this.title,
      orders: orders ?? this.orders,
      currencyIconModel: currencyIconModel ?? this.currencyIconModel,
      declienedBooking: declienedBooking ?? this.declienedBooking,
      totalAwaiting: totalAwaiting ?? this.totalAwaiting,
      activeBooking: activeBooking ?? this.activeBooking,
      completeBooking: completeBooking ?? this.completeBooking,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'orders': orders!.map((x) => x.toMap()).toList(),
      'currency_icon': currencyIconModel.toMap(),
      'decliened_booking': declienedBooking,
      'total_awaiting': totalAwaiting,
      'active_booking': activeBooking,
      'complete_booking': completeBooking,
    };
  }

  factory ProviderBookingDto.fromMap(Map<String, dynamic> map) {
    return ProviderBookingDto(
      title: map['title'] ?? '',
      orders: map['orders']['data'] != null
          ? List<BookingDataDto>.from(
              (map['orders']['data'] as List<dynamic>).map<BookingDataDto>(
                (x) => BookingDataDto.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      currencyIconModel: CurrencyIconModel.fromMap(
          map['currency_icon'] as Map<String, dynamic>),
      declienedBooking: map['decliened_booking'] ?? 0,
      totalAwaiting: map['total_awaiting'] ?? 0,
      activeBooking: map['active_booking'] ?? 0,
      completeBooking: map['complete_booking'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProviderBookingDto.fromJson(String source) =>
      ProviderBookingDto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      title,
      orders!,
      currencyIconModel,
      declienedBooking,
      totalAwaiting,
      activeBooking,
      completeBooking,
    ];
  }
}
