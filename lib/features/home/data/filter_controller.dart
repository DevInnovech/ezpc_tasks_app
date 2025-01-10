import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchController {
  final FirebaseFirestore _firestore;

  SearchController(this._firestore);

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.isEmpty) return [];

    final Set<Map<String, dynamic>> results = {};

    try {
      // Búsqueda en la colección de proveedores por nombre o apellido
      final providerQuery = await _firestore
          .collection('providers')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final lastNameQuery = await _firestore
          .collection('providers')
          .where('lastName', isGreaterThanOrEqualTo: query)
          .where('lastName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      results.addAll(providerQuery.docs.map((doc) {
        final data = {
          ...doc.data(),
          'id':
              doc.id, // Este es el ID del documento de la colección 'providers'
          'type': 'provider',
        };
        print(
            'Provider Found - Document ID: ${doc.id}'); // Mostrar el ID en consola
        return data;
      }));

      results.addAll(lastNameQuery.docs.map((doc) {
        final data = {
          ...doc.data(),
          'id':
              doc.id, // Este es el ID del documento de la colección 'providers'
          'type': 'provider',
        };
        print(
            'Provider Found - Document ID: ${doc.id}'); // Mostrar el ID en consola
        return data;
      }));

      Map<String, List<String>> resultservices =
          await searchServiceNames(query);

      results.addAll(resultservices.entries
          .expand((entry) => entry.value.map((service) => {
                'category': entry.key, // Nombre de la categoría
                'service': service, // Nombre del servicio individual
                'type': 'service', // Tipo adicional
              })));

      // Búsqueda en la colección de bookings por subcategorías (array y string)
    } catch (e) {
      print('Error al realizar la búsqueda: $e');
    }

    // Estructurar resultados para jerarquía
    final structuredResults = results
        .map((result) {
          if (result['type'] == 'service') {
            return {
              'category': result['category'], // Clave del mapa: categoría
              'services':
                  result['services'], // Valor del mapa: lista de servicios
              'type': 'service', // Tipo adicional
              'name': result['service'],
              'lastName': result['category'],
              'id': result['service'],
            };
          } else if (result['type'] == 'provider') {
            return {
              'name': result['name'] ?? 'No Name',
              'lastName': result['lastName'] ?? 'No Last Name',
              'email': result['email'] ?? 'No Email',
              'type': 'provider',
              'id': result[
                  'id'], // Este es el ID que usaremos para buscar las tasks
            };
          }
          return null;
        })
        .where((item) => item != null)
        .toList();

    // Eliminar duplicados basados en el ID
    final uniqueResults = structuredResults
        .toList()
        .fold<Map<String, Map<String, dynamic>>>(
          {},
          (map, item) {
            map[item!['id']] = item;
            return map;
          },
        )
        .values
        .toList();

    return uniqueResults;
  }
}

Future<Map<String, List<String>>> searchServiceNames(String query) async {
  final _firestore = FirebaseFirestore.instance;

  // Obtener todos los documentos de la colección "categories"
  final snapshot = await _firestore.collection('categories').get();

  Map<String, List<String>> matchingCategories = {};

  for (var doc in snapshot.docs) {
    final data = doc.data();

    // Verifica si hay servicios en el documento
    if (data.containsKey('services')) {
      List<dynamic> services = data['services'] as List<dynamic>;
      String categoryName = data['name'] ?? 'Unknown Category';

      // Busca en los nombres de los servicios
      List<String> matchingServices = [];
      for (var service in services) {
        if (service['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          matchingServices.add(service['name']);
        }
      }

      // Si hay servicios coincidentes, agrégalos bajo la categoría
      if (matchingServices.isNotEmpty) {
        matchingCategories[categoryName] = matchingServices;
      }
    }
  }
  print(matchingCategories);
  return matchingCategories;
}

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final searchControllerProvider = Provider<SearchController>((ref) {
  return SearchController(ref.watch(firestoreProvider));
});

final searchResultsProvider =
    StateNotifierProvider<SearchResultsNotifier, List<Map<String, dynamic>>>(
  (ref) => SearchResultsNotifier(ref.watch(searchControllerProvider)),
);

class SearchResultsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final SearchController _searchController;

  SearchResultsNotifier(this._searchController) : super([]);

  Future<void> performSearch(String query) async {
    final results = await _searchController.search(query);
    state = results;
  }

  // Método para limpiar resultados
  void clearResults() {
    state = [];
  }
}
