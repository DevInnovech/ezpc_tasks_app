import 'package:ezpc_tasks_app/features/order%20clientes/data%20&%20models/invoice_provider.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.item,
  });

  final OrderItems item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Usando watch en vez de notifier para observar el proveedor
        ref.read(invoiceProvider(item.orderId).future).then((orderDetails) {
          Navigator.pushNamed(
            context,
            RouteNames.orderDetails,
            arguments: orderDetails,
          );
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Utils.horizontalSpace(10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.bookingDate,
                            style: const TextStyle(
                              color: Color(0xFF535769),
                              fontSize: 18,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w600,
                              height: 1.64,
                            ),
                          ),
                        ],
                      ),
                      Utils.verticalSpace(1),
                      Text(
                        'Total Amount: ${item.totalAmount}',
                        maxLines: 1,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Utils.verticalSpace(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order No: ${item.orderId}',
                            style: const TextStyle(
                              color: Color(0xFF535769),
                              fontSize: 14,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                      Utils.verticalSpace(0),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color.fromARGB(255, 103, 241, 107)
                                    .withOpacity(0.4),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 3),
                              child: Text(
                                "Track",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Utils.getBgColor(item.orderStatus),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            child: Text(Utils.orderStatus(item.orderStatus),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Utils.textColor(item.orderStatus))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
