import 'package:ezpc_tasks_app/features/home/data/dashboardnotifi.dart';
import 'package:ezpc_tasks_app/features/home/models/currency_icon_model.dart';
import 'package:ezpc_tasks_app/features/withdraw/withdraw_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/empty_widget.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/end_drawer_menu.dart';
import 'package:ezpc_tasks_app/features/withdraw/model.dart';
import 'package:ezpc_tasks_app/features/home/models/provider_dashboard_model.dart';
import 'package:ezpc_tasks_app/features/home/presentation/widgets/balance_card.dart';

// Provider para manejar la lista de retiros simulada
final withdrawProvider = Provider<List<WithdrawModel>>((ref) {
  return [
    WithdrawModel(
      typetrasations: true,
      id: 1,
      userId: 1,
      approvedDate: '2023-09-01',
      method: 'PayPal',
      totalAmount: 100.0,
      withdrawAmount: 95.0,
      withdrawCharge: 5.0,
      accountInfo: 'user@example.com',
      status: 1,
      createdAt: '2023-08-01 15:00:00',
      updatedAt: '2023-08-01 15:00:00',
    ),
    WithdrawModel(
      typetrasations: false,
      id: 1,
      userId: 1,
      approvedDate: '2023-09-01',
      method: 'PayPal',
      totalAmount: 100.0,
      withdrawAmount: 95.0,
      withdrawCharge: 5.0,
      accountInfo: 'user@example.com',
      status: 1,
      createdAt: '2023-08-01 15:00:00',
      updatedAt: '2023-08-01 15:00:00',
    ),
    WithdrawModel(
      typetrasations: true,
      id: 2,
      userId: 1,
      approvedDate: '2023-09-05',
      method: 'Bank Transfer',
      totalAmount: 200.0,
      withdrawAmount: 190.0,
      withdrawCharge: 10.0,
      accountInfo: '12345678',
      status: 0,
      createdAt: '2023-08-05 12:00:00',
      updatedAt: '2023-08-05 12:00:00',
    ),
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    // Obtener la lista de retiros simulada
    final withdraws = ref.watch(withdrawProvider);

    // Simulación de los datos del dashboard
    final providerDashBoard = ProviderDashBoardModel(
      currencyIcon: CurrencyIconModel(icon: AutofillHints.language),
      todayTotalOrder: 10,
      todayTotalAwatingOrder: 2,
      todayApprovedOrder: 8,
      todayCompleteOrder: 6,
      todayDeclinedOrder: 1,
      todayTotalEarning: 150.0,
      todayWithdrawRequest: 1,
      monthlyTotalOrder: 50,
      monthlyTotalWwatingOrder: 10,
      monthlyApprovedOrder: 40,
      monthlyCompleteOrder: 35,
      monthlyDeclinedOrder: 5,
      monthlyTotalEarning: 1000.0,
      monthlyWithdrawRequest: 5,
      yearlyTotalAwatingOrder: 120,
      yearlyApprovedOrder: 100,
      yearlyCompleteOrder: 90,
      yearlyTotalOrder: 150,
      yearlyDeclinedOrder: 10,
      yearlyTotalEarning: 12000.0,
      yearlyWithdrawRequest: 10,
      totalTotalOrder: 150,
      totalTotalAwatingOrder: 10,
      totalApprovedOrder: 140,
      totalCompleteOrder: 130,
      totalDeclinedOrder: 10,
      totalTotalEarning: 15000.0,
      totalWithdrawRequest: 10,
      totalService: 15,
    );

    return Scaffold(
      key: scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: primaryColor,
            toolbarHeight: Utils.vSize(240.0),
            centerTitle: true,
            actions: const [SizedBox()],
            title: Column(
              children: [
                Utils.verticalSpace(20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Good Morning!",
                          fontSize: 14.0,
                          color: whiteColor.withOpacity(0.8),
                        ),
                        //nombre de usuario
                        CustomText(
                          text: 'John Doe',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: whiteColor,
                        ),

                        ///aqui va la verificacion de tipo de cuenta que se debe llamr en login
                        CustomText(
                          text: 'Role: Provider',
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: whiteColor,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: Container(
                        height: Utils.vSize(55.0),
                        width: Utils.vSize(60.0),
                        margin: Utils.only(right: 10.0),
                        child: ClipRRect(
                          borderRadius: Utils.borderRadius(r: 6.0),
                          child: const CustomImage(
                            path: KImages.pp,
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const BalanceCard(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Utils.verticalSpace(20.0),
          ),
          SliverToBoxAdapter(
            child: Wrap(
              runSpacing: Utils.vSize(14.0),
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildSingleCard(
                    KImages.d01,
                    providerDashBoard.todayApprovedOrder.toString(),
                    'Active Booking'),
                _buildSingleCard(
                    KImages.d02,
                    providerDashBoard.totalTotalAwatingOrder.toString(),
                    'Pending Booking'),
                _buildSingleCard(
                    KImages.d03,
                    providerDashBoard.totalCompleteOrder.toString(),
                    'End Booking'),
                _buildSingleCard(
                    KImages.d04,
                    providerDashBoard.totalService.toString(),
                    'Total Services'),
                _buildSingleCard(
                    KImages.d05,
                    "\$${providerDashBoard.todayTotalEarning.toStringAsFixed(0)}",
                    'Today Earning'),
                _buildSingleCard(
                    KImages.d05,
                    "\$${providerDashBoard.totalTotalEarning.toStringAsFixed(0)}",
                    'Total Earning'),
              ],
            ),
          ),
          withdraws.isNotEmpty
              ? SliverPadding(
                  padding: Utils.symmetric(v: 20.0).copyWith(bottom: 0.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Recent Transactions',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: blackColor,
                        ),
                        GestureDetector(
                          child: CustomText(
                            text: 'view all',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SliverToBoxAdapter(),
          withdraws.isNotEmpty
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return WithdrawComponent(withdraw: withdraws[index]);
                    },
                    childCount: withdraws.length,
                  ),
                )
              : EmptyWidget(
                  image: KImages.noWallet,
                  text: 'No Transaction Available',
                  height: size.height * 0.2,
                ),
        ],
      ),
      endDrawer: const EndDrawerMenu(),
      endDrawerEnableOpenDragGesture: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildSingleCard(String icon, String count, String title) {
    return Container(
      padding: Utils.symmetric(v: 0.0, h: 0.0),
      height: Utils.vSize(80.0),
      width: Utils.hSize(172.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: Utils.borderRadius(),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: Utils.vSize(38.0),
            width: Utils.vSize(38.0),
            margin: Utils.only(left: 8.0, right: 6.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: scaffoldBgColor,
              shape: BoxShape.circle,
            ),
            child: CustomImage(path: icon),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: count.padLeft(2, '0'),
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
              CustomText(
                text: title,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: grayColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
