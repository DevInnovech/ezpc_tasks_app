import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/reviewpop.dart';
import 'package:ezpc_tasks_app/features/home/data/client_data_model.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/AllcategoriesScreen.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/booking_tasks_view.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/Client_home_screen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/miancontroller.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_app_drawer.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_bottom_navigation_bar.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/feedback_dialog.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientMainScreen extends ConsumerStatefulWidget {
  const ClientMainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<ClientMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _homeController = MainController();
  late List<Widget> screenList;

  @override
  void initState() {
    super.initState();
    screenList = [
      const ClientHomeScreen(),
      const ClientCategoryScreen(),
      const ProviderOrdersScreen(),
      const ClientHomeScreen(),
    ];

    // Se inicializan los providers (esto reemplaza las llamadas a Cubits)
    ref.read(dashBoardProfileProvider);
    ref.read(serviceListProvider);
    ref.read(privacyPolicyProvider);
    ref.read(faqProvider);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkPendingFeedback(context));
  }

  void exitPopUP(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FeedBackDialog(
        image: KImages.thumbsIcon,
        message: "Exit?",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 0.0),
            const Text(
              "Do you want to exit?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                exitButton(
                  () => Navigator.pop(context),
                  "No",
                  Colors.black,
                  whiteColor,
                ),
                const SizedBox(width: 20.0),
                exitButton(() => SystemNavigator.pop(), "Yes", whiteColor,
                    primaryColor),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget exitButton(
      VoidCallback onTap, String text, Color textColor, Color bgColor) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(bgColor),
        minimumSize: WidgetStateProperty.all(const Size(104, 40)),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 0.0)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exitPopUP(context);
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ClientAppDrawer(),
        body: StreamBuilder<int>(
          initialData: 0,
          stream: _homeController.naveListener.stream,
          builder: (context, AsyncSnapshot<int> snapshot) {
            int item = snapshot.data ?? 0;
            return getPage(item);
          },
        ),
        bottomNavigationBar: ClientBottomNavigationBar(
          scaffoldKey: _scaffoldKey,
        ),
      ),
    );
  }

  Widget getPage(int item) {
    switch (item) {
      case 0:
        return const ClientHomeScreen();
      case 1:
        return const MyBookingsScreen();
      case 2:
        return const ClientCategoryScreen();

      default:
        return const SizedBox();
    }
  }
}

void checkPendingFeedback(BuildContext context1) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final clientId = user.uid; // Reemplaza con el ID del cliente autenticado

  final feedbackSnapshot = await FirebaseFirestore.instance
      .collection('pendingFeedbacks')
      .doc(clientId)
      .collection('feedbackList')
      .limit(1) // Obtener la primera reserva pendiente
      .get();

  if (feedbackSnapshot.docs.isNotEmpty) {
    final pendingFeedback = feedbackSnapshot.docs.first;
    final bookingId = pendingFeedback.id;
    final bookingData = pendingFeedback.data();

    // Mostrar el diálogo de feedback
    showCompletionReviewPopup(
      context1,
      {
        'bookingId': bookingId,
        'providerId': bookingData['providerId'],
        'customerId': clientId,
      },
      isReviewingProvider: true,
    ).then((_) async {
      // Eliminar la reserva de feedback pendiente después de enviar
      await FirebaseFirestore.instance
          .collection('pendingFeedbacks')
          .doc(clientId)
          .collection('feedbackList')
          .doc(bookingId)
          .delete();
    });
  }
}
