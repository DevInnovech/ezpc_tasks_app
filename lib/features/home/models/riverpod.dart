import 'package:ezpc_tasks_app/features/home/models/provider_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definimos los diferentes estados que puede tener el Dashboard
abstract class DashBoardState {
  const DashBoardState();
}

class DashBoardStateInitial extends DashBoardState {
  const DashBoardStateInitial();
}

class DashBoardStateLoading extends DashBoardState {
  const DashBoardStateLoading();
}

class DashBoardStateLoaded extends DashBoardState {
  final ProviderDashBoardModel providerDashBoard;

  const DashBoardStateLoaded(this.providerDashBoard);
}

class DashBoardStateError extends DashBoardState {
  final String message;
  final int status;

  const DashBoardStateError({required this.message, required this.status});
}

// Notificador que maneja el estado del Dashboard
class DashBoardNotifier extends StateNotifier<DashBoardState> {
  DashBoardNotifier() : super(const DashBoardStateInitial());

  ProviderDashBoardModel? providerDashboard;
  //UserWithCountryResponse? profile;

  Future<void> getDashBoard() async {
    try {
      state = const DashBoardStateLoading();
      // Aquí deberías realizar la llamada a tu servicio o repositorio para obtener el Dashboard
      // Simulando una llamada de red con un retraso
      await Future.delayed(const Duration(seconds: 2));

      // Después de obtener los datos, actualiza el estado con los datos cargados
      // providerDashboard = await miServicio.obtenerDashboard();
      state = DashBoardStateLoaded(providerDashboard!);
    } catch (e) {
      // En caso de error, actualiza el estado con un mensaje de error y el estado HTTP
      state = const DashBoardStateError(
          message: 'Failed to load data', status: 500);
    }
  }
}

final dashBoardNotifierProvider =
    StateNotifierProvider<DashBoardNotifier, DashBoardState>(
  (ref) => DashBoardNotifier(),
);
