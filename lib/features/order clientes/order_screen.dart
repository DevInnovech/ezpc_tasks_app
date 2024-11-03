import 'package:ezpc_tasks_app/features/order%20clientes/data%20&%20models/order_provider.dart';
import 'package:ezpc_tasks_app/features/order%20clientes/order_card.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/empty_widget.dart';
import 'package:ezpc_tasks_app/shared/widgets/please_signin_widget.dart';
import 'package:ezpc_tasks_app/shared/widgets/scrolling_taggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderList = ref.watch(orderProvider);

    return SafeArea(
      child: Scaffold(
        body: orderList.isEmpty
            ? EmptyWidget(
                image: KImages.emptyBookingImage,
                text: "No Orders Yet",
              )
            : OrderLoadedWidget(
                orderedList: orderList,
                routeMessage: message,
              ),
      ),
    );
  }
}

class OrderLoadedWidget extends ConsumerStatefulWidget {
  final List<OrderItems> orderedList;
  final String routeMessage;

  const OrderLoadedWidget({
    Key? key,
    required this.orderedList,
    required this.routeMessage,
  }) : super(key: key);

  @override
  ConsumerState<OrderLoadedWidget> createState() => _OrderLoadedWidgetState();
}

class _OrderLoadedWidgetState extends ConsumerState<OrderLoadedWidget> {
  List<OrderItems> orderedList = [];
  int _currentIndex = 0;

  void _filtering(int index) {
    orderedList.clear();
    _currentIndex = index;
    if (index == 0) {
      orderedList = widget.orderedList
          .where((element) => element.orderStatus == "Pending")
          .toList();
    } else if (index == 1) {
      orderedList = widget.orderedList
          .where((element) => element.orderStatus == "approved_by_provider")
          .toList();
    } else if (index == 2) {
      orderedList = widget.orderedList
          .where((element) => element.orderStatus == "complete")
          .toList();
    } else if (index == 3) {
      orderedList = widget.orderedList
          .where(
              (element) => element.orderStatus == "order_declined_by_provider")
          .toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    _filtering(_currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = ["Pending", "Approved", "Completed", "Declined"];

    return Column(
      children: [
        Utils.verticalSpace(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.routeMessage.isNotEmpty
                  ? GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 48.w,
                        width: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF040415).withOpacity(0.1),
                            )),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 18.0,
                          color: Color(0xFF040415),
                        ),
                      ),
                    )
                  : const SizedBox(),
              const Center(
                child: Text(
                  'My Orders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF051533),
                    fontSize: 22,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(),
            ],
          ),
        ),
        Utils.verticalSpace(20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.50, color: primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ToggleButtonScrollComponent(
            textList: list,
            initialLabelIndex: _currentIndex,
            onChange: _filtering,
          ),
        ),
        Utils.verticalSpace(10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: orderedList.length,
            itemBuilder: (c, i) {
              return OrderCard(item: orderedList[i]);
            },
          ),
        )
      ],
    );
  }
}

List<String> orderTabItems = ['Active', 'Completed', 'Cancelled'];
