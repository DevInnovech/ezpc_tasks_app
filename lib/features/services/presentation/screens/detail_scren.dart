import 'package:ezpc_tasks_app/features/services/data/sevices_repository.dart';
import 'package:ezpc_tasks_app/features/services/models/services_model.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/dwtail_information.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/service_botton_bar.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_sliver_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/fetch_error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  const ServiceDetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceProvider);

    // Find the service by id
    final ServiceProductStateModel? service = serviceState.services.firstWhere(
      (service) => service.id == id,
      // Return null if not found
    );

    return Scaffold(
      body: serviceState.isLoading
          ? const LoadingWidget()
          : serviceState.error != null
              ? FetchErrorText(text: serviceState.error!)
              : service != null
                  ? LoadedServiceDetailWidget(service: service)
                  : const FetchErrorText(text: 'Service not found'),
      bottomNavigationBar: service != null
          ? ServiceBottomNavBar(id: service.id)
          : const SizedBox(),
    );
  }
}

class LoadedServiceDetailWidget extends StatelessWidget {
  const LoadedServiceDetailWidget({super.key, required this.service});

  final ServiceProductStateModel service;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CustomSliverAppBar(title: 'Service Details'),
        SliverPadding(
          padding: Utils.symmetric(),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildImageTitle(service),
              _buildPackageInfo(context, service),
              DetailInformation(service: service),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildImageTitle(ServiceProductStateModel service) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: Utils.vSize(200.0),
          margin: Utils.only(bottom: 16.0),
          child: ClipRRect(
            borderRadius: Utils.borderRadius(),
            child: CustomImage(
              width: double.infinity,
              height: Utils.vSize(200.0),
              fit: BoxFit.cover,
              path: service.image,
            ),
          ),
        ),
        CustomText(
          text: service.name,
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
        )
      ],
    );
  }

  Widget _buildPackageInfo(
      BuildContext context, ServiceProductStateModel service) {
    return Container(
      padding: Utils.only(bottom: 20.0),
      margin: Utils.symmetric(h: 0.0, v: 20.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Utils.radius(6.0)),
          topRight: Radius.circular(Utils.radius(6.0)),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: Utils.symmetric(h: 16.0, v: 10.0),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Utils.radius(6.0)),
                topRight: Radius.circular(Utils.radius(6.0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: 'Our Packages',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                  color: whiteColor,
                ),
                CustomText(
                  text: '\$${service.price}',
                  fontWeight: FontWeight.w600,
                  fontSize: 22.0,
                  color: whiteColor,
                ),
              ],
            ),
          ),
          ...List.generate(
            service.packageFeature.length,
            (index) => Padding(
              padding: Utils.symmetric().copyWith(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: Utils.only(top: 2.0),
                    child: const Icon(
                      Icons.check_circle,
                      color: primaryColor,
                      size: 18.0,
                    ),
                  ),
                  Utils.horizontalSpace(4.0),
                  Flexible(
                    fit: FlexFit.loose,
                    child: CustomText(
                      text: service.packageFeature[index],
                      color: grayColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
