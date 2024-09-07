import 'dart:io';

import 'package:ezpc_tasks_app/features/home/presentation/screens/miancontroller.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class ClientBottomNavigationBar extends StatelessWidget {
  const ClientBottomNavigationBar({Key? key, required this.scaffoldKey})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final controller = MainController();
    return Container(
      height: Platform.isAndroid ? Utils.vSize(80.0) : Utils.vSize(110.0),
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: StreamBuilder(
          initialData: 0,
          stream: controller.naveListener.stream,
          builder: (_, AsyncSnapshot<int> index) {
            int selectedIndex = index.data ?? 0;
            return BottomNavigationBar(
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedLabelStyle: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
              unselectedLabelStyle: const TextStyle(fontSize: 12.0),
              selectedItemColor: primaryColor,
              items: <BottomNavigationBarItem>[
                _bottomNavItem(
                    icon: KImages.homeclient,
                    active: KImages.homeActiveclient,
                    title: 'Home'),
                // _bottomNavItem(
                //     icon: KImages.inbox,
                //     active: KImages.inboxActive,
                //     title: "Inbox"),
                _bottomNavItem(
                    icon: KImages.order,
                    active: KImages.orderActive,
                    title: "Order"),
                _bottomNavItem(
                    icon: KImages.service,
                    active: KImages.serviceActive,
                    title: "Services"),
                _bottomNavItem(
                    icon: KImages.more,
                    active: KImages.moreActive,
                    title: "More"),
              ],
              // type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              onTap: (int index) {
                if (index == 3) {
                  scaffoldKey.currentState!.openDrawer();
                  controller.naveListener.sink.add(0);
                } else {
                  controller.naveListener.sink.add(index);
                }
              },
            );
          },
        ),
      ),
    );
  }

  _bottomNavItem(
      {required String icon, required String active, required String title}) {
    return BottomNavigationBarItem(
      // icon: _navIcon(icon),
      icon: CustomImage(path: icon),
      activeIcon: AnimatedContainer(
        duration: kDuration,
        // height: Utils.vSize(60.0),
        // width: Utils.vSize(60.0),
        // color: redColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(path: active),
          ],
        ),
      ),
      label: title,
    );
  }
}
