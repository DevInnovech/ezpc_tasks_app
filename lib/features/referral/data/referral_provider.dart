import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/referral_repository.dart';
import '../models/referral_model.dart';

final referralRepositoryProvider = Provider((ref) => ReferralRepository());

final referralListProvider = FutureProvider<List<ReferralModel>>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception("User not logged in");
  }

  // Obtener el documento del usuario actual
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (!userDoc.exists) {
    throw Exception("User document not found");
  }

  final userData = userDoc.data() as Map<String, dynamic>;
  final referralCode = userData['referralCode'] ?? '';

  debugPrint("Referral Code: $referralCode");

  final repository = ref.watch(referralRepositoryProvider);
  return repository.fetchReferrals(referralCode);
});
