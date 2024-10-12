import 'package:ezpc_tasks_app/firebase_options.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_theme.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importa Riverpod
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: Ezpc())); // Envuelve Ezpc con ProviderScope
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
        );
      },
    );
  }
}
