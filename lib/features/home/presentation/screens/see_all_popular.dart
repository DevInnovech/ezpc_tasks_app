import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/pop_services.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/popular_service_card.dart';

/// Modelo para representar un servicio popular
class PopularServiceModel {
  final String service;
  final int count;

  PopularServiceModel({
    required this.service, // Cambiado para que coincida con 'service' en Firestore
    required this.count,
  });

  // Método para convertir un Map en una instancia de PopularServiceModel
  factory PopularServiceModel.fromMap(Map<String, dynamic> map) {
    return PopularServiceModel(
      service:
          map['service'] as String? ?? 'Unknown Service', // Campo corregido
      count: map['count'] as int? ?? 0,
    );
  }
}

/// Pantalla para mostrar los servicios populares
class PopularServicesScreen extends StatefulWidget {
  const PopularServicesScreen({super.key});

  @override
  _PopularServicesScreenState createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  late Future<List<PopularServiceModel>> _popularServicesFuture;

  @override
  void initState() {
    super.initState();
    _popularServicesFuture = _getPopularServices();
  }

  /// Método para obtener servicios populares de Firestore
  Future<List<PopularServiceModel>> _getPopularServices() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('servicesfiltered')
          .doc('servicespop')
          .get();

      final servicesData = querySnapshot.data()?['services'] as List<dynamic>?;
      if (servicesData == null) {
        return [];
      }

      return servicesData.map((service) {
        return PopularServiceModel.fromMap(service as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error cargando servicios populares: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Servicios Populares'),
      ),
      body: FutureBuilder<List<PopularServiceModel>>(
        future: _popularServicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child:
                  Text('Error cargando servicios populares: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final services = snapshot.data!;
            if (services.isEmpty) {
              return const Center(
                child: Text('No hay servicios populares disponibles.'),
              );
            }

            // Mostrar la lista de servicios populares
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4, // Relación de aspecto de las tarjetas
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return PopularServiceCard(
                  serviceName: service.service,
                  count: service.count,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TasksByServiceScreen(
                          serviceName: service.service,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No se encontraron servicios.'));
          }
        },
      ),
      bottomNavigationBar: ClientBottomNavigationBar(scaffoldKey: scaffoldKey),
    );
  }
}
