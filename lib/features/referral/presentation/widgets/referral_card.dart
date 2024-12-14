import 'package:ezpc_tasks_app/features/referral/models/referral_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReferralCard extends StatelessWidget {
  final ReferralModel referral;

  const ReferralCard({super.key, required this.referral});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar del usuario referido
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.purple[100],
              backgroundImage: referral.imageUrl.isNotEmpty
                  ? NetworkImage(referral.imageUrl)
                  : null,
              child: referral.imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 24, color: Colors.purple)
                  : null,
            ),
            const SizedBox(width: 16),
            // Nombre, título y fecha del referido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referral.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    referral.jobTitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Fecha y monto del bono
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('MM/dd/yyyy')
                      .format(DateTime.parse(referral.date)),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '\$${referral.bonusAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
