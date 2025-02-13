import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ondemand.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referall_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/end_drawer_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<Map<String, dynamic>> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final doc = await FirebaseFirestore.instance
          .collection('about_me')
          .doc(user.uid)
          .get();
      return doc.data() ?? {};
    } catch (e) {
      debugPrint("Error loading user data: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final activeBookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .where('status')
          .get();
      final activeBookings = activeBookingsQuery.size;

      final pendingBookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingBookings = pendingBookingsQuery.size;

      final transactionsQuery = await FirebaseFirestore.instance
          .collection('transactions')
          .where('providerId', isEqualTo: user.uid)
          .where('withdrawStatus', isEqualTo: 'not_started')
          .get();
      final remainingPayout = transactionsQuery.docs.fold<double>(
        0.0,
        (sum, doc) => sum + (doc['amount'] ?? 0.0),
      );

      final totalRevenueQuery = await FirebaseFirestore.instance
          .collection('transactions')
          .where('providerId', isEqualTo: user.uid)
          .get();
      final totalRevenue = totalRevenueQuery.docs.fold<double>(
        0.0,
        (sum, doc) => sum + (doc['amount'] ?? 0.0),
      );

      return {
        'activeBookings': activeBookings,
        'pendingBookings': pendingBookings,
        'remainingPayout': remainingPayout,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
      return {
        'activeBookings': 0,
        'pendingBookings': 0,
        'remainingPayout': 0.0,
        'totalRevenue': 0.0,
      };
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

  Future<List<FlSpot>> _loadBookingsChartData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .get();

      final Map<int, int> bookingsPerDay = {};

      for (var doc in bookingsQuery.docs) {
        final timestamp = doc['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final day = date.day;

          bookingsPerDay[day] = (bookingsPerDay[day] ?? 0) + 1;
        }
      }

      return bookingsPerDay.entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
          .toList();
    } catch (e) {
      debugPrint("Error loading bookings chart data: $e");
      return [];
    }
  }

  Future<void> checkReferralStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final referralPartner = data['referralPartner'] ?? '';

      // Si el usuario no tiene referralPartner y no ha indicado 'no_referral'
      // entonces mostramos el diálogo.
      // Si referralPartner == 'no_referral', no mostramos nada.
      if (referralPartner.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const ReferralDialog(),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkReferralStatus();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final accountType = ref.read(accountTypeProvider);

    // Determinar el texto que se mostrará según el tipo de cuenta
    String roleText = '';
    if (accountType == AccountType.client) {
      roleText = 'Role: Client';
    } else if (accountType == AccountType.independentProvider) {
      roleText = 'Role: Provider';
    } else if (accountType == AccountType.employeeProvider) {
      roleText = 'Role: Employee Provider';
    } else if (accountType == AccountType.corporateProvider) {
      roleText = 'Role: Corporate Provider';
    } else {
      roleText = 'Role: Unknown';
    }

    return Scaffold(
      key: scaffoldKey,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data ?? {};
          final userName = userData['name'] ?? "John Doe";
          final profileImage = userData['imagen'];

          return FutureBuilder<Map<String, dynamic>>(
            future: _loadDashboardData(),
            builder: (context, dashboardSnapshot) {
              if (dashboardSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final dashboardData = dashboardSnapshot.data ??
                  {
                    'activeBookings': 0,
                    'pendingBookings': 0,
                    'remainingPayout': 0.0,
                    'totalRevenue': 0.0,
                  };

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    backgroundColor: primaryColor,
                    toolbarHeight: Utils.vSize(240.0),
                    centerTitle: true,
                    actions: const [SizedBox()],
                    title: Column(
                      children: [
                        Utils.verticalSpace(20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                  text: "Good Morning!",
                                  fontSize: 14.0,
                                  color: Color(0xCCFFFFFF),
                                ),
                                CustomText(
                                  text: userName,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w700,
                                  color: whiteColor,
                                ),
                                CustomText(
                                  text: roleText,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: whiteColor,
                                ),
                              ],
                            ),
                            const AvailabilitySwitch()
                            /*      GestureDetector(
                              onTap: () {
                                scaffoldKey.currentState!.openEndDrawer();
                              },
                              child: Container(
                                height: Utils.vSize(55.0),
                                width: Utils.vSize(60.0),
                                margin: Utils.only(right: 10.0),
                                child: ClipRRect(
                                  borderRadius: Utils.borderRadius(r: 6.0),
                                  child: profileImage != null
                                      ? Image.network(
                                          profileImage,
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                        */
                          ],
                        ),
                        Utils.verticalSpace(20),
                        _buildBalanceCard(
                          dashboardData['remainingPayout'].toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.spaceEvenly,
                        children: [
                          _buildDashboardCard(
                            KImages.d01,
                            "${dashboardData['activeBookings']}",
                            "Active Bookings",
                          ),
                          _buildDashboardCard(
                            KImages.d02,
                            "${dashboardData['pendingBookings']}",
                            "Pending Bookings",
                          ),
                          _buildDashboardCard(
                            KImages.d03,
                            "\$${dashboardData['totalRevenue'].toStringAsFixed(2)}",
                            "Total Revenue",
                          ),
                          _buildDashboardCard(
                            KImages.d04,
                            "\$${dashboardData['remainingPayout'].toStringAsFixed(2)}",
                            "Remaining Payout",
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Recent Transactions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/walletScreen');
                                },
                                child: const Text(
                                  "View All",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 2), // Espacio entre encabezado y tarjetas
                          _buildRecentTransactions(), // Renderiza las tarjetas de transacciones
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bookings Over Time",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<FlSpot>>(
                            future: _loadBookingsChartData(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final spots = snapshot.data ?? [];

                              return SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: const Border(
                                        bottom: BorderSide(color: Colors.black),
                                        left: BorderSide(color: Colors.black),
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (value, meta) =>
                                              Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (value, meta) =>
                                              Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5F60BA),
                                            Color(0xFF8A89D6)
                                          ],
                                        ),
                                        barWidth: 3,
                                        belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      endDrawer: const EndDrawerMenu(),
      endDrawerEnableOpenDragGesture: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildRecentTransactions() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
          return const Text("No transactions found.");
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
                borderRadius: Utils.borderRadius(r: 8.0),
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
                          borderRadius: Utils.borderRadius(r: 4.0),
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

  Widget _buildDashboardCard(String icon, String count, String title) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      height: 100.0,
      width: (MediaQuery.of(context).size.width - 48) / 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Utils.borderRadius(),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9F0FF),
            ),
            child: CustomImage(
              path: icon,
              url: null,
            ),
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 36, 36, 62),
        borderRadius: Utils.borderRadius(r: 8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomText(
            text: "My Available Balance",
            fontSize: 16,
            color: Colors.white70,
          ),
          Utils.verticalSpace(10),
          CustomText(
            text: "\$$balance",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
