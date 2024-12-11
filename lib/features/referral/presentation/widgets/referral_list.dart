import 'package:ezpc_tasks_app/features/referral/data/referral_provider.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referral_bonus_header.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referral_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReferralList extends ConsumerWidget {
  const ReferralList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralListAsync = ref.watch(referralListProvider);

    return referralListAsync.when(
      data: (referrals) {
        double totalBonus =
            referrals.fold(0, (sum, item) => sum + item.bonusAmount);

        return Column(
          children: [
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
