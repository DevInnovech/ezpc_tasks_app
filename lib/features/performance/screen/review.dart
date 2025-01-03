import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewOnTasksScreen extends StatelessWidget {
  const ReviewOnTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        title: const Text(
          'Review On Tasks',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .doc(user!.uid)
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No reviews available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final reviews = snapshot.data!.docs;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Customer Review By Tasks Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...reviews.map((review) {
                    final data = review.data() as Map<String, dynamic>;
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _fetchAdditionalData(
                        clientId: data['clientId'],
                        bookingId: data['bookingId'],
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final additionalData = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _buildReviewCard(
                            name: additionalData['clientName'] ?? 'Unknown',
                            username:
                                '@${additionalData['username'] ?? 'USER'}',
                            taskName: additionalData['taskName'] ?? 'N/A',
                            rating: data['rating']?.toDouble() ?? 0.0,
                            date: _formatDate(data['createdAt']),
                            reviewText: data['review'] ?? '',
                            avatar: additionalData['clientImage'] ?? KImages.pp,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchAdditionalData({
    required String clientId,
    required String bookingId,
  }) async {
    final clientSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(clientId)
        .get();

    final bookingSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .get();

    final clientData = clientSnapshot.data() ?? {};
    final bookingData = bookingSnapshot.data() ?? {};

    return {
      'clientName': clientData['name'] ?? 'Unknown',
      'clientImage': clientData['profileImageUrl'] ?? KImages.pp,
      'username': clientData['username'] ?? "USER",
      'taskName': bookingData['selectedTaskName'] ?? 'N/A',
    };
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildReviewCard({
    required String name,
    required String username,
    required String taskName,
    required double rating,
    required String date,
    required String reviewText,
    required String avatar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(avatar),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              /*  IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  // Handle delete action
                },
              ),*/
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Name : $taskName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < rating ? Colors.orange : Colors.grey,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$rating',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  reviewText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
