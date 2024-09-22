import 'package:ezpc_tasks_app/features/home/data/client_services_controler.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/remote_image.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientCategoryScreen extends ConsumerWidget {
  const ClientCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el estado del controlador del home
    final homeControllerState = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: "All Categories"),
      body: _buildBody(context, ref, homeControllerState),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, HomeControllerState state) {
    // Manejamos los diferentes estados manualmente
    if (state is HomeControllerLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is HomeControllerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () {
                // Refrescamos los datos
                ref.read(homeControllerProvider.notifier).loadHomeData();
              },
              icon: const Icon(Icons.refresh_outlined),
            ),
          ],
        ),
      );
    } else if (state is HomeControllerLoaded) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: state.homeModel.categories.length,
        itemBuilder: (context, index) {
          return ClientCategoryItem(item: state.homeModel.categories[index]);
        },
      );
    } else {
      return const SizedBox(); // Caso por defecto para manejar un estado inesperado
    }
  }
}

class ClientCategoryItem extends StatelessWidget {
  const ClientCategoryItem({super.key, required this.item});

  final Category item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegación a la pantalla de servicios de categoría
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
            Container(
              width: 38.w,
              height: 38.h,
              padding: const EdgeInsets.all(7),
              decoration: const ShapeDecoration(
                color: Color(0xFFEAF4FF),
                shape: OvalBorder(),
              ),
              child: CustomImage(
                path: item.pathimage != null
                    ? item.pathimage!
                    : KImages
                        .booking, // Usamos el operador ternario para manejar el caso en que `pathimage` sea null
              ),
            ),
            Utils.verticalSpace(8),
            Text(
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
          ],
        ),
      ),
    );
  }
}
