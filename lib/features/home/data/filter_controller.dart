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

      // Búsqueda en la colección de bookings por nombre de proveedor
      final serviceQueryByProvider = await _firestore
          .collection('bookings')
          .where('providerName', isGreaterThanOrEqualTo: query)
          .where('providerName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      results.addAll(serviceQueryByProvider.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
            'type': 'service',
          }));

      // Búsqueda en la colección de bookings por subcategorías (array y string)
      final serviceQueryBySubCategoryArray = await _firestore
          .collection('bookings')
          .where('selectedSubCategories', arrayContains: query)
          .get();

      final serviceQueryBySubCategorySingle = await _firestore
          .collection('bookings')
          .where('selectedSubCategories', isEqualTo: query)
          .get();

      results.addAll(serviceQueryBySubCategoryArray.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
            'type': 'service',
          }));

      results.addAll(serviceQueryBySubCategorySingle.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
            'type': 'service',
          }));
    } catch (e) {
      print('Error al realizar la búsqueda: $e');
    }

    // Estructurar resultados para jerarquía
    final structuredResults = results
        .map((result) {
          if (result['type'] == 'service') {
            // Manejo de selectedSubCategories como array o string
            final subcategories = result['selectedSubCategories'];
            final formattedSubcategories = subcategories is List
                ? subcategories.join(', ') // Es un array
                : subcategories ?? 'No Subcategories'; // Es un string o null

            return {
              'selectedSubCategories': formattedSubcategories,
              'providerName': result['providerName'] ?? 'No Provider Name',
              'providerEmail': result['providerEmail'] ?? 'No Provider Email',
              'providerPhone': result['providerPhone'] ?? 'No Provider Phone',
              'type': 'service',
              'id': result['id'],
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
