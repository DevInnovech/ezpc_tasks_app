import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/features/home/data/dashboardnotifi.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referall_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Future<Map<String, dynamic>?> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final doc = await FirebaseFirestore.instance
          .collection('about_me')
          .doc(user.uid)
          .get();
      return doc.data();
    } catch (e) {
      debugPrint("Error loading user data: $e");
      return null;
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Failed to load user data."));
          }

          final userData = snapshot.data!;
          final userName = userData['name'] ?? "John Doe";
          final profileImage = userData['imagen'];

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
                              color: Color(0xCCFFFFFF), // Blanco con opacidad
                            ),
                            // Nombre dinámico del usuario
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
                        GestureDetector(
                          onTap: () {
                            scaffoldKey.currentState!.openEndDrawer();
                          },
                          child: Container(
                            height: Utils.vSize(55.0),
                            width: Utils.vSize(60.0),
                            margin: Utils.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: Utils.borderRadius(r: 6.0),
                              child: profileImage != null &&
                                      profileImage.isNotEmpty
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
                      ],
                    ),
                    const BalanceCard(),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Utils.verticalSpace(20.0),
              ),
              SliverToBoxAdapter(
                child: Wrap(
                  runSpacing: Utils.vSize(14.0),
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    _buildSingleCard(KImages.d01, '10', 'Active Booking'),
                    _buildSingleCard(KImages.d02, '20', 'Pending Booking'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      endDrawer: const EndDrawerMenu(),
      endDrawerEnableOpenDragGesture: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildSingleCard(String icon, String count, String title) {
    return Container(
      padding: Utils.symmetric(v: 0.0, h: 0.0),
      height: Utils.vSize(80.0),
      width: Utils.hSize(172.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: Utils.borderRadius(),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: Utils.vSize(38.0),
            width: Utils.vSize(38.0),
            margin: Utils.only(left: 8.0, right: 6.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: scaffoldBgColor,
              shape: BoxShape.circle,
            ),
            child: CustomImage(
              path: icon,
              url: null,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: count.padLeft(2, '0'),
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
              CustomText(
                text: title,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: grayColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
