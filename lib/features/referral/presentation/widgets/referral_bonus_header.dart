import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class ReferralBonusHeader extends StatelessWidget {
  final double totalBonus;

  const ReferralBonusHeader({super.key, required this.totalBonus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "My Referrals Bonuses",
            style: TextStyle(
              color: primaryColor,
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          CircleAvatar(
            backgroundColor: primaryColor,
            radius:
                30, // Incrementa el tamaño del avatar para acomodar el texto
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "\$$totalBonus",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
