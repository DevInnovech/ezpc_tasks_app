import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo para un servicio popular
class PopularService {
  final String? image;
  final String serviceName;
  final int count;

  PopularService({
    required this.serviceName,
    required this.count,
    required this.image,
  });
}

// Estados del controlador
class PopularServicesState {
  const PopularServicesState();
}

class PopularServicesLoading extends PopularServicesState {}

class PopularServicesLoaded extends PopularServicesState {
  final List<PopularService> services;

  PopularServicesLoaded(this.services);
}

class PopularServicesError extends PopularServicesState {
  final String message;

  PopularServicesError(this.message);
}

// Controlador para cargar servicios populares
class PopularServicesController extends StateNotifier<PopularServicesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PopularServicesController() : super(PopularServicesLoading());

  Future<void> loadPopularServices() async {
    try {
      // Consulta para obtener los servicios populares ordenados por 'count'
      final snapshot = await _firestore
          .collection('servicesfiltered')
          .doc('servicespop')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();

        // Asegúrate de que 'services' es una lista válida
        final servicesList = (data?['services'] as List<dynamic>?) ?? [];

        // Mapear los datos a objetos de PopularService y ordenar por count
        final services = servicesList
            .map((serviceData) => PopularService(
                  serviceName: serviceData['service'] ?? 'Unnamed Service',
                  count: serviceData['count'] ?? 0,
                  image: serviceData['image'] ?? null,
                ))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count)); // Orden descendente

        // Tomar los 10 servicios más populares
        final topServices = services.take(10).toList();

        state = PopularServicesLoaded(topServices);
      } else {
        state = PopularServicesLoaded([]);
      }
    } catch (e) {
      state = PopularServicesError(e.toString());
    }
  }
}

// Proveedor de Riverpod para el controlador de Popular Services
final popularServicesProvider =
    StateNotifierProvider<PopularServicesController, PopularServicesState>(
  (ref) => PopularServicesController(),
);
