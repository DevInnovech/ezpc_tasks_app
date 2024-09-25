import 'package:ezpc_tasks_app/features/home/data/client_services_controler.dart';
import 'package:ezpc_tasks_app/features/home/models/client_home_controller.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_category_screen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_home_header.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_single_category_view.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_slider_section.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_title_and_navigator.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_filter.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeControllerState = ref.watch(homeControllerProvider);

    // Inicia la carga de datos si el estado es HomeControllerLoading
    if (homeControllerState is HomeControllerLoading) {
      ref.read(homeControllerProvider.notifier).loadHomeData();
    }

    return Column(
      children: [
        const ClientHomeHeader(),
        Utils.verticalSpace(50),
        GenericFilterWidget(
          onFilterSelected: (selectedFilters) {
            if (selectedFilters != null) {
              // Aplicar los filtros seleccionados
              print('Filtros seleccionados: $selectedFilters');
            } else {
              print('No se seleccionaron filtros');
            }
          },
        ),
        if (homeControllerState is HomeControllerLoading)
          const Center(child: CircularProgressIndicator())
        else if (homeControllerState is HomeControllerLoaded)
          HomeLoadedData(data: homeControllerState.homeModel)
        else if (homeControllerState is HomeControllerError)
          Center(child: Text('Error: ${homeControllerState.message}')),
      ],
    );
  }
}

class HomeLoadedData extends StatelessWidget {
  const HomeLoadedData({
    super.key,
    required this.data,
  });
  final HomeModel data;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ClientSliderSection(sliders: data.sliders),
            Utils.verticalSpace(24),
            ClientTitleAndNavigator(
              title: data.categorySection.title,
              press: () {
                /*Navigator.pushNamed(context, RouteNames.categoryScreen);*/
              },
            ),
            Utils.verticalSpace(16),
            SizedBox(
              // height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: data.categories
                      .take(data.categories.length > 6
                          ? 6
                          : data.categories.length)
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            // en cliente category item tambien debe estar la pagina de categorias
                            child: ClientCategoryItem(item: e),
                          ))
                      .toList(),
                ),
              ),
            ),

            Container(
              height: 160.h,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const CustomImage(
                  //areglar baner osea que venga de donde debe venir
                  path: KImages.Referalflayer,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ClientTitleAndNavigator(
              title: data.featureServiceSection.title,
              press: () {
                /* Navigator.pushNamed(context, RouteNames.serviceListScreen,
                    arguments: {
                      'title': 'Feature Services',
                      'slug': 'feature'
                    });*/
              },
            ),
            Utils.verticalSpace(16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  ...List.generate(data.featuredServices.length, (index) {
                    final service = data.featuredServices[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClientSingleCategoryView(item: service),
                    );
                  })
                ],
              ),
            ),
            Utils.verticalSpace(12),
            //     contador inabilitado por el momento //
            /*   Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(data.counterBgImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // runAlignment: WrapAlignment.center,
                    // spacing: 20,
                    // runSpacing: 10,
                    children: data.counters
                        .take(
                            data.counters.length > 3 ? 3 : data.counters.length)
                        .map((e) => HomeCounter(
                              icon: e.icon,
                              total: e.number,
                              text: e.title,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
         */

            // CustomImage(path: KImages.megaSale),
            Utils.verticalSpace(24),
            ClientTitleAndNavigator(
              title: data.popularServiceSection.title,
              press: () {
                /*Navigator.pushNamed(context, RouteNames.serviceListScreen,
                    arguments: {
                      'title': 'Popular Services',
                      'slug': 'popular'
                    });*/
              },
            ),
            Utils.verticalSpace(16),

            Wrap(
              runSpacing: 24,
              spacing: 16,
              children: [
                ...List.generate(data.popularServices.length, (index) {
                  final service = data.popularServices[index];
                  return ClientSingleCategoryView(item: service);
                })
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ],
        ),
      ),
    );
  }
}
