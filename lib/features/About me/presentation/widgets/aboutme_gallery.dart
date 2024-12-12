import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';

class AboutMeGallery extends StatelessWidget {
  final List<String> images;

  const AboutMeGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final displayedImages = images.length > 4 ? images.sublist(0, 4) : images;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Gallery (${images.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (images.length > 4)
                GestureDetector(
                  onTap: () {
                    // Acción para ver todas las imágenes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullGalleryScreen(images: images),
                      ),
                    );
                  },
                  child: const Text(
                    "View all",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.2,
          ),
          itemCount: displayedImages.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CustomImage(
                path: displayedImages[index],
                fit: BoxFit.cover,
                height: 150, // Altura de las imágenes en la galería
                width: double.infinity, url: null,
              ),
            );
          },
        ),
      ],
    );
  }
}

class FullGalleryScreen extends StatelessWidget {
  final List<String> images;

  const FullGalleryScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Full Gallery"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.2,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CustomImage(
              path: images[index],
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
              url: null,
            ),
          );
        },
      ),
    );
  }
}
