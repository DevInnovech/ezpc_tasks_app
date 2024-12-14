import 'package:ezpc_tasks_app/features/referral/data/referral_provider.dart';
import 'package:ezpc_tasks_app/features/referral/data/referreal_panet.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referal_paner.dart'; // Asegúrate de tener el import correcto
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'referral_card.dart';
import 'referral_bonus_header.dart';
// Si es necesario

class ReferralList extends ConsumerWidget {
  const ReferralList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralListAsync = ref.watch(referralListProvider);
    final referralPartnerAsync = ref.watch(referralPartnerProvider);

    return referralListAsync.when(
      data: (referrals) {
        double totalBonus =
            referrals.fold(0, (sum, item) => sum + item.bonusAmount);

        return Column(
          children: [
            // Usar el FutureBuilder generado por Riverpod a través de referralPartnerAsync
            referralPartnerAsync.when(
              data: (partnerCode) {
                return ReferralHeader(referralPartnerCode: partnerCode);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) =>
                  Text('Error cargando referralPartner: $error'),
            ),

            ReferralBonusHeader(totalBonus: totalBonus),
            Expanded(
              child: ListView.builder(
                itemCount: referrals.length,
                itemBuilder: (context, index) {
                  return ReferralCard(referral: referrals[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
