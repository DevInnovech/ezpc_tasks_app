import 'package:ezpc_tasks_app/features/services/data/sevices_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/services_appbar.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/services_component.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/fetch_error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';

class ServiceScreen extends ConsumerWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar el estado de los servicios usando Riverpod
    final serviceState = ref.watch(serviceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        centerTitle: true,
        title: const Text(
          'Task',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: serviceState.isLoading
          ? const LoadingWidget()
          : serviceState.error != null
              ? FetchErrorText(text: serviceState.error!)
              : Column(
                  children: [
                    const ServiceAppBar(), // Static widget for adding a new service
                    Expanded(
                      child: serviceState.services.isNotEmpty
                          ? ListView.builder(
                              itemCount: serviceState.services.length,
                              itemBuilder: (context, index) {
                                final service = serviceState.services[index];
                                return ServiceComponent(service: service);
                              },
                            )
                          : _buildEmptyState(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImage(
            path: KImages.emptyBookingImage,
          ),
          SizedBox(height: 20.0),
          CustomText(
            text: 'No Services Available',
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
