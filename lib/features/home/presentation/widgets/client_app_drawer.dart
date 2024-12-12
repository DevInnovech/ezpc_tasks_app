import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ezpc_tasks_app/features/home/data/client_provider.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_curve_shape.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientAppDrawer extends ConsumerWidget {
  const ClientAppDrawer({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return doc.data()!;
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

    // Usamos el provider que sustituye el cubit para el perfil del usuario
    final dashboardProfileAsyncValue =
        ref.watch(clientDashBoardProfileProvider);

    return Drawer(
      backgroundColor: blackColor,
      child: Column(
        children: [
          SafeArea(
            top: false,
            child: SizedBox(
              height: 140.h,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No user data available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final userData = snapshot.data!;
                  final profileImageUrl =
                      userData['profileImageUrl'] as String?;
                  final name = userData['name'] as String? ?? 'Unknown';
                  final lastName = userData['lastName'] as String? ?? 'Unknown';
                  final email = userData['email'] as String? ?? 'No email';

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.50, color: Color(0xFFEAF4FF)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            /* Navigator.pushNamed(
                                context, RouteNames.editProfileScreen); */
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty
                                ? Image.network(
                                    profileImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error,
                                          color: Colors.red);
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  )
                                : Image.asset(
                                    KImages.pp, // Imagen predeterminada
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name $lastName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Color(0xFFEAF4FF),
                                fontSize: 14,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.57,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(color: whiteColor),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => const Divider(
                color: whiteColor,
              ),
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    navigatePage(context, index);
                  },
                  leading: SvgPicture.asset(drawerItems[index]['icon']!),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    drawerItems[index]['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: SvgPicture.asset(KImages.logout),
              onTap: () async {
                await showModalBottomSheet(
                  backgroundColor: transparent,
                  context: context,
                  useSafeArea: true,
                  builder: (context) => CustomPaint(
                    size: Size(size.width, 400),
                    painter: CustomCurveShape(),
                    willChange: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      height: Utils.vSize(232.0),
                      child: Column(
                        children: [
                          const CustomText(
                            text: 'LOGOUT',
                            fontWeight: FontWeight.w700,
                            color: redColor,
                            fontSize: 24.0,
                          ),
                          Container(
                            height: 2.0,
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            color: greyColor.withOpacity(0.1),
                          ),
                          const CustomText(
                            text: 'Are you sure you want to Logout?',
                            fontWeight: FontWeight.w500,
                            color: blackColor,
                            fontSize: 18.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              PrimaryButton(
                                text: 'Cancel',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                bgColor: primaryColor.withOpacity(0.4),
                                textColor: primaryColor,
                                fontSize: 16.0,
                                minimumSize:
                                    Size(Utils.hSize(150.0), Utils.vSize(40.0)),
                                maximumSize:
                                    Size(Utils.hSize(150.0), Utils.vSize(40.0)),
                              ),
                              PrimaryButton(
                                text: 'Logout',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Logout'),
                                        content: const Text(
                                            'Are you sure you want to log out?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Utils.logoutFunction(context);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Logout'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                bgColor: redColor,
                                textColor: whiteColor,
                                fontSize: 16.0,
                                minimumSize:
                                    Size(Utils.hSize(150.0), Utils.vSize(40.0)),
                                maximumSize:
                                    Size(Utils.hSize(150.0), Utils.vSize(40.0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigatePage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.popAndPushNamed(context, RouteNames.clientCategoryScreen);
        break;
      case 1:
        Navigator.popAndPushNamed(context, RouteNames.senttingsScreen);
        break;
      case 2:
        Navigator.popAndPushNamed(context, RouteNames.learningScreen);
        break;
      default:
        break;
    }
  }
}

List<Map<String, String>> drawerItems = [
  {
    "name": "All Category",
    "icon": KImages.drawerCategory,
  },
  {
    "name": "Edit Profile",
    "icon": KImages.editProfile,
  },
  {
    "name": "Learning",
    "icon": KImages.booking,
  },
  {
    "name": "Ticket Support",
    "icon": KImages.supportIcon,
  },
  {
    "name": "All Reviews",
    "icon": KImages.drawerStar,
  },
  {
    "name": "Privacy Policy",
    "icon": KImages.privacy,
  },
  {
    "name": "FAQ",
    "icon": KImages.faq,
  },
  {
    "name": "About Us",
    "icon": KImages.aboutUs,
  },
];
