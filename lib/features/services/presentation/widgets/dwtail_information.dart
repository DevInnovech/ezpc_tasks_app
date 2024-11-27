import 'package:ezpc_tasks_app/features/services/presentation/widgets/detailtabview.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/overviewtabview.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/features/services/models/services_model.dart';

class DetailInformation extends StatefulWidget {
  const DetailInformation({super.key, required this.service});
  final ServiceProductStateModel service;

  @override
  State<DetailInformation> createState() => _DetailInformationState();
}

class _DetailInformationState extends State<DetailInformation> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> detailScreen = [
      OverViewTabView(services: widget.service),
      DetailsTabView(services: widget.service),
    ];

    final List<String> tabButton = ['Overview', 'Details'];

    return ExpandablePageView.builder(
      itemCount: detailScreen.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, position) {
        return Column(
          children: [
            Container(
              padding: Utils.symmetric(h: 10.0, v: 6.0),
              decoration: BoxDecoration(
                borderRadius: Utils.borderRadius(),
                border: Border.all(color: grayColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  tabButton.length,
                  (index) {
                    final active = _currentTab == index;
                    return GestureDetector(
                      onTap: () => setState(() => _currentTab = index),
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        alignment: Alignment.center,
                        padding: Utils.symmetric(h: 40.0, v: 12.0),
                        decoration: BoxDecoration(
                          color: active ? primaryColor : transparent,
                          borderRadius: Utils.borderRadius(r: 8.0),
                        ),
                        child: CustomText(
                          text: tabButton[index],
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: active ? whiteColor : primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: Utils.symmetric(v: 20.0, h: 0.0).copyWith(bottom: 40.0),
              child: detailScreen[_currentTab],
            ),
          ],
        );
      },
    );
  }
}
