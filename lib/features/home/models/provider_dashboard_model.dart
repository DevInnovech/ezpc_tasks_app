import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'currency_icon_model.dart';

class ProviderDashBoardModel extends Equatable {
  final CurrencyIconModel currencyIcon;
  final int todayTotalOrder;
  final int todayTotalAwatingOrder;
  final int todayApprovedOrder;
  final int todayCompleteOrder;
  final int todayDeclinedOrder;
  final double todayTotalEarning;
  final double todayWithdrawRequest;
  final int monthlyTotalOrder;
  final int monthlyTotalWwatingOrder;
  final int monthlyApprovedOrder;
  final int monthlyCompleteOrder;
  final int monthlyDeclinedOrder;
  final double monthlyTotalEarning;
  final double monthlyWithdrawRequest;
  final int yearlyTotalAwatingOrder;
  final int yearlyApprovedOrder;
  final int yearlyCompleteOrder;
  final int yearlyTotalOrder;
  final int yearlyDeclinedOrder;
  final double yearlyTotalEarning;
  final double yearlyWithdrawRequest;
  final int totalTotalOrder;
  final int totalTotalAwatingOrder;
  final int totalApprovedOrder;
  final int totalCompleteOrder;
  final int totalDeclinedOrder;
  final double totalTotalEarning;
  final double totalWithdrawRequest;
  final int totalService;

  const ProviderDashBoardModel({
    required this.currencyIcon,
    required this.todayTotalOrder,
    required this.todayTotalAwatingOrder,
    required this.todayApprovedOrder,
    required this.todayCompleteOrder,
    required this.todayDeclinedOrder,
    required this.todayTotalEarning,
    required this.todayWithdrawRequest,
    required this.monthlyTotalOrder,
    required this.monthlyTotalWwatingOrder,
    required this.monthlyApprovedOrder,
    required this.monthlyCompleteOrder,
    required this.monthlyDeclinedOrder,
    required this.monthlyTotalEarning,
    required this.monthlyWithdrawRequest,
    required this.yearlyTotalAwatingOrder,
    required this.yearlyApprovedOrder,
    required this.yearlyCompleteOrder,
    required this.yearlyTotalOrder,
    required this.yearlyDeclinedOrder,
    required this.yearlyTotalEarning,
    required this.yearlyWithdrawRequest,
    required this.totalTotalOrder,
    required this.totalTotalAwatingOrder,
    required this.totalApprovedOrder,
    required this.totalCompleteOrder,
    required this.totalDeclinedOrder,
    required this.totalTotalEarning,
    required this.totalWithdrawRequest,
    required this.totalService,
  });

  ProviderDashBoardModel copyWith({
    CurrencyIconModel? currencycon,
    int? todayTotalOrder,
    int? todayTotalAwatingOrder,
    int? todayApprovedOrder,
    int? todayCompleteOrder,
    int? todayDeclinedOrder,
    double? todayTotalEarning,
    double? todayWithdrawRequest,
    int? monthlyTotalOrder,
    int? monthlyTotalWwatingOrder,
    int? monthlyApprovedOrder,
    int? monthlyCompleteOrder,
    int? monthlyDeclinedOrder,
    double? monthlyTotalEarning,
    double? monthlyWithdrawRequest,
    int? yearlyTotalAwatingOrder,
    int? yearlyApprovedOrder,
    int? yearlyCompleteOrder,
    int? yearlyTotalOrder,
    int? yearlyDeclinedOrder,
    double? yearlyTotalEarning,
    double? yearlyWithdrawRequest,
    int? totalTotalOrder,
    int? totalTotalAwatingOrder,
    int? totalApprovedOrder,
    int? totalCompleteOrder,
    int? totalDeclinedOrder,
    double? totalTotalEarning,
    double? totalWithdrawRequest,
    int? totalService,
  }) {
    return ProviderDashBoardModel(
      currencyIcon: currencycon ?? currencyIcon,
      todayTotalOrder: todayTotalOrder ?? this.todayTotalOrder,
      todayTotalAwatingOrder:
          todayTotalAwatingOrder ?? this.todayTotalAwatingOrder,
      todayApprovedOrder: todayApprovedOrder ?? this.todayApprovedOrder,
      todayCompleteOrder: todayCompleteOrder ?? this.todayCompleteOrder,
      todayDeclinedOrder: todayDeclinedOrder ?? this.todayDeclinedOrder,
      todayTotalEarning: todayTotalEarning ?? this.todayTotalEarning,
      todayWithdrawRequest: todayWithdrawRequest ?? this.todayWithdrawRequest,
      monthlyTotalOrder: monthlyTotalOrder ?? this.monthlyTotalOrder,
      monthlyTotalWwatingOrder:
          monthlyTotalWwatingOrder ?? this.monthlyTotalWwatingOrder,
      monthlyApprovedOrder: monthlyApprovedOrder ?? this.monthlyApprovedOrder,
      monthlyCompleteOrder: monthlyCompleteOrder ?? this.monthlyCompleteOrder,
      monthlyDeclinedOrder: monthlyDeclinedOrder ?? this.monthlyDeclinedOrder,
      monthlyTotalEarning: monthlyTotalEarning ?? this.monthlyTotalEarning,
      monthlyWithdrawRequest:
          monthlyWithdrawRequest ?? this.monthlyWithdrawRequest,
      yearlyTotalAwatingOrder:
          yearlyTotalAwatingOrder ?? this.yearlyTotalAwatingOrder,
      yearlyApprovedOrder: yearlyApprovedOrder ?? this.yearlyApprovedOrder,
      yearlyCompleteOrder: yearlyCompleteOrder ?? this.yearlyCompleteOrder,
      yearlyTotalOrder: yearlyTotalOrder ?? this.yearlyTotalOrder,
      yearlyDeclinedOrder: yearlyDeclinedOrder ?? this.yearlyDeclinedOrder,
      yearlyTotalEarning: yearlyTotalEarning ?? this.yearlyTotalEarning,
      yearlyWithdrawRequest:
          yearlyWithdrawRequest ?? this.yearlyWithdrawRequest,
      totalTotalOrder: totalTotalOrder ?? this.totalTotalOrder,
      totalTotalAwatingOrder:
          totalTotalAwatingOrder ?? this.totalTotalAwatingOrder,
      totalApprovedOrder: totalApprovedOrder ?? this.totalApprovedOrder,
      totalCompleteOrder: totalCompleteOrder ?? this.totalCompleteOrder,
      totalDeclinedOrder: totalDeclinedOrder ?? this.totalDeclinedOrder,
      totalTotalEarning: totalTotalEarning ?? this.totalTotalEarning,
      totalWithdrawRequest: totalWithdrawRequest ?? this.totalWithdrawRequest,
      totalService: totalService ?? this.totalService,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currencycon': currencyIcon.toMap(),
      'today_total_order': todayTotalOrder,
      'today_total_awating_order': todayTotalAwatingOrder,
      'today_approved_order': todayApprovedOrder,
      'today_complete_order': todayCompleteOrder,
      'today_declined_order': todayDeclinedOrder,
      'today_total_earning': todayTotalEarning,
      'today_withdraw_request': todayWithdrawRequest,
      'monthly_total_order': monthlyTotalOrder,
      'monthly_total_awating_order': monthlyTotalWwatingOrder,
      'monthly_approved_order': monthlyApprovedOrder,
      'monthly_complete_order': monthlyCompleteOrder,
      'monthly_declined_order': monthlyDeclinedOrder,
      'monthly_total_earning': monthlyTotalEarning,
      'monthly_withdraw_request': monthlyWithdrawRequest,
      'yearly_total_awating_order': yearlyTotalAwatingOrder,
      'yearly_approved_order': yearlyApprovedOrder,
      'yearly_complete_order': yearlyCompleteOrder,
      'yearly_total_order': yearlyTotalOrder,
      'yearly_declined_order': yearlyDeclinedOrder,
      'yearly_total_earning': yearlyTotalEarning,
      'yearly_withdraw_request': yearlyWithdrawRequest,
      'total_total_order': totalTotalOrder,
      'total_total_awating_order': totalTotalAwatingOrder,
      'total_approved_order': totalApprovedOrder,
      'total_complete_order': totalCompleteOrder,
      'total_declined_order': totalDeclinedOrder,
      'total_total_earning': totalTotalEarning,
      'total_withdraw_request': totalWithdrawRequest,
      'total_service': totalService,
    };
  }

  factory ProviderDashBoardModel.fromMap(Map<String, dynamic> map) {
    return ProviderDashBoardModel(
      currencyIcon: CurrencyIconModel.fromMap(
          map['currency_icon'] as Map<String, dynamic>),
      todayTotalOrder: map['today_total_order'] ?? 0,
      todayTotalAwatingOrder: map['today_total_awating_order'] ?? 0,
      todayApprovedOrder: map['today_approved_order'] ?? 0,
      todayCompleteOrder: map['today_complete_order'] ?? 0,
      todayDeclinedOrder: map['today_declined_order'] ?? 0,
      todayTotalEarning: map['today_total_earning'] != null
          ? double.parse(map['today_total_earning'].toString())
          : 0.0,
      todayWithdrawRequest: map['today_withdraw_request'] != null
          ? double.parse(map['today_withdraw_request'].toString())
          : 0.0,
      monthlyTotalOrder: map['monthly_total_order'] ?? 0,
      monthlyTotalWwatingOrder: map['monthly_total_awating_order'] ?? 0,
      monthlyApprovedOrder: map['monthly_approved_order'] ?? 0,
      monthlyCompleteOrder: map['monthly_complete_order'] ?? 0,
      monthlyDeclinedOrder: map['monthly_declined_order'] ?? 0,
      monthlyTotalEarning: map['monthly_total_earning'] != null
          ? double.parse(map['monthly_total_earning'].toString())
          : 0.0,
      monthlyWithdrawRequest: map['monthly_withdraw_request'] != null
          ? double.parse(map['monthly_withdraw_request'].toString())
          : 0.0,
      yearlyTotalAwatingOrder: map['yearly_total_awating_order'] ?? 0,
      yearlyApprovedOrder: map['yearly_approved_order'] ?? 0,
      yearlyCompleteOrder: map['yearly_complete_order'] ?? 0,
      yearlyTotalOrder: map['yearly_total_order'] ?? 0,
      yearlyDeclinedOrder: map['yearly_declined_order'] ?? 0,
      yearlyTotalEarning: map['yearly_total_earning'] != null
          ? double.parse(map['yearly_total_earning'].toString())
          : 0.0,
      yearlyWithdrawRequest: map['yearly_withdraw_request'] != null
          ? double.parse(map['yearly_withdraw_request'].toString())
          : 0.0,
      totalTotalOrder: map['total_total_order'] ?? 0,
      totalTotalAwatingOrder: map['total_total_awating_order'] ?? 0,
      totalApprovedOrder: map['total_approved_order'] ?? 0,
      totalCompleteOrder: map['total_complete_order'] ?? 0,
      totalDeclinedOrder: map['total_declined_order'] ?? 0,
      totalTotalEarning: map['total_total_earning'] != null
          ? double.parse(map['total_total_earning'].toString())
          : 0.0,
      totalWithdrawRequest: map['total_withdraw_request'] != null
          ? double.parse(map['total_withdraw_request'].toString())
          : 0.0,
      totalService: map['total_service'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProviderDashBoardModel.fromJson(String source) =>
      ProviderDashBoardModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      currencyIcon,
      todayTotalOrder,
      todayTotalAwatingOrder,
      todayApprovedOrder,
      todayCompleteOrder,
      todayDeclinedOrder,
      todayTotalEarning,
      todayWithdrawRequest,
      monthlyTotalOrder,
      monthlyTotalWwatingOrder,
      monthlyApprovedOrder,
      monthlyCompleteOrder,
      monthlyDeclinedOrder,
      monthlyTotalEarning,
      monthlyWithdrawRequest,
      yearlyTotalAwatingOrder,
      yearlyApprovedOrder,
      yearlyCompleteOrder,
      yearlyTotalOrder,
      yearlyDeclinedOrder,
      yearlyTotalEarning,
      yearlyWithdrawRequest,
      totalTotalOrder,
      totalTotalAwatingOrder,
      totalApprovedOrder,
      totalCompleteOrder,
      totalDeclinedOrder,
      totalTotalEarning,
      totalWithdrawRequest,
      totalService,
    ];
  }
}
