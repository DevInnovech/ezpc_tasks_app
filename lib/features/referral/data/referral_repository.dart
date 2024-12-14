import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/referral_model.dart';

class ReferralRepository {
  Future<List<ReferralModel>> fetchReferrals(String referralCode) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('referralPartner', isEqualTo: referralCode)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return ReferralModel(
        name: '${data['name'] ?? ''} ${data['lastName'] ?? ''}',
        jobTitle: data['role'] ?? '',
        isActive: true, // Por ahora, asumimos que siempre están activos
        date: data['date'] != null
            ? (data['date'] as Timestamp).toDate().toString()
            : DateTime.now().toString(),
        bonusAmount: 0.0, // Inicialmente, 0 para pruebas
        imageUrl: data['profileImageUrl'] ?? '', // Agrega una imagen válida
      );
    }).toList();
  }
}
