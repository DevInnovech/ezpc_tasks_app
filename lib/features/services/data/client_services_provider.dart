import 'package:ezpc_tasks_app/features/services/models/client_services_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';

// Proveedor de servicios para el cliente
final serviceClientProvider =
    StateNotifierProvider<ServiceClientNotifier, ServiceClientState>((ref) {
  return ServiceClientNotifier();
});

// Definición del estado para los servicios del cliente
class ServiceClientState {
  final bool isLoading;
  final List<ServiceClientModel> services;
  final String? error;

  ServiceClientState({
    required this.isLoading,
    required this.services,
    this.error,
  });

  factory ServiceClientState.loading() =>
      ServiceClientState(isLoading: true, services: []);
  factory ServiceClientState.loaded(List<ServiceClientModel> services) =>
      ServiceClientState(isLoading: false, services: services);
  factory ServiceClientState.error(String error) =>
      ServiceClientState(isLoading: false, services: [], error: error);
}

// Notificador de estado para manejar la lógica de servicios del cliente
class ServiceClientNotifier extends StateNotifier<ServiceClientState> {
  ServiceClientNotifier() : super(ServiceClientState.loading()) {
    _loadServices();
  }

  // Simulación de carga de servicios para el cliente
  void _loadServices() {
    // Datos simulados para servicios
    final services = [
      const ServiceClientModel(
        name: 'Cleaning Service',
        slug: 'cleaning-service',
        price: '100.00',
        categoryId: '1',
        subCategoryId: '1.1',
        details: 'We offer premium home cleaning services.',
        image: KImages.s01,
        packageFeature: ['Fast', 'Reliable'],
        benefits: ['Free consultation', 'Satisfaction guaranteed'],
        whatYouWillProvide: ['All cleaning materials', 'Staff'],
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
      ),
      const ServiceClientModel(
        name: 'Plumbing Service',
        slug: 'plumbing-service',
        price: '150.00',
        categoryId: '2',
        subCategoryId: '2.1',
        details: 'Expert plumbing services for all your needs.',
        image: KImages.s01,
        packageFeature: ['Certified plumbers', 'Fast response'],
        benefits: ['24/7 emergency service', 'Warranty on repairs'],
        whatYouWillProvide: ['Plumbing tools', 'Expert team'],
        licenseDocument: 'https://example.com/license.pdf',
        workingDays: ['Tuesday', 'Thursday'],
        workingHours: [
          {'day': 'Tuesday', 'from': '09:00 AM', 'to': '05:00 PM'},
          {'day': 'Thursday', 'from': '09:00 AM', 'to': '05:00 PM'},
        ],
        specialDays: [],
      ),
    ];

    // Actualiza el estado con los servicios simulados
    state = ServiceClientState.loaded(services);
  }
}
