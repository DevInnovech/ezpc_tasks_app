import 'package:ezpc_tasks_app/features/home/models/provider_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardNotifier extends StateNotifier<ProviderDashBoardModel?> {
  DashboardNotifier() : super(null);

  Future<void> fetchDashboard() async {
    try {
      // Aquí deberías llamar a tu API o servicio para obtener el dashboard
      //final dashboardData = await fetchDashboardFromApi();
//state = dashboardData;
    } catch (e) {
      // Manejar error, si es necesario
    }
  }

  Future<double?> fetchProfile() async {
    try {
      // Aquí deberías llamar a tu API o servicio para obtener el perfil
      // final profileData = await fetchProfileFromApi();
      /*   if (profileData != null) {
        state = profileData;
        return profileData.currentBalance;
      }*/
      return null;
    } catch (e) {
      // Manejar error, si es necesario
      return null;
    }
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, ProviderDashBoardModel?>(
  (ref) => DashboardNotifier(),
);
