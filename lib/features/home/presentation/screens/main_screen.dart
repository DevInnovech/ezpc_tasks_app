import 'package:ezpc_tasks_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/miancontroller.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/end_drawer_menu.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/sevices_page.dart';
import 'package:ezpc_tasks_app/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/home_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_dialog.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _homeController = MainController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> screenList;

  @override
  void initState() {
    super.initState();
    screenList = [
      const HomeScreen(),
      const ProviderOrdersScreen(),
      const ServiceScreen(),
      const HomeScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(context: context, builder: (context) => const ExitDialog());
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const EndDrawerMenu(),
        body: StreamBuilder<int>(
          initialData: 0,
          stream: _homeController.naveListener.stream,
          builder: (context, AsyncSnapshot<int> snapshot) {
            int item = snapshot.data ?? 0;
            return screenList[item];
          },
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          scaffoldKey: _scaffoldKey,
        ),
      ),
    );
  }
}

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return CustomDialog(
      icon: KImages.exitFromAppIcon,
      height: size.height * 0.32,
      child: Column(
        children: [
          const CustomText(
            text: 'Are you sure\nYou want to Exit?',
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            color: blackColor,
            textAlign: TextAlign.center,
          ),
          Utils.verticalSpace(8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PrimaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                borderRadiusSize: 6.0,
                bgColor: blackColor,
                fontSize: 16.0,
                minimumSize: Size(Utils.hSize(125.0), Utils.vSize(52.0)),
              ),
              PrimaryButton(
                text: 'Exit',
                onPressed: () => SystemNavigator.pop(),
                bgColor: redColor,
                borderRadiusSize: 6.0,
                fontSize: 16.0,
                minimumSize: Size(Utils.hSize(125.0), Utils.vSize(52.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
