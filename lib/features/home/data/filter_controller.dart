import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchController {
  final FirebaseFirestore _firestore;

  SearchController(this._firestore);

  Future<List<Map<String, dynamic>>> searchWithFilters(
      String query, Map<String, dynamic>? filters) async {
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

      results.addAll(providerQuery.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
            'type': 'provider',
          }));

      results.addAll(lastNameQuery.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
            'type': 'provider',
          }));

      // Búsqueda de servicios
      Map<String, List<String>> resultservices =
          await searchServiceNames(query);

      results.addAll(resultservices.entries
          .expand((entry) => entry.value.map((service) => {
                'category': entry.key,
                'service': service,
                'type': 'service',
              })));

      // Aplicar filtros a los resultados
      final filteredResults = _applyFilters(results, filters);
      final structuredResults = filteredResults
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
    } catch (e) {
      print('Error al realizar la búsqueda: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _applyFilters(
      Set<Map<String, dynamic>> results, Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) return results.toList();

    // Filtrar por fecha
    if (filters.containsKey('onDemand') && filters['onDemand'] == true) {
      results = results.where((result) {
        final same = result['onDemand'];
        if (result['type'] != 'provider') {
          return true;
        }
        if (same == null) return false;
        return same == true ? true : false;
      }).toSet();
    }
/*
    // Filtrar por precio
    if (filters.containsKey('Price')) {
      String priceFilter = filters['Price'];
      results = results.where((result) {
        final price = result['price'] as double?;
        if (price == null) return false;

        if (priceFilter == 'Lowest') {
          return price <= 100; // Ajustar el rango según los datos
        } else if (priceFilter == 'Highest') {
          return price >= 100; // Ajustar el rango según los datos
        }
        return true;
      }).toSet();
    }*/

    // Filtrar por calificación (Rating)
    if (filters.containsKey('averageRating') &&
        filters['averageRating'][0] == true) {
      final ratingFilter = filters['averageRating'][1];
      final minRating = double.tryParse(ratingFilter.toString()) ?? 4;
      print('aqui ${filters['averageRating'][0]}');
      results = results.where((result) {
        if (result['type'] != 'provider') {
          return true;
        }
        // Asegúrate de que el tipo sea 'service' para aplicar este filtro
        final rating = result['averageRating'] as double?;
        return (rating != null && rating >= minRating) ? true : false;
      }).toSet();
    }

    // Filtrar por opciones extendidas
    if (filters.containsKey('extendedFilters')) {
      final extendedFilters = filters['extendedFilters'] as Map<String, bool>;
      results = results.where((result) {
        final category = result['category'] as String?;
        return category != null && extendedFilters[category] == true;
      }).toSet();
    }

    return results.toList();
  }
}

Future<Map<String, List<String>>> searchServiceNames(String query) async {
  final firestore = FirebaseFirestore.instance;

  // Obtener todos los documentos de la colección "categories"
  final snapshot = await firestore.collection('categories').get();

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

  Future<void> performSearch(
      String query, Map<String, dynamic>? filters) async {
    final results = await _searchController.searchWithFilters(query, filters);
    state = results;
  }

  // Método para limpiar resultados
  void clearResults() {
    state = [];
  }
}
