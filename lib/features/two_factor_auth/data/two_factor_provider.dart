import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/two_factor_repository.dart';

final authMethodProvider = StateProvider<String>((ref) => '');
final verificationStatusProvider = StateProvider<bool>((ref) => false);

final verificationProvider =
    FutureProvider.family<bool, String>((ref, code) async {
  final repository = ref.watch(twoFactorRepositoryProvider);
  return await repository.verifyCode(code);
});
