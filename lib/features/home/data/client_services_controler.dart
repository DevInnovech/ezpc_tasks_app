import 'package:ezpc_tasks_app/features/home/models/add_model.dart';
import 'package:ezpc_tasks_app/features/home/models/client_home_controller.dart';
import 'package:ezpc_tasks_app/features/home/models/counters_model.dart';
import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/home/models/service_area.dart';
import 'package:ezpc_tasks_app/features/home/models/service_item.dart';
import 'package:ezpc_tasks_app/features/home/models/service_section.dart';
import 'package:ezpc_tasks_app/features/home/models/slider_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  HomeControllerNotifier() : super(HomeControllerLoading());

  get categories => null;

  Future<void> loadHomeData() async {
    try {
      // Simula la carga de datos con un retardo
      await Future.delayed(const Duration(seconds: 2));

      // Aquí deberías cargar tus datos reales en lugar del modelo simulado
      final homeModel = await fetchHomeData();

      state = HomeControllerLoaded(homeModel);
    } catch (e) {
      state = HomeControllerError(e.toString());
    }
  }

  Future<HomeModel> fetchHomeData() async {
    // Simulamos algunos datos para cada parte del HomeModel
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

    final featuredServices = [
      ServiceItem(
        id: 1,
        name: "Featured Service 1",
        slug: "featured-service-1",
        image: KImages.s01,
        price: 100.0,
        categoryId: 1,
        providerId: 1,
        makeFeatured: 1,
        isBanned: 0,
        details: "This is a featured service",
        status: 1,
        createdAt: "2024-01-01",
        approveByAdmin: 1,
        averageRating: "5",
        totalReview: 10,
        totalOrder: 5,
        category: categories[0],
        provider: const ProviderModel(
            id: 1,
            name: "Provider 1",
            email: '',
            phone: '',
            image: '',
            createdAt: '',
            userName: ''),
      ),
      ServiceItem(
        id: 1,
        name: "Featured Service 12",
        slug: "featured-service-2",
        image: KImages.s01,
        price: 100.0,
        categoryId: 1,
        providerId: 1,
        makeFeatured: 1,
        isBanned: 0,
        details: "This is a featured service",
        status: 1,
        createdAt: "2024-01-01",
        approveByAdmin: 1,
        averageRating: "4.5",
        totalReview: 10,
        totalOrder: 5,
        category: categories[0],
        provider: const ProviderModel(
            id: 1,
            name: "Provider 2",
            email: '',
            phone: '',
            image: KImages.pp,
            createdAt: '',
            userName: ''),
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

// Proveedor para HomeControllerNotifier
final homeControllerProvider =
    StateNotifierProvider<HomeControllerNotifier, HomeControllerState>(
        (ref) => HomeControllerNotifier());
