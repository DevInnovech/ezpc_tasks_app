import 'package:ezpc_tasks_app/features/services/data/services_repository.dart';
import 'package:ezpc_tasks_app/features/services/models/services_model.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/details_custom_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class ServiceBottomNavBar extends ConsumerWidget {
  const ServiceBottomNavBar({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceProvider);

    if (serviceState.isLoading) {
      return const SizedBox.shrink();
    }

    // Find the service by id
    final service = serviceState.services.firstWhere(
      (service) => service.id == id,
      orElse: () => const ServiceProductStateModel(
        id: '',
        name: '',
        slug: '',
        price: '',
        categoryId: '',
        subCategoryId: '',
        details: '',
        image: '',
        packageFeature: [],
        benefits: [],
        whatYouWillProvide: [],
        status: '',
      ), // Provide a default empty instance
    );

    if (service.id.isEmpty) {
      return const SizedBox
          .shrink(); // Return an empty widget if service is not found
    }

    return Container(
      width: double.infinity,
      height: Utils.vSize(110.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 40,
            offset: Offset(0, 3),
            spreadRadius: 0,
          )
        ],
      ),
      child: CustomPaint(
        painter: DetailsCustomShape(),
        child: Padding(
          padding: Utils.symmetric(v: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.center,
                child: CustomImage(path: KImages.lineIcon, color: whiteColor),
              ),
              Utils.verticalSpace(20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrimaryButton(
                    text: 'Delete',
                    bgColor: redColor,
                    onPressed: () {
                      // Implement the delete functionality
                      // You can call a method from the notifier to handle this
                      //ref.read(serviceProvider.notifier).deleteService(id);
                    },
                    minimumSize: Size(Utils.hSize(160.0), Utils.vSize(52.0)),
                  ),
                  PrimaryButton(
                    text: 'Edit Service',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      'route_to_edit_service_screen', // Update with actual route
                      arguments: id,
                    ),
                    bgColor: primaryColor,
                    minimumSize: Size(Utils.hSize(160.0), Utils.vSize(52.0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
