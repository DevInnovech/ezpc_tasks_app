import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/ProviderOrderDetailsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticar al usuario
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';

class ClientHomeHeader extends ConsumerWidget {
  const ClientHomeHeader({super.key});

  // Función para obtener un saludo según la hora actual
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 18) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el ID del usuario logueado
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Si no hay usuario logueado, mostrar un mensaje
    if (currentUserId == null) {
      return Center(
        child: Text(
          'No user logged in.',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      );
    }

    return SizedBox(
      height: 178.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            color: primaryColor,
            height: 178.h,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId) // Usar el userID dinámico
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User not found.'));
                } else {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final String nombre = userData['name'] ?? 'N/A';
                  final String apellido = userData['lastName'] ?? 'N/A';
                  final String rol = userData['role'] ?? 'Client';
                  final String? profileImageUrl = userData['profileImageUrl'];
                  final String greeting = getGreeting();

                  return Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 0.50,
                              color: Color(0xFFEAF4FF),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Acción para editar el perfil
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty
                                ? CustomImage(
                                    path: profileImageUrl,
                                    fit: BoxFit.cover,
                                    url: null,
                                  )
                                : const CustomImage(
                                    path: KImages.pp, // Imagen predeterminada
                                    fit: BoxFit.cover,
                                    url: null,
                                  ),
                          ),
                        ),
                      ),
                      Utils.horizontalSpace(10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                color: Color(0xFFEAF4FF),
                                fontSize: 14,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.57,
                              ),
                            ),
                            Text(
                              '$nombre $apellido',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Role: $rol",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Utils.horizontalSpace(10),
                      GestureDetector(
                        onTap: () => showTechnicalSupportOptions(context),
                        child: Container(
                          height: Utils.vSize(50.0),
                          width: Utils.vSize(50.0),
                          margin: Utils.only(right: 10.0),
                          child: ClipRRect(
                            borderRadius: Utils.borderRadius(r: 6.0),
                            child: const CustomImage(
                              path: KImages.supportIcon,
                              fit: BoxFit.contain,
                              url: null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Positioned(
            bottom: -25,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: double.infinity,
                height: 52.h,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 40,
                      offset: Offset(0, 2),
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: TextField(
                  onTap: () {
                    // Aquí puedes agregar lógica adicional, como abrir una nueva pantalla o expandir el TextField.
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Services or Providers',
                    hintStyle: const TextStyle(
                      color: Color(0xFF686873),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showTechnicalSupportOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Message Option
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    Navigator.pop(context);
                    openSupportChat(context);
                  },
                ),
                const Text('Message'),
              ],
            ),
            // Call Option
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {
                    // Open phone dialer
                    Navigator.pop(context);
                    makePhoneCall(
                        'tel:+1234567890'); // Replace with support number
                  },
                ),
                const Text('Call'),
              ],
            ),
            // Email Option
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    // Open email client
                    Navigator.pop(context);
                    sendEmail(
                        'support@example.com'); // Replace with support email
                  },
                ),
                const Text('Email'),
              ],
            ),
          ],
        ),
      );
    },
  );
}
