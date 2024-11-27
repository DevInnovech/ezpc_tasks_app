import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/lista_de_provedores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Final Provider to fetch schedules from the existing provider list
final scheduleProvider = FutureProvider<List<ProviderModel>>((ref) async {
  // Obtén los proveedores desde el providerListProvider
  final providers = await ref.watch(providerListProvider.future);

  // Aquí puedes manipular o filtrar los proveedores si lo necesitas
  return providers;
});
