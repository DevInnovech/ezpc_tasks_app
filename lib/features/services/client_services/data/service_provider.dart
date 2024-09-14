import 'package:ezpc_tasks_app/features/lista_de_provedores.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';

class ServiceNotifier extends StateNotifier<ServiceState> {
  final List<ProviderModel> providerList;

  ServiceNotifier(this.providerList) : super(ServiceState(services: []));

  Future<void> fetchServices() async {
    await Future.delayed(const Duration(seconds: 1));

    // Aquí asignamos proveedores a los servicios
    state = ServiceState(services: [
      ServiceModel(
        id: '1',
        name: 'AC repair service',
        slug: 'ac-repair-service',
        price: '50.0',
        categoryId: categories[1],
        subCategoryId: '1.1',
        details:
            'We provide the best AC repair service for residential and commercial units.',
        image: 'https://example.com/images/ac-repair.jpg',
        packageFeature: ['Fast', 'Reliable', 'Certified Technicians'],
        benefits: [
          'Free consultation',
          '24/7 customer support',
          'Affordable pricing'
        ],
        whatYouWillProvide: [
          'AC unit',
          'Access to power supply',
          'Parking space for technicians'
        ],
        licenseDocument: 'https://example.com/licenses/ac-repair-license.pdf',
        workingDays: ['Monday', 'Wednesday', 'Friday'],
        workingHours: [
          {'day': 'Monday', 'from': '09:00 AM', 'to': '05:00 PM'},
          {'day': 'Wednesday', 'from': '09:00 AM', 'to': '05:00 PM'},
          {'day': 'Friday', 'from': '09:00 AM', 'to': '05:00 PM'},
        ],
        specialDays: [
          {'date': '2024-12-25', 'from': '10:00 AM', 'to': '02:00 PM'}
        ],
        status: 'active',
        provider: providerList[0], // Asignar el primer proveedor
      ),
      ServiceModel(
        id: '2',
        name: 'Plumbing Service',
        slug: 'plumbing-service',
        price: '75.0',
        categoryId: categories[0],
        subCategoryId: '2.1',
        details:
            'Our expert plumbing services include leak detection, repair, and installation.',
        image: 'https://example.com/images/plumbing-service.jpg',
        packageFeature: [
          'Certified plumbers',
          'Quick response',
          'Guaranteed service'
        ],
        benefits: [
          '24/7 emergency service',
          'Free re-inspection within 30 days'
        ],
        whatYouWillProvide: [
          'Water supply access',
          'Clear area for repairs',
          'On-site contact person'
        ],
        licenseDocument: 'https://example.com/licenses/plumbing-license.pdf',
        workingDays: ['Tuesday', 'Thursday'],
        workingHours: [
          {'day': 'Tuesday', 'from': '09:00 AM', 'to': '06:00 PM'},
          {'day': 'Thursday', 'from': '09:00 AM', 'to': '06:00 PM'},
        ],
        specialDays: [],
        status: 'active',
        provider: providerList[1], // Asignar el segundo proveedor
      ),
    ]);
  }
}

// Clase que contiene el estado de los servicios
class ServiceState {
  final List<ServiceModel> services;

  ServiceState({required this.services});
}

// Proveedor para ServiceNotifier que también obtiene la lista de proveedores
final serviceProvider = FutureProvider.autoDispose((ref) async {
  final providerList = await ref.watch(providerListProvider.future);
  final serviceNotifier = ServiceNotifier(providerList);
  await serviceNotifier.fetchServices();
  return serviceNotifier.state;
});
