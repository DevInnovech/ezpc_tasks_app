import 'package:ezpc_tasks_app/features/About%20me/models/AboutMeModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/aboutme_repository.dart';

// Provider para obtener los datos del perfil del proveedor
final aboutMeProvider = FutureProvider<AboutMeModel>((ref) async {
  final repository = ref.watch(aboutMeRepositoryProvider);
  return repository.getAboutMe();
});

// Provider para editar la descripción del proveedor
final aboutMeEditProvider =
    StateNotifierProvider<AboutMeEditNotifier, AboutMeModel?>((ref) {
  final initialProfile = ref.watch(aboutMeProvider).maybeWhen(
        data: (profile) => profile,
        orElse: () => null,
      );
  return AboutMeEditNotifier(initialProfile);
});

class AboutMeEditNotifier extends StateNotifier<AboutMeModel?> {
  AboutMeEditNotifier(AboutMeModel? initialProfile) : super(initialProfile);

  // Método para actualizar el perfil con nuevos datos
  void updateProfile(AboutMeModel updatedProfile) {
    state = updatedProfile;
  }
}
