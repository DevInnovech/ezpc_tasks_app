import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/ProviderOrderDetailsScreen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ServicesByProviderfilter.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ServicesByServiceScreen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticar al usuario
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/features/home/data/filter_controller.dart';
import 'dart:async'; // Import necesario para usar Timer

class ClientHomeHeader extends ConsumerStatefulWidget {
  const ClientHomeHeader({super.key});

  @override
  ConsumerState<ClientHomeHeader> createState() => _ClientHomeHeaderState();
}

class _ClientHomeHeaderState extends ConsumerState<ClientHomeHeader> {
  Timer? _debounce;
  Map<String, dynamic>? selectedFilters;
  @override
  void dispose() {
    _debounce?.cancel(); // Cancela el debounce al destruir el widget
    super.dispose();
  }

// Manejo del cambio en el campo de texto con debounce
  void _onSearchChanged(String query, Map<String, dynamic>? selectedFilters) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        ref
            .read(searchResultsProvider.notifier)
            .performSearch(query, selectedFilters);
      } else {
        ref.read(searchResultsProvider.notifier).clearResults();
      }
    });
  }

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
  Widget build(BuildContext context) {
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

    return Column(
      mainAxisSize: MainAxisSize.min, // Ajuste dinámico
      children: [
        // Contenedor del header principal
        Container(
          color: primaryColor,
          height: 178.h,
          child: Stack(
            alignment: Alignment.center, // Alinear elementos verticalmente
            children: [
              // Información del usuario obtenida dinámicamente
              Positioned(
                top: 50.h, // Posicionar en la parte superior
                left: 20,
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId) // ID del usuario dinámico
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text('User not found.');
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final String nombre = userData['name'] ?? 'N/A';
                    final String apellido = userData['lastName'] ?? 'N/A';
                    final String rol = userData['role'] ?? 'Client';
                    final String greeting = getGreeting();

                    return Row(
                      children: [
                        // Imagen del perfil
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const CustomImage(
                              path: KImages.pp, // Imagen predeterminada
                              fit: BoxFit.cover,
                              url: null,
                            ),
                          ),
                        ),
                        Utils.horizontalSpace(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Texto dinámico del saludo
                            Text(
                              greeting,
                              style: const TextStyle(
                                color: Color(0xFFEAF4FF),
                                fontSize: 14,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Nombre y apellido del usuario
                            Text(
                              '$nombre $apellido',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Rol del usuario
                            Text(
                              "Role: $rol",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Barra de búsqueda centrada
              Positioned(
                bottom: -5.h, // Posicionar más cerca del centro
                left: 20,
                right: 20,
                child: Container(
                  height: 52.h,
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
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (query) {
                      _onSearchChanged(query, selectedFilters);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Services or Providers',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          ref
                              .read(searchResultsProvider.notifier)
                              .clearResults();
                        },
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Previsualizador de resultados
        Consumer(
          builder: (context, ref, _) {
            final searchResults = ref.watch(searchResultsProvider);

            if (searchResults.isEmpty) {
              return const SizedBox(); // Ocultar resultados si no hay búsqueda
            }

            // Filtrar servicios/tareas sin nombre
            final filteredResults = searchResults
                .where(
                    (result) => result['name'] != null && result['name'] != '')
                .toList();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(8),
              height: 200.h, // Altura fija con scroll
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 40,
                    offset: Offset(0, 2),
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = filteredResults[index];
                    return ListTile(
                      leading: Icon(
                        result['type'] == 'provider'
                            ? Icons.person
                            : Icons.home_repair_service,
                      ),
                      title: Text(result['name']),
                      subtitle: Text(result['lastName'] ?? 'No Last Name'),
                      onTap: () {
                        if (result['type'] == 'provider') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServicesByProviderScreen(
                                providerName: result['name'],
                                providerLastName: result['lastName'] ?? 'N/A',
                                providerDocumentID: result['id'],
                              ),
                            ),
                          );
                        }
                        if (result['type'] == 'service') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServicesByServiceScreen(
                                serviceName: result['name'],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
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
