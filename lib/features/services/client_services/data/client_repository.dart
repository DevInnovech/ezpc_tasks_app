import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/client_model.dart';
import 'package:ezpc_tasks_app/features/services/client_services/data/client_repository.dart';

// Client provider to fetch the client data
final clientProvider = Provider<ClientModel>((ref) {
  final clientRepo = ClientRepository();
  return clientRepo.fetchClient();
});

class ClientRepository {
  ClientModel fetchClient() {
    // Simulated client data
    return ClientModel(
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '123-456-7890',
      address: '123 Main St, Anytown, USA',
      imageUrl: 'https://example.com/profile.jpg',
      totalBookings: 15,
      completedBookings: 12,
      activeBookings: 3,
    );
  }
}
