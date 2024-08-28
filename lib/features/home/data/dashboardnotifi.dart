import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Simular balance
    final double simulatedBalance = 1200.0;

    // Devolver el widget con el balance simulado
    return LoadedBalanceWidget(balance: simulatedBalance);
  }
}

class LoadedBalanceWidget extends StatelessWidget {
  const LoadedBalanceWidget({super.key, required this.balance});

  final double balance;

  String formatPrice(BuildContext context, double price) {
    // Aquí asumimos que la moneda siempre es $
    const String currency = '\$';

    return '$currency${price.toStringAsFixed(0)}';
  }

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
                text: formatPrice(context, balance),
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
}
