import 'dart:math' as math;
import 'package:ezpc_tasks_app/core/services/conexion.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/exit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  initializeController() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    final curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceIn,
      reverseCurve: Curves.easeInOut,
    );

    animation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              animationController.forward();
            }
          });
    animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    initializeController();

    // Verifica el estado de la conectividad después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      // Siempre asumimos que hay conexión
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.onBoardingScreen, (route) => false);
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Escuchando el estado de la conectividad, aunque ahora siempre asumimos que hay conexión
    ref.listen<InternetStatusState>(internetStatusProvider, (previous, state) {
      if (state is InternetStatusBackState) {
        Utils.showSnackBar(context, state.message);
        Navigator.pushNamedAndRemoveUntil(
            context, RouteNames.onBoardingScreen, (route) => false);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        showDialog(context: context, builder: (context) => const ExitDialog());
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            CustomImage(
              path: KImages.splashBg,
              height: size.height,
              width: size.width,
              fit: BoxFit.cover,
              url: null,
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              bottom: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Transform.rotate(
                  angle: animation.value,
                  child: const CustomImage(
                    path: KImages.circlePattern,
                    url: null,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              bottom: 0.0,
              child: Padding(
                padding: Utils.all(value: 50.0),
                child: const CustomImage(
                  path: KImages.appLogo,
                  url: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
