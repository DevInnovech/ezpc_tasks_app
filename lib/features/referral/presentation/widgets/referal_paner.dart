import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReferralHeader extends StatelessWidget {
  final String referralPartnerCode;
  const ReferralHeader({super.key, required this.referralPartnerCode});

  Future<String> _getReferrerName() async {
    if (referralPartnerCode.isEmpty || referralPartnerCode == 'no_referral') {
      return "No fuiste referido por nadie";
    }
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('referralCode', isEqualTo: referralPartnerCode)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      final name = data['name'] ?? '';
      final lastName = data['lastName'] ?? '';
      return "Fuiste referido por: $name $lastName";
    } else {
      return "Código de referencia no encontrado";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getReferrerName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 50, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Text("Error al cargar el referente");
        }
        return Text(snapshot.data ?? "No fuiste referido por nadie");
      },
    );
  }
}
