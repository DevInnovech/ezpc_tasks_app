import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/order%20clientes/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/*
// Proveedor falso para los detalles de la factura de una orden
final invoiceProvider =
    FutureProvider.family<OrderDetailsDto, String>((ref, orderId) async {
  // Simulación de carga de datos con retraso
  await Future.delayed(const Duration(seconds: 2));

  // Datos falsos para propósitos de demostración
  return OrderDetailsDto(
    order: OrderItems(
      orderId: orderId,
      bookingDate: '2024-11-02',
      totalAmount: 150.0,
      orderStatus: 'approved_by_provider',
      id: 0,
      clientId: 10,
      serviceName: 'services 1',
    ),
    provider: const ProviderModel(
      id: 1,
      name: 'Alam Cordero',
      email: 'alam@example.com',
      phone: '+123456789',
      image: KImages.pp,
      createdAt: '2024-01-01',
      userName: 'alamcordero',
      rating: 4.5,
      reviews: 120,
      profession: 'Carpintero',
      timeSlots: [
        TimeSlotModel(time: '08:00', isAvailable: true),
        TimeSlotModel(time: '10:00', isAvailable: false),
        TimeSlotModel(time: '12:00', isAvailable: true),
      ],
    ),
    packageAmount: 100.0,
    additionalAmount: 50.0,
    totalAmount: 150.0,
    couponDiscount: 0.0,
    paymentStatus: 'Paid',
  );
});
*/