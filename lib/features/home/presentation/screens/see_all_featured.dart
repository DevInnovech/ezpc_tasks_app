import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/home/data/services_controler.dart';

class FeaturedProvidersScreen extends StatefulWidget {
  const FeaturedProvidersScreen({super.key});

  @override
  _FeaturedProvidersScreenState createState() =>
      _FeaturedProvidersScreenState();
}

class _FeaturedProvidersScreenState extends State<FeaturedProvidersScreen> {
  late Future<List<ProviderData>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _providersFuture = _getFeaturedProviders();
  }

  /// Método para obtener proveedores destacados desde Firestore
  Future<List<ProviderData>> _getFeaturedProviders() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('servicesfiltered')
          .doc('providerpop')
          .get();

      final providersData =
          querySnapshot.data()?['providers'] as List<dynamic>?;
      if (providersData == null) {
        return [];
      }

      return providersData.map((provider) {
        return ProviderData.fromMap(provider as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error cargando proveedores destacados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Featured Providers'),
      ),
      body: FutureBuilder<List<ProviderData>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  'Error cargando proveedores destacados: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final providers = snapshot.data!;
            if (providers.isEmpty) {
              return const Center(
                child: Text('No hay proveedores destacados disponibles.'),
              );
            }

            // Mostrar la lista de proveedores como un GridView
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    3 / 4, // Relación de aspecto para las tarjetas
              ),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return ProviderCard(
                  provider: provider,
                );
              },
            );
          } else {
            return const Center(child: Text('No se encontraron proveedores.'));
          }
        },
      ),
      bottomNavigationBar: ClientBottomNavigationBar(scaffoldKey: scaffoldKey),
    );
  }
}
