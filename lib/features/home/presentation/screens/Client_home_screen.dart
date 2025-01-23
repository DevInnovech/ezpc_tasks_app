import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/home/data/client_services_controler.dart';
import 'package:ezpc_tasks_app/features/home/data/filter_controller.dart';
import 'package:ezpc_tasks_app/features/home/data/popular_services_controller.dart';
import 'package:ezpc_tasks_app/features/home/data/services_controler.dart';
import 'package:ezpc_tasks_app/features/home/models/client_home_controller.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/pop_services.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/see_all_featured.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ServicesByProviderfilter.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/ServicesByServiceScreen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_home_header.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_title_and_navigator.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/popular_service_card.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/scrool_text.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/Referall_poup.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referall_dialog.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_filter.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/see_all_popular.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  Timer? _debounce;
  Map<String, dynamic> selectedFilter = {};
  @override
  void initState() {
    super.initState();
    checkReferralStatus();
    ref.read(servicesControllerProvider.notifier).loadAllServices();
    ref.read(popularServicesProvider.notifier).loadPopularServices();
    ref.read(providerControllerProvider.notifier).loadProviders();
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
  void dispose() {
    _debounce?.cancel(); // Cancela el debounce al destruir el widget
    super.dispose();
  }

// Manejo del cambio en el campo de texto con debounce
  void _onSearchChanged(String query, Map<String, dynamic>? selectedFilters) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        ref
            .read(searchResultsProvider.notifier)
            .performSearch(query, selectedFilters);
      } else {
        ref.read(searchResultsProvider.notifier).clearResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeControllerState = ref.watch(homeControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          const Column(
            children: [
              // Header fijo
              ClientHomeHeader(),

              // Espacio adicional debajo del header para que el FloatingSearchBar tenga espacio
              SizedBox(height: 10), // Ajusta según el diseño necesario
            ],
          ),

          // FloatingSearchBar ajustado
          Positioned(
            top: MediaQuery.of(context).padding.top + 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Espaciador
                Utils.verticalSpace(20),

                GenericFilterWidget(
                  onFilterSelected: (selectedFilters) {
                    if (selectedFilters != null) {
                      selectedFilter = selectedFilters;
                      print('Filtros seleccionados: $selectedFilters');
                    } else {
                      print('No se seleccionaron filtros');
                    }
                  },
                ),
                // Manejo de estado del controlador principal
                Expanded(
                  child: homeControllerState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                    data: (state) {
                      if (state is HomeControllerLoaded) {
                        return HomeLoadedData(data: state.homeModel, ref: ref);
                      } else {
                        return const Center(child: Text('No data available'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Contenido debajo de la barra de búsqueda
          Positioned.fill(
            top: 100,
            child: FloatingSearchBar(
              hint: 'Search Tasks or Providers',
              backdropColor: Colors.transparent, // Quitar el fondo opacado

              scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
              transitionDuration: const Duration(milliseconds: 300),
              transitionCurve: Curves.easeInOut,
              physics: const BouncingScrollPhysics(),
              debounceDelay: const Duration(milliseconds: 500),
              automaticallyImplyBackButton: false,
              onQueryChanged: (query) {
                // Actualiza los resultados de la búsqueda
                _onSearchChanged(
                    query, selectedFilter); // Llama al método con debounce
              },
              builder: (context, transition) {
                final searchResults = ref.watch(searchResultsProvider);

                if (searchResults.isEmpty) {
                  return Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 40, color: Colors.grey[600]),
                          SizedBox(height: 10),
                          Text(
                            'No results found.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Procesa los resultados y añade el tipo basado en la presencia de `userID`
                /*final processedResults = searchResults.map((result) {
                  print({'$result'});
                  // Identificar si es provider o service basándonos en la existencia del campo `userID`
                  final isProvider = result.containsKey('type') &&
                      result['type'] == 'provider';

                  if (isProvider) {
                    // Para providers, devolvemos el `name`, `lastName`, y otros datos relevantes
                    return {
                      'name': result['name'] ?? 'No Name',
                      'lastName': result['lastName'] ?? 'No Last Name',
                      'type': 'provider',
                      'id': result['id'] ?? '',
                    };
                  } else {
                    // Para services, extraemos el primer `taskName` de `selectedTasks`
                    final selectedTasks =
                        result['selectedTasks'] as Map<String, dynamic>? ?? {};
                    final taskName = selectedTasks.keys.isNotEmpty
                        ? selectedTasks.keys.first
                        : 'No Task Name';

                    return {
                      'taskName': taskName,
                      'type': 'service',
                      'id': result['id'] ?? '',
                    };
                  }
                }).toList();*/

                return Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      final isProvider = result['type'] == 'provider';

                      return ListTile(
                        leading: Icon(
                          isProvider ? Icons.person : Icons.home_repair_service,
                        ),
                        title: Text(result['name'] ?? 'N/A'),
                        subtitle: Text(result['lastName'] ?? '/a'),
                        onTap: () {
                          if (isProvider) {
                            // Navegación para provider
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServicesByProviderScreen(
                                  providerName: result['name'],
                                  providerLastName: result['lastName'] ?? 'N/A',
                                  providerDocumentID: result['id'],
                                  ordenby:
                                      selectedFilter['Lowest'] == true ? 1 : 0,
                                  rating:
                                      selectedFilter['averageRating'][0] == true
                                          ? double.tryParse(
                                              selectedFilter['averageRating'][1]
                                                  .toString())
                                          : null,
                                ),
                              ),
                            );
                          } else {
                            // Navegación para service
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServicesByServiceScreen(
                                  /*   rating: selectedFilter['averageRating'][0] ==
                                              true &&
                                          selectedFilter['averageRating'][0] !=
                                              null
                                      ? double.tryParse(
                                          selectedFilter['averageRating'][1]
                                              .toString())
                                      : null,*/
                                  ordenby:
                                      selectedFilter['Lowest'] == true ? 1 : 0,
                                  serviceName: result[
                                      'name'], // Usar taskName en la navegación
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final SimpleService service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Acción al hacer clic en el servicio
        Navigator.pushNamed(
          context,
          RouteNames.serviceDetailsScreen, // Ajusta la ruta según sea necesario
          arguments: {
            'serviceId': service.serviceId
          }, // Pasa el ID del servicio
        );
      },
      child: Container(
        width: 150, // Ancho de la tarjeta
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.home_repair_service, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ID: ${service.serviceId}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeLoadedData extends StatelessWidget {
  const HomeLoadedData({
    super.key,
    required this.data,
    required this.ref,
  });
  final HomeModel data;
  final WidgetRef ref;

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
                //aqui alam
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
              title: "Featured Services",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeaturedProvidersScreen(),
                  ),
                );
              },
            ),

            Utils.verticalSpace(16),

// Manejo de estados del controlador de servicios
            Builder(
              builder: (context) {
                final providerState = ref.watch(providerControllerProvider);

                if (providerState is ProviderControllerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (providerState is ProviderControllerError) {
                  return Center(child: Text('Error: ${providerState.message}'));
                } else if (providerState is ProviderControllerLoaded) {
                  final providers = providerState.providers;

                  // Si no hay proveedores, mostrar un mensaje
                  if (providers.isEmpty) {
                    return const Center(
                      child: Text('No featured providers available.'),
                    );
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ProviderCard(
                              provider: provider), // Usar ProviderCard
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
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
              title: "Popular Services",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PopularServicesScreen(), // Página de Popular Services
                  ),
                );
              },
            ),

            Utils.verticalSpace(16),

// Nueva lógica para Popular Services
            Builder(
              builder: (context) {
                final popularServicesState = ref.watch(popularServicesProvider);

                if (popularServicesState is PopularServicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (popularServicesState is PopularServicesError) {
                  return Center(
                      child: Text('Error: ${popularServicesState.message}'));
                } else if (popularServicesState is PopularServicesLoaded) {
                  final popularServices = popularServicesState.services;

                  if (popularServices.isEmpty) {
                    return const Center(
                      child: Text('No popular services available.'),
                    );
                  }

                  return SizedBox(
                    height: 200, // Altura del carrusel
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: popularServices.length,
                      itemBuilder: (context, index) {
                        final service = popularServices[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: PopularServiceCard(
                            rank: index + 1,
                            category: service.categoryName,
                            image: service.image,
                            serviceName: service.serviceName,
                            count: service.count,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TasksByServiceScreen(
                                    serviceName: service.serviceName,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),

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
          /*   arguments: {
            'category': item, // Pasa la información de la categoría
          },*/
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
