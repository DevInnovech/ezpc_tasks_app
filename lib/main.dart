import 'package:carousel_slider/carousel_slider.dart'; // Importa el paquete carousel_slider
import 'package:ezpc_tasks_app/features/services/client_services/data/PaymentKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ezpc_tasks_app/firebase_options.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_theme.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_string.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = PublishableKey;
  await Stripe.instance.applySettings();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: Ezpc()));
}

class Ezpc extends StatelessWidget {
  const Ezpc({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375.0, 812.0),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (BuildContext context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: KString.appName,
          initialRoute: RouteNames.splashScreen,
          onGenerateRoute: RouteNames.generateRoutes,
          onUnknownRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ),
            );
          },
          theme: MyTheme.theme,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150', // Imagen de ejemplo
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Afternoon',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'John Doe\nRole: Client',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications, size: 30, color: Colors.grey),
                ],
              ),
            ),
            // Opciones de Filtro
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChoiceChip(label: Text("Same Day"), selected: false),
                  ChoiceChip(label: Text("Price: Lowest"), selected: false),
                  ChoiceChip(label: Text("4.7 ★"), selected: false),
                  Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // Sección de Oferta
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "Today's Offer",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Get discount for every order only valid for today",
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Carrusel de Categorías
            CarouselSlider(
              options: CarouselOptions(
                height: 100.h,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.3,
              ),
              items: [
                _buildCategory(Icons.build, 'Carpentry'),
                _buildCategory(Icons.plumbing, 'Plumbing'),
                _buildCategory(Icons.electrical_services, 'Electricity'),
                _buildCategory(Icons.brush, 'Painting'),
                _buildCategory(Icons.cleaning_services, 'Cleaning'),
                _buildCategory(Icons.home_repair_service, 'Repair'),
                _buildCategory(Icons.home_repair_service, 'Gardening'),
                _buildCategory(Icons.pest_control, 'Pest Control'),
                _buildCategory(Icons.local_shipping, 'Moving'),
                _buildCategory(Icons.design_services, 'Design'),
              ],
            ),
            SizedBox(height: 20.h),

            // Sección de Referidos
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Get \$5 by helping your friends\nThey get \$5 off their first task and you get \$5 when they complete it.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),

            // Sección de Tareas Destacadas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Featured Tasks",
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {}, child: const Text("See All")),
                    ],
                  ),
                  // Aquí podrías agregar un ListView horizontal con tasks
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategory(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }
}
