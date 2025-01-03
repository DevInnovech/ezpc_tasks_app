import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[150],
      appBar: AppBar(
        backgroundColor:
            primaryColor, // Cambiar a primaryColor si está definido
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        title: const Text('Performance',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: _buildReviewCard(),
                onTap: () => Navigator.pushNamed(
                    context, RouteNames.reviewOnTasksScreen),
              ),
              const SizedBox(height: 16),
              _buildPerformanceCard(
                  'Cancelations', 25, '9.23%', Colors.red, primaryColor),
              const SizedBox(height: 16),
              _buildPerformanceCard(
                  'Jobs Completed', 50, '90%', Colors.green, Colors.green),
              const SizedBox(height: 16),
              _buildPerformanceCard(
                  'Re-Schedules', 5, '50%', Colors.red, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('reviews')
          .doc(userId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No reviews available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          );
        }

        final reviews = snapshot.data!.docs;
        final double averageRating = reviews
                .map((doc) => (doc['rating'] as num).toDouble())
                .reduce((a, b) => a + b) /
            reviews.length;
        final totalReviews = reviews.length;
        final mostRecentReview = reviews.first.data() as Map<String, dynamic>;

        // Buscar la imagen del cliente con el clientId
        final clientId = mostRecentReview['clientId'];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(clientId)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final clientData =
                userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final clientImage = clientData['profileImageUrl'] ?? KImages.pp;

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              averageRating
                                  .toStringAsFixed(1), // Promedio de rating
                              style: const TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                '$totalReviews+ reviews', // Total de reseñas
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              NetworkImage(clientImage), // Imagen del cliente
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mostRecentReview['review'] != null
                                    ? (mostRecentReview['review'].length > 30
                                        ? '${mostRecentReview['review'].substring(0, 30)}...' // Trunca si supera 30 caracteres
                                        : mostRecentReview[
                                            'review']) // De lo contrario, muestra el texto completo
                                    : 'Great service experience with provider',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star,
                                    color: index <
                                            (mostRecentReview['rating'] as num)
                                                .toDouble()
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPerformanceCard(String title, int value, String percentage,
      Color arrowColor, Color progressBarColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value.toString(),
                        style: const TextStyle(
                            color: primaryColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: arrowColor),
                        Text(percentage,
                            style: TextStyle(
                                fontSize: 28,
                                color: arrowColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              minHeight: 18,
              value: value / 100,
              backgroundColor: progressBarColor.withOpacity(0.3),
              color: progressBarColor,
              borderRadius: BorderRadius.circular(30),
            ),
          ],
        ),
      ),
    );
  }
}
