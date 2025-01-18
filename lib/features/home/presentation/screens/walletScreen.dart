import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<double> _loadEarningsBalance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final transactionsQuery = await FirebaseFirestore.instance
          .collection('transactions')
          .where('providerId', isEqualTo: user.uid)
          .where('transactionType', isEqualTo: 'payment')
          .get();

      final totalBalance = transactionsQuery.docs.fold<double>(
        0.0,
        (sum, doc) => sum + (doc['amount'] ?? 0.0),
      );

      return totalBalance;
    } catch (e) {
      debugPrint("Error loading earnings balance: $e");
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('providerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      return [];
    }
  }

  Widget _buildRecentTransactions() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
          return const Center(child: Text("No transactions found."));
        }

        final transactions = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final type = transaction['service'] ?? 'Unknown';
            final status = transaction['status'] ?? 'Unknown';
            final amount = transaction['amount'] ?? 0.0;
            final createdAt =
                (transaction['createdAt'] as Timestamp?)?.toDate();
            final formattedDate = createdAt != null
                ? "${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')} · ${createdAt.month}/${createdAt.day}/${createdAt.year}"
                : '';
            final isPositive = transaction['transactionType'] == 'payment';

            return Container(
              margin: EdgeInsets.only(
                  top: index == 0 ? 0.0 : 12.0), // No margin for the first card
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE9F0FF),
                    ),
                    child: Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: status.toLowerCase() == 'hold'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status.toLowerCase() == 'hold'
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "${isPositive ? '+' : '-'}\$${amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wallet",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5F60BA),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Earnings Balance Container
            Container(
              width: double.infinity,
              color: const Color(0xFF5F60BA), // Purple background
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: FutureBuilder<double>(
                future: _loadEarningsBalance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final balance = snapshot.data ?? 0.0;

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141D3A), // Dark inner container
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Earnings Balance",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "\$${balance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildRecentTransactions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
