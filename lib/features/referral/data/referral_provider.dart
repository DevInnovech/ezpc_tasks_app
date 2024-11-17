import 'package:ezpc_tasks_app/features/referral/data/referral_repository.dart';
import 'package:ezpc_tasks_app/features/referral/models/referral_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final referralRepositoryProvider = Provider((ref) => ReferralRepository());

final referralListProvider = FutureProvider<List<ReferralModel>>((ref) async {
  final repository = ref.watch(referralRepositoryProvider);
  return repository.fetchReferrals();
});
