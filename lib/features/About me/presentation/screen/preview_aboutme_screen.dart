import 'package:ezpc_tasks_app/features/About%20me/data/aboutme_provider.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/about_section.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/aboutme_gallery.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/aboutme_header.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/widgets/aboutme_reviews.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewAboutMeScreen extends ConsumerWidget {
  const PreviewAboutMeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutMeData = ref.watch(aboutMeProvider);

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
        body: aboutMeData.when(
          data: (aboutMe) => Column(
            children: [
              // Header con la imagen y detalles del proveedor
              AboutMeHeader(aboutMe: aboutMe),

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
                          descripcion: aboutMe.description,
                          providerName: aboutMe.name,
                          providerTitle: aboutMe.serviceType,
                          imagePath: aboutMe.imagen,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AboutMeGallery(images: aboutMe.gallery),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AboutMeReviews(reviews: aboutMe.reviews),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}
