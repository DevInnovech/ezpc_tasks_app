import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/models/services_model.dart';

// Definición del estado de los servicios
final serviceProvider =
    StateNotifierProvider<ServiceNotifier, ServiceState>((ref) {
  return ServiceNotifier();
});

class ServiceState {
  final bool isLoading;
  final List<ServiceProductStateModel> services;
  final String? error;

  ServiceState({
    required this.isLoading,
    required this.services,
    this.error,
  });

  factory ServiceState.loading() => ServiceState(isLoading: true, services: []);
  factory ServiceState.loaded(List<ServiceProductStateModel> services) =>
      ServiceState(isLoading: false, services: services);
  factory ServiceState.error(String error) =>
      ServiceState(isLoading: false, services: [], error: error);
}

// Notificador de estado para manejar la lógica
class ServiceNotifier extends StateNotifier<ServiceState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ServiceNotifier() : super(ServiceState.loading()) {
    _loadServicesFromFirebase();
  }

  // Carga de datos desde Firebase
  Future<void> _loadServicesFromFirebase() async {
    try {
      // Obtenemos la colección de "services" de Firebase
      final QuerySnapshot snapshot =
          await _firestore.collection('services').get();

      // Convertimos los documentos de Firebase a objetos ServiceProductStateModel
      final List<ServiceProductStateModel> services = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ServiceProductStateModel.fromJson(data as String);
      }).toList();

      // Actualizamos el estado con los servicios obtenidos de Firebase
      state = ServiceState.loaded(services);
    } catch (e) {
      state = ServiceState.error(e.toString());
      print('Error loading services from Firebase: $e');
    }
  }

  // Método para guardar un nuevo servicio en Firebase
  Future<void> saveService(ServiceProductStateModel service) async {
    try {
      // Guardamos el servicio en la colección de Firebase
      await _firestore
          .collection('services')
          .doc(service.id)
          .set(service.toJson() as Map<String, dynamic>);

      // Recargamos los servicios desde Firebase
      _loadServicesFromFirebase();
    } catch (e) {
      print('Error saving service to Firebase: $e');
    }
  }

  // Simulación de carga de datos (si decides no usar Firebase para pruebas locales)
  void _loadServices() {
    final services = [
      const ServiceProductStateModel(
        id: "pp",
        name: 'Service 1',
        slug: 'service-1',
        price: '100.00',
        categoryId: '1',
        subCategoryId: '1.1',
        details: 'Details for service 1',
        image: 'https://example.com/image.png',
        packageFeature: ['Feature 1', 'Feature 2'],
        benefits: ['Benefit 1', 'Benefit 2'],
        whatYouWillProvide: ['Provide 1', 'Provide 2'],
        licenseDocument: 'https://example.com/license.pdf',
        workingDays: ['Monday', 'Wednesday', 'Friday'],
        workingHours: [
          {'day': 'Monday', 'from': '08:00 AM', 'to': '05:00 PM'},
          {'day': 'Wednesday', 'from': '09:00 AM', 'to': '06:00 PM'},
          {'day': 'Friday', 'from': '10:00 AM', 'to': '07:00 PM'},
        ],
        specialDays: [
          {'date': '2024-12-25', 'from': '10:00 AM', 'to': '02:00 PM'},
        ],
        status: 'Active',
      ),
      const ServiceProductStateModel(
        id: "ss",
        name: 'Service 2',
        slug: 'service-2',
        price: '150.00',
        categoryId: '2',
        subCategoryId: '2.1',
        details: 'Details for service 2',
        image: 'https://example.com/image.png',
        packageFeature: ['Feature A', 'Feature B'],
        benefits: ['Benefit A', 'Benefit B'],
        whatYouWillProvide: ['Provide A', 'Provide B'],
        licenseDocument: 'https://example.com/license.pdf',
        workingDays: ['Tuesday', 'Thursday'],
        workingHours: [
          {'day': 'Tuesday', 'from': '09:00 AM', 'to': '05:00 PM'},
          {'day': 'Thursday', 'from': '09:00 AM', 'to': '05:00 PM'},
        ],
        specialDays: [],
        status: 'Inactive',
      ),
    ];

    // Actualiza el estado con los servicios simulados
    state = ServiceState.loaded(services);
  }
}
