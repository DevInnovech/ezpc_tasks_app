import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo para un servicio popular
class PopularService {
  final String providerName;
  final String category;
  final String imageUrl;

  PopularService({
    required this.providerName,
    required this.category,
    required this.imageUrl,
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
      // Consulta para obtener las tareas
      final tasksSnapshot = await _firestore.collection('tasks').get();

      // Mapear las tareas a objetos de PopularService
      final services = tasksSnapshot.docs.map((doc) {
        final data = doc.data();

        return PopularService(
          providerName:
              data['firstName'] ?? 'Unnamed Provider', // Nombre del proveedor
          category: data['category'] ?? 'Uncategorized', // Categoría
          imageUrl: data['imageUrl'] ?? '', // URL de la imagen
        );
      }).toList();

      state = PopularServicesLoaded(services);
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
