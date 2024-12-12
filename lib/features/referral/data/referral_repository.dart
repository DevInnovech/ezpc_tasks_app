// lib/features/referral/data/referral_repository.dart

import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';

import '../models/referral_model.dart';

class ReferralRepository {
  Future<List<ReferralModel>> fetchReferrals() async {
    await Future.delayed(
        const Duration(seconds: 1)); // Simulando retraso de red

    return [
      ReferralModel(
        name: "Jose Florez",
        jobTitle: "Trabajo X",
        isActive: true,
        date: "06/02/2024",
        bonusAmount: 20.0,
        imageUrl: KImages.pp,
      ),
      ReferralModel(
        name: "Tifany Plures",
        jobTitle: "Trabajo Y",
        isActive: false,
        date: "06/02/2024",
        bonusAmount: 15.0,
        imageUrl: KImages.pp,
      ),
      // Más datos de ejemplo
    ];
  }
}
