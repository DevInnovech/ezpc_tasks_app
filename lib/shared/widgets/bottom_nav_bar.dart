import 'dart:io';

import 'package:ezpc_tasks_app/features/home/presentation/screens/miancontroller.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MainController();
    return Container(
      height: Platform.isAndroid ? Utils.vSize(90.0) : Utils.vSize(100.0),
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Utils.radius(24.0)),
            topRight: Radius.circular(Utils.radius(24.0)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 20,
              offset: Offset(0, 2),
              spreadRadius: 0,
            )
          ]),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: StreamBuilder(
          initialData: 0,
          stream: controller.naveListener.stream,
          builder: (_, AsyncSnapshot<int> index) {
            int selectedIndex = index.data ?? 0;
            return Theme(
                data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.copyWith(
                        bodySmall: const TextStyle(color: Colors.red))),
                child: BottomNavigationBar(
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                  ),
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      tooltip: 'Home',
                      icon: _navIcon(KImages.home),
                      activeIcon: _navIcon(KImages.homeActive),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      tooltip: "Booking",
                      icon: _navIcon(KImages.booking),
                      activeIcon: _navIcon(KImages.bookingActive),
                      label: "Booking",
                    ),
                    BottomNavigationBarItem(
                      tooltip: "Service",
                      icon: _navIcon(KImages.service),
                      activeIcon: _navIcon(KImages.serviceActive),
                      label: "Service",
                    ),
                    BottomNavigationBarItem(
                      tooltip: "Wallet",
                      icon: _navIcon(KImages.wallet),
                      activeIcon: _navIcon(KImages.walletActive),
                      label: "Wallet",
                    ),
                    BottomNavigationBarItem(
                      tooltip: "Profile",
                      icon: _navIcon(KImages.person),
                      activeIcon: _navIcon(KImages.personActive),
                      label: "Profile",
                    ),
                  ],
                  // type: BottomNavigationBarType.fixed,
                  currentIndex: selectedIndex,
                  onTap: (int index) {
                    controller.naveListener.sink.add(index);
                  },
                ));
          },
        ),
      ),
    );
  }

  Widget _navIcon(String path) {
    return Padding(
      padding: Utils.symmetric(h: 0.0, v: 6.0),
      child: SvgPicture.asset(path),
    );
  }
}
