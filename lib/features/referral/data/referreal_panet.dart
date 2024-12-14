import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final referralPartnerProvider = FutureProvider<String>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return '';
  }

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (!doc.exists) {
    return '';
  }

  final data = doc.data() as Map<String, dynamic>;
  final referralPartner = data['referralPartner'] ?? '';
  return referralPartner;
});
