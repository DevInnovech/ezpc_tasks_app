import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';

class OrderDetailsDto {
  final String orderId;
  final String taskName;
  final String providerName;
  final String providerImageUrl;
  final String date;
  final String time;
  final double price;
  final double discount;
  final double tax;
  final double total;
  final String status;
  final String address;
  final String providerEmail;
  final String providerPhone;
  final double rating; // Nuevo campo para la calificación del proveedor
  final String paymentStatus;

  OrderDetailsDto({
    required this.orderId,
    required this.taskName,
    required this.providerName,
    required this.providerImageUrl,
    required this.date,
    required this.time,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    required this.address,
    required this.providerEmail,
    required this.providerPhone,
    required this.rating, // Inicialización del nuevo campo
    required this.paymentStatus,
  });

  // Método para convertir un Map a una instancia de OrderDetailsDto
  factory OrderDetailsDto.fromMap(Map<String, dynamic> map) {
    return OrderDetailsDto(
      orderId: map['id'] ?? '',
      taskName: map['taskName'] ?? '',
      providerName: map['providerName'] ?? '',
      providerImageUrl: map['providerImageUrl'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      total: map['totalPrice']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      address: map['address'] ?? '',
      providerEmail: map['providerEmail'] ?? '',
      providerPhone: map['providerPhone'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0, // Conversión del nuevo campo
      paymentStatus: map['paymentStatus'] ?? '',
    );
  }

  // Método para convertir una instancia a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': orderId,
      'taskName': taskName,
      'providerName': providerName,
      'providerImageUrl': providerImageUrl,
      'date': date,
      'time': time,
      'price': price,
      'discount': discount,
      'tax': tax,
      'total': total,
      'status': status,
      'address': address,
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'rating': rating, // Conversión del nuevo campo al mapa
      'paymentStatus': paymentStatus,
    };
  }
}
