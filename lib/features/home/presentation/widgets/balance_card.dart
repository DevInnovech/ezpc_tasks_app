import 'package:ezpc_tasks_app/features/home/data/dashboardprovider.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/*/*
// Provider que maneja el balance disponible del perfil
final balanceProvider = FutureProvider<double?>((ref) async {
  final profile = ref.read(dashboardProvider);
  if (profile != null) {
    return profile.currentBalance;
  }
  // Simular recarga del perfil si no está cargado
  return ref.watch(dashboardNotifierProvider.notifier).fetchProfile();
});*/

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  //  final balanceAsyncValue = ref.watch(balanceProvider);

    return balanceAsyncValue.when(
      data: (balance) {
        if (balance != null) {
          return LoadedBalanceWidget(balance: balance);
        } else {
          return const SizedBox();
        }
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

class LoadedBalanceWidget extends StatelessWidget {
  const LoadedBalanceWidget({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Utils.vSize(100.0),
      alignment: Alignment.center,
      margin: Utils.only(top: 20.0),
      padding: Utils.symmetric(h: 16.0),
      decoration: BoxDecoration(
        color: blackColor,
        borderRadius: Utils.borderRadius(r: 6.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomText(
                text: 'My Available Balance',
                fontSize: 12.0,
                color: whiteColor,
              ),
              Utils.verticalSpace(6.0),
              CustomText(
                text: "25000\$",
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
                color: whiteColor,
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ButtonStyle(
              minimumSize: MaterialStatePropertyAll(
                  Size(Utils.hSize(112.0), Utils.vSize(45.0))),
              backgroundColor: const MaterialStatePropertyAll(primaryColor),
            ),
            onPressed: () => showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => Container(), // Tu lógica para el dialog
            ),
            icon: const CustomImage(path: KImages.withdrawIcon),
            label: const CustomText(
              text: 'Withdraw',
              color: whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}*/
