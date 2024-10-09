import 'package:ezpc_tasks_app/features/home/models/add_model.dart';
import 'package:ezpc_tasks_app/features/home/models/client_home_controller.dart';
import 'package:ezpc_tasks_app/features/home/models/counters_model.dart';
import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/home/models/service_area.dart';
import 'package:ezpc_tasks_app/features/home/models/service_item.dart';
import 'package:ezpc_tasks_app/features/home/models/service_section.dart';
import 'package:ezpc_tasks_app/features/home/models/slider_model.dart';
import 'package:ezpc_tasks_app/features/lista_de_provedores.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definimos los diferentes estados que puede tener el HomeController
class HomeControllerState {
  const HomeControllerState();
}

class HomeControllerLoading extends HomeControllerState {}

class HomeControllerLoaded extends HomeControllerState {
  final HomeModel homeModel;
  HomeControllerLoaded(this.homeModel);
}

class HomeControllerError extends HomeControllerState {
  final String message;
  HomeControllerError(this.message);
}

// Creamos el HomeControllerNotifier para manejar los estados
class HomeControllerNotifier extends StateNotifier<HomeControllerState> {
  final List<ProviderModel> providers;

  HomeControllerNotifier(this.providers) : super(HomeControllerLoading());

  get categories => null;

  Future<void> loadHomeData() async {
    try {
      // Simula la carga de datos con un retardo
      await Future.delayed(const Duration(seconds: 1));

      // Cargamos los datos del home usando los proveedores
      final homeModel = await fetchHomeData();

      state = HomeControllerLoaded(homeModel);
    } catch (e) {
      state = HomeControllerError(e.toString());
    }
  }

  Future<HomeModel> fetchHomeData() async {
    // Simula una lista de categorías
    final categories = [
      Category(
        id: '1',
        name: 'Category 1',
        subCategories: [
          SubCategory(id: '1', name: 'SubCategory 1'),
          SubCategory(id: '2', name: 'SubCategory 2'),
        ],
      ),
      Category(
        id: '2',
        name: 'Category 2',
        subCategories: [
          SubCategory(id: '3', name: 'SubCategory 3'),
          SubCategory(id: '4', name: 'SubCategory 4'),
        ],
      ),
    ];

    final sliders = [
      const SliderModel(
          id: 1,
          title: "",
          image: KImages.offer,
          status: 1,
          serial: 12,
          createdAt: '',
          updatedAt: ''),
      const SliderModel(
          id: 2,
          title: "",
          image: KImages.offer,
          status: 2,
          serial: 22,
          createdAt: '',
          updatedAt: ''),
    ];

    final serviceAreas = [
      const ServiceArea(id: 1, name: "Service Area 1", slug: '1'),
      const ServiceArea(id: 2, name: "Service Area 2", slug: '2'),
    ];

    // Asignamos los proveedores a los servicios destacados
    final featuredServices = [
      ServiceItem(
        id: 1,
        name: "Featured Service 1",
        slug: "featured-service-1",
        image: KImages.s01,
        price: 100.0,
        categoryId: categories[0],
        providerId: providers[0].id,
        makeFeatured: 1,
        isBanned: 0,
        details: "This is a featured service by John Doe",
        status: 1,
        createdAt: "2024-01-01",
        approveByAdmin: 1,
        averageRating: "5",
        totalReview: 10,
        totalOrder: 5,
        category: categories[0],
        provider: providers[0], // John Doe
      ),
      ServiceItem(
        id: 2,
        name: "Featured Service 2",
        slug: "featured-service-2",
        image: KImages.s01,
        price: 120.0,
        categoryId: categories[1],
        providerId: providers[1].id,
        makeFeatured: 1,
        isBanned: 0,
        details: "This is a featured service by Jane Smith",
        status: 1,
        createdAt: "2024-01-01",
        approveByAdmin: 1,
        averageRating: "4.5",
        totalReview: 10,
        totalOrder: 5,
        category: categories[1],
        provider: providers[1], // Jane Smith
      ),
      ServiceItem(
        id: 3,
        name: "Featured Service 3",
        slug: "featured-service-3",
        image: KImages.s01,
        price: 150.0,
        categoryId: categories[2],
        providerId: providers[2].id,
        makeFeatured: 1,
        isBanned: 0,
        details: "This is a featured service by Michael Johnson",
        status: 1,
        createdAt: "2024-01-01",
        approveByAdmin: 1,
        averageRating: "4.8",
        totalReview: 12,
        totalOrder: 8,
        category: categories[2],
        provider: providers[2], // Michael Johnson
      ),
      ServiceItem(
        id: 4,
        name: "Featured Service 4",
        slug: "featured-service-4",
        image: KImages.s01,
        price: 130.0,
        categoryId: categories[3],
        providerId: providers[3].id,
        makeFeatured: 1,
        isBanned: 0,
        details: "This is a featured service by Emily Clark",
        status: 1,
        createdAt: "2024-01-01",
        approveByAdmin: 1,
        averageRating: "4.7",
        totalReview: 9,
        totalOrder: 7,
        category: categories[3],
        provider: providers[3], // Emily Clark
      ),
    ];

    final counters = [
      const CounterModel(
          id: 1,
          title: "Completed",
          number: "100",
          icon: "https://via.placeholder.com/50x50",
          status: 1),
      const CounterModel(
          id: 2,
          title: "In Progress",
          number: "50",
          icon: "https://via.placeholder.com/50x50",
          status: 2),
    ];

    const adBanner = AddBannerModel(
      banner: "1",
      link: 'https://via.placeholder.com/600x100',
    );

    final homeModel = HomeModel(
      searchCategories: categories,
      sliders: sliders,
      serviceAreas: serviceAreas,
      categorySection: const ServiceSection(
          visibility: true, title: "Categories", description: "categories"),
      categories: categories,
      counterBgImage: "https://via.placeholder.com/600x200",
      featuredServices: featuredServices,
      adBanner: adBanner,
      coundownVisibility: true,
      counters: counters,
      popularServiceSection: const ServiceSection(
          visibility: true, title: "Popular Services", description: "popular"),
      featureServiceSection: const ServiceSection(
          visibility: true, title: "Feature Services", description: "feature"),
      popularServices: featuredServices,
    );

    return homeModel;
  }
}

// Proveedor para HomeControllerNotifier que obtiene los proveedores de la lista
final homeControllerProvider = FutureProvider.autoDispose((ref) async {
  final providers = await ref.watch(providerListProvider.future);
  final homeControllerNotifier = HomeControllerNotifier(providers);
  await homeControllerNotifier.loadHomeData();
  return homeControllerNotifier.state;
});
