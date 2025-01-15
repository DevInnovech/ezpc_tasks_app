import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  Map<String, dynamic>? _monthlyPerformance;
  Map<String, dynamic>? _annualPerformance;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  void _fetchPerformanceData() async {
    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final monthlyPerformance = await _getMonthlyPerformance(userId);
    final annualPerformance = await _getAnnualPerformance(userId);

    setState(() {
      _monthlyPerformance = monthlyPerformance;
      _annualPerformance = annualPerformance;
      _isLoading = false;
    });
  }

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
              if (_monthlyPerformance != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildPerformanceCard(
                      'Jobs Completed',
                      _monthlyPerformance?['currentMonth']['completed'] ?? 0,
                      _monthlyPerformance?['percentageCompleted'] ?? 0.0,
                      Colors.green,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceCard(
                      'Re-Schedules',
                      _monthlyPerformance?['currentMonth']['reschedules'] ?? 0,
                      _monthlyPerformance?['percentageReschedules'] ?? 0.0,
                      primaryColor,
                      primaryColor,
                    ),
                    _buildPerformanceCard(
                      'Cancelations',
                      _monthlyPerformance?['currentMonth']?['canceled'] ?? 0,
                      _monthlyPerformance?['percentageCanceled'] ?? 0.0,
                      Colors.red,
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    if (_annualPerformance != null)
                      _buildAnnualPerformanceCard(_annualPerformance!),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getAnnualPerformance(String providerId) async {
    try {
      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .get();

      if (!providerDoc.exists) {
        debugPrint("Provider not found.");
        return {};
      }

      final providerData = providerDoc.data() as Map<String, dynamic>? ?? {};

      final performanceData =
          providerData['performance'] as Map<String, dynamic>? ?? {};

      final String currentYear = DateFormat('yyyy').format(DateTime.now());
      final Map<String, dynamic> yearlyPerformance = {};

      performanceData.forEach((key, value) {
        if (key.startsWith(currentYear)) {
          final month = key.split('-')[1]; // Extraer el mes
          yearlyPerformance[month] = value;
        }
      });

      return yearlyPerformance;
    } catch (e) {
      debugPrint("Error fetching annual performance: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> _getMonthlyPerformance(String providerId) async {
    try {
      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .get();

      if (!providerDoc.exists) {
        debugPrint("Provider not found.");
        return {};
      }

      final providerData = providerDoc.data() as Map<String, dynamic>? ?? {};

      final performanceData =
          providerData['performance'] as Map<String, dynamic>? ?? {};

      final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final String previousMonth = DateFormat('yyyy-MM').format(
        DateTime.now().subtract(const Duration(days: 30)),
      );

      final currentMonthData =
          performanceData[currentMonth] as Map<String, dynamic>? ??
              {
                'completed': 0,
                'canceled': 0,
                'reschedules': 0,
              };

      final previousMonthData =
          performanceData[previousMonth] as Map<String, dynamic>? ??
              {
                'completed': 0,
                'canceled': 0,
                'reschedules': 0,
              };

      // Cálculo del porcentaje de incremento o decremento
      double calculatePercentage(int current, int previous) {
        if (previous == 0) return current > 0 ? 100.0 : 0.0;
        return ((current - previous) / previous) * 100;
      }

      final performance = {
        'currentMonth': currentMonthData,
        'previousMonth': previousMonthData,
        'percentageCompleted': calculatePercentage(
          currentMonthData['completed'] ?? 0,
          previousMonthData['completed'] ?? 0,
        ),
        'percentageCanceled': calculatePercentage(
          currentMonthData['canceled'] ?? 0,
          previousMonthData['canceled'] ?? 0,
        ),
        'percentageReschedules': calculatePercentage(
          currentMonthData['reschedules'] ?? 0,
          previousMonthData['reschedules'] ?? 0,
        ),
      };

      return performance;
    } catch (e) {
      debugPrint("Error fetching performance: $e");
      return {};
    }
  }

  Widget _buildReviewCard() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
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

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        // Información ya calculada por la función
        final double averageRating =
            (userData['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int totalReviews = userData['totalReviews'] ?? 0;
        final Map<String, dynamic>? mostRecentReview =
            userData['mostRecentReview'] as Map<String, dynamic>?;

        // Buscar la imagen del cliente con el clientId
        final String clientId = mostRecentReview?['clientId'] ?? '';
        final String reviewText =
            mostRecentReview?['review'] ?? 'No recent review available.';
        final double recentRating =
            (mostRecentReview?['rating'] as num?)?.toDouble() ?? 0.0;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(clientId)
              .get(),
          builder: (context, clientSnapshot) {
            if (clientSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final clientData =
                clientSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final String clientImage =
                clientData['profileImageUrl'] ?? KImages.pp;

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
                                reviewText.length > 30
                                    ? '${reviewText.substring(0, 30)}...' // Trunca si es muy largo
                                    : reviewText, // Texto completo si es corto
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star,
                                    color: index < recentRating.toDouble()
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

  Widget _buildAnnualPerformanceCard(Map<String, dynamic> yearlyData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: ExpansionTile(
        title: const Text(
          "Annual Performance",
          style: TextStyle(
              color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        children: yearlyData.entries.map((entry) {
          final month = entry.key;
          final data = entry.value as Map<String, dynamic>;

          return ListTile(
            title: Text(
              "Month: $month",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Completed: ${data['completed'] ?? 0}, "
              "Canceled: ${data['canceled'] ?? 0}, "
              "Reschedules: ${data['reschedules'] ?? 0}",
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceCard(String title, int value, double percentage,
      Color arrowColor, Color progressBarColor) {
    final isNegative = percentage < 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    Icon(
                      isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isNegative ? Colors.red : arrowColor,
                    ),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                          fontSize: 28,
                          color: isNegative ? Colors.red : arrowColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              minHeight: 18,
              value: (value / 100).clamp(0.0, 1.0),
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
