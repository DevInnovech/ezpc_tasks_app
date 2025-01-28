import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/featured_services.dart';

// Modelo para un servicio (SimpleService)
class SimpleService {
  final String name;
  final String? image;
  final List<String> questions;
  final String serviceId;

  SimpleService({
    required this.image,
    required this.name,
    required this.questions,
    required this.serviceId,
  });
}

// Modelo para un proveedor (ProviderData)
class ProviderData {
  final String name;
  final String providerId;
  final int totalReviews;
  final double averageRating;
  final double weightedScore;

  ProviderData({
    required this.name,
    required this.providerId,
    required this.totalReviews,
    required this.averageRating,
    required this.weightedScore,
  });

  // Constructor para convertir datos Firestore a objeto ProviderData
  factory ProviderData.fromMap(Map<String, dynamic> data) {
    return ProviderData(
      name: data['name'] ?? 'Unnamed Provider',
      providerId: data['providerId'] ?? '',
      totalReviews: data['totalReviews'] ?? 0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      weightedScore: (data['weightedScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Estados del controlador para servicios
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

// Estados del controlador para proveedores
class ProviderControllerState {
  const ProviderControllerState();
}

class ProviderControllerLoading extends ProviderControllerState {}

class ProviderControllerLoaded extends ProviderControllerState {
  final List<ProviderData> providers;

  ProviderControllerLoaded(this.providers);
}

class ProviderControllerError extends ProviderControllerState {
  final String message;

  ProviderControllerError(this.message);
}

// Controlador para cargar servicios
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
            serviceId: service['serviceId'] ?? '',
            image: service['imageUrl'] ?? null, // ID del servicio
          );
        });
      }).toList();

      // Actualizar el estado con todos los servicios cargados
      state = ServicesControllerLoaded(allServices);
    } catch (e) {
      // Manejo de errores
      if (!mounted) return;
      state = ServicesControllerError(e.toString());
    }
  }
}

// Controlador para cargar proveedores
class ProviderControllerNotifier
    extends StateNotifier<ProviderControllerState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProviderControllerNotifier() : super(ProviderControllerLoading());

  Future<void> loadProviders() async {
    try {
      // Consultar el documento `providerpop`
      final snapshot = await _firestore
          .collection('servicesfiltered')
          .doc('providerpop')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final providersList = (data?['providers'] as List<dynamic>?) ?? [];

        // Mapear los datos a objetos ProviderData
        final providers = providersList
            .map((providerData) =>
                ProviderData.fromMap(providerData as Map<String, dynamic>))
            .toList();

        // Actualizar estado con los proveedores cargados
        state = ProviderControllerLoaded(providers);
      } else {
        // Si no hay datos, devolver una lista vacía
        state = ProviderControllerLoaded([]);
      }
    } catch (e) {
      // Manejo de errores
      state = ProviderControllerError(e.toString());
    }
  }
}

// Proveedores de Riverpod para los controladores
final servicesControllerProvider = StateNotifierProvider.autoDispose<
    ServicesControllerNotifier,
    ServicesControllerState>((ref) => ServicesControllerNotifier());

final providerControllerProvider =
    StateNotifierProvider<ProviderControllerNotifier, ProviderControllerState>(
        (ref) => ProviderControllerNotifier());

// Widget para mostrar una tarjeta de servicio
class ServiceCard extends StatelessWidget {
  final SimpleService service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar una tarjeta de proveedor
class ProviderCard extends StatelessWidget {
  final ProviderData provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.4;

    return InkWell(
      onTap: () {
        // Navegar a la pantalla de servicios por proveedor
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesByProviderScreen(
              providerId: provider.providerId, // Pasar el providerId
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth, // Ancho relativo a la pantalla
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen en la parte superior
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: cardWidth * 0.6, // Altura relativa al ancho
                width: double.infinity,
                color: Colors.grey[200],
                child: provider.providerId.isNotEmpty
                    ? Image.asset(
                        'assets/images/pp.jpg', // Imagen por defecto
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Nombre del proveedor
            Flexible(
              child: Text(
                provider.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),

            // Promedio de calificaciones y estrella
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  provider.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Total de reseñas
            Text(
              "${provider.totalReviews} reviews",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla principal que muestra los carruseles
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services and Providers')),
      body: Column(
        children: [
          // Carrusel de servicios
          Builder(
            builder: (context) {
              final servicesState = ref.watch(servicesControllerProvider);

              if (servicesState is ServicesControllerLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (servicesState is ServicesControllerError) {
                return Center(child: Text('Error: ${servicesState.message}'));
              } else if (servicesState is ServicesControllerLoaded) {
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: servicesState.services.length,
                    itemBuilder: (context, index) {
                      final service = servicesState.services[index];
                      return ServiceCard(service: service);
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          // Carrusel de proveedores
          Builder(
            builder: (context) {
              final providerState = ref.watch(providerControllerProvider);

              if (providerState is ProviderControllerLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (providerState is ProviderControllerError) {
                return Center(child: Text('Error: ${providerState.message}'));
              } else if (providerState is ProviderControllerLoaded) {
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: providerState.providers.length,
                    itemBuilder: (context, index) {
                      final provider = providerState.providers[index];
                      return ProviderCard(provider: provider);
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
