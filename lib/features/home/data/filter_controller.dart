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

      return filteredResults;
    } catch (e) {
      print('Error al realizar la búsqueda: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _applyFilters(
      Set<Map<String, dynamic>> results, Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) return results.toList();

    // Filtrar por fecha
    if (filters.containsKey('Date')) {
      String dateFilter = filters['Date'];
      DateTime now = DateTime.now();
      DateTime filterDate;

      switch (dateFilter) {
        case 'Same Day':
          filterDate = now;
          break;
        case 'Last Week':
          filterDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last Month':
          filterDate = DateTime(now.year, now.month - 1, now.day);
          break;
        default:
          filterDate = now;
      }

      results = results.where((result) {
        final timestamp = result['createdAt'] as Timestamp?;
        if (timestamp == null) return false;
        return timestamp.toDate().isAfter(filterDate);
      }).toSet();
    }

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
    }

    // Filtrar por calificación
    if (filters.containsKey('Rating')) {
      String ratingFilter = filters['Rating'];
      final minRating = double.tryParse(ratingFilter) ?? 0;
      results = results.where((result) {
        final rating = result['rating'] as double?;
        return rating != null && rating >= minRating;
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
