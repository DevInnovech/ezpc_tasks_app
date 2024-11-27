import 'package:ezpc_tasks_app/features/order/models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fake provider for orders list
final orderProvider = Provider<List<OrderItems>>((ref) {
  // Fake data list
  return [
    const OrderItems(
      id: 1,
      orderId: '405406464040645',
      clientId: 123,
      bookingDate: '2024-11-02',
      totalAmount: 150.0,
      orderStatus: 'approved_by_provider',
      serviceName: 'Home Cleaning', // Example service name
    ),
    const OrderItems(
      id: 2,
      orderId: '102934857564928',
      clientId: 456,
      bookingDate: '2024-11-01',
      totalAmount: 200.0,
      orderStatus: 'Pending',
      serviceName: 'Lawn Mowing', // Example service name
    ),
    const OrderItems(
      id: 3,
      orderId: '293847564837563',
      clientId: 789,
      bookingDate: '2024-10-30',
      totalAmount: 250.0,
      orderStatus: 'complete',
      serviceName: 'Plumbing Repair', // Example service name
    ),
  ];
});
