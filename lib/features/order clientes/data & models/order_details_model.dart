import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';

class OrderDetailsDto {
  final OrderItems order;
  final ProviderModel provider;
  final double packageAmount;
  final double additionalAmount;
  final double totalAmount;
  final double couponDiscount;
  final String paymentStatus;

  OrderDetailsDto({
    required this.order,
    required this.provider,
    required this.packageAmount,
    required this.additionalAmount,
    required this.totalAmount,
    required this.couponDiscount,
    required this.paymentStatus,
  });
}
