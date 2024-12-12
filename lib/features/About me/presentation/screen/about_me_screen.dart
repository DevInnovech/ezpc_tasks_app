import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/About%20me/models/AboutMeModel.dart';
import 'package:ezpc_tasks_app/features/About%20me/models/review_model.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/about_section.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/aboutme_gallery.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/aboutme_header.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/aboutme_reviews.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  Future<Map<String, dynamic>?> fetchAboutMeData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final doc = await FirebaseFirestore.instance
          .collection('about_me')
          .doc(userId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint("Error fetching About Me data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                // Acción para el icono de opciones
              },
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: fetchAboutMeData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No About Me data available."));
            }

            final aboutMe = snapshot.data!;
            final reviews = (aboutMe['reviews'] as List?) ?? [];

            return Column(
              children: [
                // Header con la imagen y detalles del proveedor
                AboutMeHeader(
                  aboutMe: AboutMeModel(
                    name: aboutMe['name'] ?? '',
                    imagen: aboutMe['imagen'] ?? '',
                    description: aboutMe['description'] ?? '',
                    location: aboutMe['location'] ?? '',
                    contactNumber: aboutMe['contactNumber'] ?? '',
                    rating: aboutMe['rating']?.toDouble() ?? 0.0,
                    serviceType: aboutMe['serviceType'] ?? '',
                    gallery: List<String>.from(aboutMe['gallery'] ?? []),
                    reviews: reviews
                        .map((review) => ReviewModel.fromMap(review))
                        .toList(),
                  ),
                ),

                // TabBar debajo del header
                const TabBar(
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryColor,
                  indicatorWeight: 6,
                  tabs: [
                    Tab(text: "About"),
                    Tab(text: "Gallery"),
                    Tab(text: "Review"),
                  ],
                ),

                // Contenido de cada pestaña
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AboutSection(
                            descripcion: aboutMe['description'] ?? '',
                            providerName: aboutMe['name'] ?? '',
                            providerTitle: aboutMe['serviceType'] ?? '',
                            imagePath: aboutMe['imagen'] ?? '',
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AboutMeGallery(
                            images: List<String>.from(aboutMe['gallery'] ?? []),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AboutMeReviews(
                            reviews: reviews
                                .map((review) => ReviewModel.fromMap(review))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PrimaryButton(
            text: "Book Now",
            onPressed: () {
              // Acción para reservar
            },
          ),
        ),
      ),
    );
  }
}
