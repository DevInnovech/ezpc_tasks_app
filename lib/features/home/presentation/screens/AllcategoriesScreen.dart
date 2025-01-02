import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ServicesByCategory.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
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
        pathimage: doc['imageUrl'] ?? '',
        subCategories: (doc['services'] as List<dynamic>?)
                ?.map((sub) => SubCategory.fromMap(sub as Map<String, dynamic>))
                .toList() ??
            [],
        categoryId: doc['id'] ?? '',
        pathImage: null,
      );
    }).toList();
  } catch (e) {
    throw Exception("Failed to load categories: $e");
  }
});

class ClientCategoryScreen extends ConsumerWidget {
  const ClientCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: "All Categories"),
      body: asyncCategoryState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () {
                  // Refrescamos los datos
                  ref.refresh(categoryProvider);
                },
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text("No categories found."));
          }
          return _buildCategoryGrid(categories);
        },
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
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
        width: 102.w,
        height: 120.h,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesByCategoryScreen(category: item),
                  ),
                );
              },
              child: Container(
                width: 38.w,
                height: 38.h,
                padding: const EdgeInsets.all(7),
                decoration: const ShapeDecoration(
                  color: Color(0xFFEAF4FF),
                  shape: OvalBorder(),
                ),
                child: CustomImage(
                  path: null,
                  url: item.pathimage ??
                      KImages.booking, // Usamos el valor por defecto si es null
                ),
              ),
            ),
            Utils.verticalSpace(8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesByCategoryScreen(category: item),
                  ),
                );
              },
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
