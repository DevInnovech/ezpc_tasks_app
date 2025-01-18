import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo simplificado para un servicio
class SimpleService {
  final String name;
  final List<String> questions;
  final String serviceId;

  SimpleService({
    required this.name,
    required this.questions,
    required this.serviceId,
  });
}

// Estados del controlador
class ServicesControllerState {
  const ServicesControllerState();
}

class ServicesControllerLoading extends ServicesControllerState {}

class ServicesControllerLoaded extends ServicesControllerState {
  final List<SimpleService> services;

  ServicesControllerLoaded(this.services);
}

class ServicesControllerError extends ServicesControllerState {
  final String message;

  ServicesControllerError(this.message);
}

// Controlador modificado para cargar TODOS los servicios
class ServicesControllerNotifier
    extends StateNotifier<ServicesControllerState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ServicesControllerNotifier() : super(ServicesControllerLoading());

  Future<void> loadAllServices() async {
    try {
      // Consultar todas las categorías en Firestore
      final categoriesSnapshot =
          await _firestore.collection('categories').get();

      // Extraer y mapear los servicios de todas las categorías
      final allServices = categoriesSnapshot.docs.expand((doc) {
        final data = doc.data();
        final services = data['services'] as List<dynamic>? ?? [];
        return services.map((service) {
          return SimpleService(
            name: service['name'] ?? 'Unnamed Service', // Nombre del servicio
            questions: (service['questions'] as List<dynamic>? ?? [])
                .map((q) => q.toString())
                .toList(), // Lista de preguntas
            serviceId: service['serviceId'] ?? '', // ID del servicio
          );
        });
      }).toList();

      // Actualizar el estado con todos los servicios cargados
      state = ServicesControllerLoaded(allServices);
    } catch (e) {
      // Manejo de errores
      state = ServicesControllerError(e.toString());
    }
  }
}

// Proveedor de Riverpod para el controlador
final servicesControllerProvider = StateNotifierProvider.autoDispose<
    ServicesControllerNotifier,
    ServicesControllerState>((ref) => ServicesControllerNotifier());
