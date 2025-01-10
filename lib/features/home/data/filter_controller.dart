import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchController {
  final FirebaseFirestore _firestore;

  SearchController(this._firestore);

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.isEmpty) return [];

    final Set<Map<String, dynamic>> results = {};

    try {
      // Obtener todas las categorías y sus servicios
      final categoriesSnapshot =
          await _firestore.collection('categories').get();
      final categories =
          categoriesSnapshot.docs.map((doc) => doc.data()).toList();

      print('Categorías obtenidas: $categories');

      // Buscar en cada categoría
      for (var category in categories) {
        final categoryName = category['name'] ?? 'Unknown Category';
        final categoryId = category['categoryId'];
        final services = category['services'] as List<dynamic>? ?? [];

        for (var service in services) {
          if (service['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
            final serviceId = service['serviceId'];
            results.add({
              'serviceName': service['name'],
              'serviceId': serviceId,
              'categoryName': categoryName,
              'categoryId': categoryId,
              'type': 'categoryService',
            });
          }
        }
      }

      print('Resultados tras buscar en categorías: $results');

      // Buscar en las tareas (tasks)
      final tasksSnapshot = await _firestore.collection('tasks').get();
      final tasks = tasksSnapshot.docs.map((doc) => doc.data()).toList();

      print('Tareas obtenidas: $tasks');

      for (var task in tasks) {
        final selectedTasks =
            task['selectedTasks'] as Map<String, dynamic>? ?? {};
        for (var selectedTask in selectedTasks.entries) {
          if (selectedTask.key.toLowerCase().contains(query.toLowerCase())) {
            results.add({
              'taskName': selectedTask.key,
              'price': selectedTask.value,
              'providerId': task['providerId'],
              'imageUrl': task['imageUrl'] ?? '',
              'type': 'task',
            });
          }
        }
      }

      print('Resultados tras buscar en tareas: $results');
    } catch (e) {
      print('Error al realizar la búsqueda: $e');
    }

    // Estructurar los resultados
    final structuredResults = results
        .map((result) {
          if (result['type'] == 'categoryService') {
            return {
              'serviceName': result['serviceName'],
              'serviceId': result['serviceId'],
              'categoryName': result['categoryName'],
              'categoryId': result['categoryId'],
              'type': 'categoryService',
            };
          } else if (result['type'] == 'task') {
            return {
              'taskName': result['taskName'],
              'price': result['price'],
              'providerId': result['providerId'],
              'imageUrl': result['imageUrl'],
              'type': 'task',
            };
          }
          return null;
        })
        .where((item) => item != null)
        .toList();

    print('Resultados estructurados: $structuredResults');

    // Eliminar duplicados basados en `serviceId` o `taskName`
    final uniqueResults = structuredResults
        .fold<Map<String, Map<String, dynamic>>>(
          {},
          (map, item) {
            final uniqueKey = item!['serviceId'] ?? item['taskName'];
            map[uniqueKey] = item;
            return map;
          },
        )
        .values
        .toList();

    print('Resultados únicos: $uniqueResults');

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
    print('Realizando búsqueda con query: $query');
    final results = await _searchController.search(query);
    print('Resultados finales para el query: $results');
    state = results;
  }

  void clearResults() {
    print('Limpiando resultados de búsqueda');
    state = [];
  }
}
