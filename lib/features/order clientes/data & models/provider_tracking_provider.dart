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

// Proveedor de seguimiento simulado para propósitos de demostración
final providerTrackingProvider =
    FutureProvider.family<TrackingData, String>((ref, orderId) async {
  // Simulación de la obtención de datos con retraso
  await Future.delayed(const Duration(seconds: 2));

  // Datos simulados para demostración
  return TrackingData(
    orderId: orderId,
    providerName: "Alam Cordero",
    providerImageUrl: "https://example.com/provider_image.jpg",
    providerLocation: const LatLng(37.7749, -122.4194), // Ubicación de ejemplo
    status: TrackingStatus.onTheWay, // Estado de ejemplo
  );
});
