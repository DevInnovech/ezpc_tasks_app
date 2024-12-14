import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/home/data/client_services_controler.dart';
import 'package:ezpc_tasks_app/features/home/models/client_home_controller.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_home_header.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_single_category_view.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_title_and_navigator.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/Referall_poup.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referall_dialog.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_filter.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  @override
  void initState() {
    super.initState();
    checkReferralStatus();
  }

  Future<void> checkReferralStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final referralPartner = data['referralPartner'] ?? '';

      // Si el usuario no tiene referralPartner y no ha indicado 'no_referral'
      // entonces mostramos el diálogo.
      // Si referralPartner == 'no_referral', no mostramos nada.
      if (referralPartner.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const ReferralDialog(),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeControllerState = ref.watch(homeControllerProvider);

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

        // Banner Carousel

        Utils.verticalSpace(24),

        // Manejo adecuado del AsyncValue para homeControllerState
        homeControllerState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (state) {
            if (state is HomeControllerLoaded) {
              return HomeLoadedData(data: state.homeModel);
            } else {
              return Container(
                child: const Text("No Enable"),
              ); // Maneja cualquier otro estado inesperado
            }
          },
        ),
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
            //  mira la data de los sliders
            /*ClientSliderSection(sliders: data.sliders),*/
            // cristians
            CarouselSlider(
              items: [
                // Reemplaza esto con la lógica para obtener las imágenes del banner
                Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: const DecorationImage(
                      image: AssetImage(
                          'assets/images/offer.png'), // Reemplaza con tu imagen por defecto
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                // Añade más contenedores con imágenes aquí si es necesario
              ],
              options: CarouselOptions(
                height: 180.h,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Utils.verticalSpace(24),
            ClientTitleAndNavigator(
              title: data.categorySection.title,
              press: () {
                Navigator.pushNamed(context, RouteNames.clientCategoryScreen);
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
                  url: null,
                ),
              ),
            ),
            ClientTitleAndNavigator(
              title: data.featureServiceSection.title,
              press: () {
                //error corregir mas tarde
                Navigator.pushNamed(context, RouteNames.serviceScreen,
                    arguments: {
                      'title': 'Featured Services',
                      'slug': 'feature'
                    });
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

            // Imagen Promocional
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ReferralPopup(
                    referralCode:
                        "referral01", // Código de referido del usuario
                  ),
                );
              },
              child: Container(
                height: 160.h,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const CustomImage(
                    path: KImages
                        .Referalflayer, // Reemplaza con tu imagen promocional
                    fit: BoxFit.contain,
                    url: null,
                  ),
                ),
              ),
            ),
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

            // ... (resto del código) ...
          ],
        ),
      ),
    );
  }
}

// Asumiendo que ClientCategoryItem recibe un objeto 'item' de tipo Category
class ClientCategoryItem extends StatelessWidget {
  const ClientCategoryItem({super.key, required this.item});
  final Category item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navegar a la pantalla de detalles de la categoría
        Navigator.pushNamed(
          context,
          RouteNames.clientCategoryScreen,
          arguments: {
            'category': item, // Pasa la información de la categoría
          },
        );
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: item.pathimage != null
                    ? NetworkImage(item.pathimage!)
                    : const AssetImage(
                        'assets/images/default_category.jpg', // Imagen por defecto
                      ) as ImageProvider,
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
