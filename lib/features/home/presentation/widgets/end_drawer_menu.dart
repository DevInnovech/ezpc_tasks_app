import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';

class EndDrawerMenu extends StatefulWidget {
  const EndDrawerMenu({super.key});

  @override
  _EndDrawerMenuState createState() => _EndDrawerMenuState();
}

class _EndDrawerMenuState extends State<EndDrawerMenu> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user is logged in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      } else {
        print("User document does not exist");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: blackColor,
        elevation: 0.0,
        child: ListView(
          children: [
            Padding(
              padding: Utils.symmetric(h: 10.0, v: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del usuario
                  Container(
                    height: Utils.vSize(50.0),
                    width: Utils.vSize(50.0),
                    margin: Utils.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: Utils.borderRadius(r: 6.0),
                      child: userData != null &&
                              userData!['profileImageUrl'] != null
                          ? Image.network(
                              userData![
                                  'profileImageUrl'], // URL de la imagen desde Firestore.
                              fit: BoxFit.cover,
                              width: Utils.vSize(50.0),
                              height: Utils.vSize(50.0),
                              errorBuilder: (context, error, stackTrace) {
                                print("Error loading profile image: $error");
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                            )
                          : Image.asset(
                              KImages.pp, // Imagen por defecto si no hay URL.
                              fit: BoxFit.cover,
                              width: Utils.vSize(50.0),
                              height: Utils.vSize(50.0),
                            ),
                    ),
                  ),
                  // Nombre y correo electrónico
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: userData != null
                            ? "${userData!['name']} ${userData!['lastName']}"
                            : 'Loading...',
                        color: whiteColor,
                      ),
                      CustomText(
                        text: userData?['email'] ?? 'Loading...',
                        fontSize: 12.0,
                        color: whiteColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DrawerItem(
              icon: KImages.di01,
              title: 'Settings',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.senttingsScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di01,
              title: 'Appointment Schedule',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.scheduleScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di02,
              title: 'Profile',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.profileScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di04,
              title: 'Review',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.performanceScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di04,
              title: 'Chats',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.chatListScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isBorder = true,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool isBorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.only(left: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: Utils.symmetric(h: 0.0, v: 12.0),
          margin: Utils.only(bottom: 6.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isBorder ? whiteColor.withOpacity(0.2) : transparent,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImage(
                path: icon,
                url: null,
              ),
              Utils.horizontalSpace(12.0),
              CustomText(
                text: title,
                color: whiteColor,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
