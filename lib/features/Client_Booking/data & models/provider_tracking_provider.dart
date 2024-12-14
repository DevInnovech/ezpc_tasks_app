import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Enum para los estados de seguimiento
enum TrackingStatus { reserved, onTheWay, atLocation }

// Modelo para los datos de seguimiento
class TrackingData {
  final String orderId;
  final String providerName;
  final String providerImageUrl;
  final LatLng? providerLocation;
  final TrackingStatus status;

  TrackingData({
    required this.orderId,
    required this.providerName,
    required this.providerImageUrl,
    this.providerLocation,
    required this.status,
  });
}

// Ejemplo: Mapeo del estado de la reserva a nuestro TrackingStatus
TrackingStatus _mapBookingStatusToTrackingStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'accepted':
      return TrackingStatus.reserved;
    case 'started':
    case 'on the way':
      return TrackingStatus.onTheWay;
    case 'atlocation':
    case 'at location':
      return TrackingStatus.atLocation;
    default:
      return TrackingStatus.reserved;
  }
}

// Proveedor de tracking real a partir del orderId
final providerTrackingProvider =
    FutureProvider.family<TrackingData, String>((ref, orderId) async {
  // 1. Obtener datos de la reserva (booking)
  final bookingDoc = await FirebaseFirestore.instance
      .collection('bookings')
      .doc(orderId)
      .get();

  if (!bookingDoc.exists) {
    throw Exception("Booking not found for orderId: $orderId");
  }

  final bookingData = bookingDoc.data() as Map<String, dynamic>;

  // Asegúrate de que la reserva tenga el providerId
  final providerId = bookingData['providerId'] ?? '';
  if (providerId.isEmpty) {
    throw Exception("No providerId found in booking");
  }

  // 2. Obtener datos del proveedor
  final providerDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(providerId)
      .get();

  if (!providerDoc.exists) {
    throw Exception("Provider not found for providerId: $providerId");
  }

  final providerData = providerDoc.data() as Map<String, dynamic>;
  final providerName =
      "${providerData['name'] ?? ''} ${providerData['lastName'] ?? ''}".trim();
  final providerImageUrl = providerData['profileImageUrl'] ?? '';

  // 3. Obtener ubicación y estado del proveedor
  // Suponiendo que en la reserva tienes información de ubicación o lo obtienes desde otro campo.
  LatLng? providerLocation;
  if (bookingData.containsKey('providerLocation')) {
    final locData = bookingData['providerLocation'];
    if (locData is Map &&
        locData.containsKey('lat') &&
        locData.containsKey('lng')) {
      providerLocation = LatLng(
        (locData['lat'] as num).toDouble(),
        (locData['lng'] as num).toDouble(),
      );
    }
  }

  // Suponiendo que el estado de la reserva se almacena en 'status' del booking
  final bookingStatus = bookingData['status'] ?? 'pending';
  final trackingStatus = _mapBookingStatusToTrackingStatus(bookingStatus);

  // 4. Devolver TrackingData con los datos reales
  return TrackingData(
    orderId: orderId,
    providerName: providerName.isEmpty ? 'Unknown Provider' : providerName,
    providerImageUrl: providerImageUrl,
    providerLocation: providerLocation,
    status: trackingStatus,
  );
});
