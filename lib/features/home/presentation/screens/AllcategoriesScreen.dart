import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ServicesByCategory.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final categoryProvider = FutureProvider<List<Category>>((ref) async {
  try {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) {
      return Category(
        id: doc.id,
        name: doc['name'] ?? '',
        pathimage: doc['pathimage'],
        subCategories: [],
        pathImage: null,
        categoryId:
            doc['categoryId'] ?? '', // Maneja imágenes si están en Firestore
      );
    }).toList();
  } catch (e) {
    throw Exception("Failed to load categories: $e");
  }
});

class AllCategoryScreen extends ConsumerWidget {
  const AllCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Categories",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: asyncCategoryState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Failed to load categories:\n$error",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  ref.refresh(categoryProvider);
                },
                icon: const Icon(Icons.refresh_outlined),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text(
                "No categories found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return _buildCategoryGrid(categories);
        },
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Cambiamos a 3 por fila
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // Ajustamos la proporción
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ClientCategoryItem(item: categories[index]);
      },
    );
  }
}

class ClientCategoryItem extends StatelessWidget {
  const ClientCategoryItem({super.key, required this.item});

  final Category item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesByCategoryScreen(category: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: CustomImage(
                path: item.pathimage ?? KImages.booking,
                url: null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
