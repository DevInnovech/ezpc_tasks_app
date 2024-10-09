import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_data_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/provider_booking_dto.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/booking_component.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/fetch_error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';
import 'package:ezpc_tasks_app/shared/widgets/scrolling_taggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingListProvider);

    return Scaffold(
      body: bookingState.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => FetchErrorText(text: error.toString()),
        data: (providerBookingDto) => LoadedBookingWidget(
          bookingDto: providerBookingDto,
        ),
      ),
    );
  }
}

class LoadedBookingWidget extends ConsumerStatefulWidget {
  const LoadedBookingWidget({super.key, required this.bookingDto});

  final ProviderBookingDto bookingDto;

  @override
  ConsumerState<LoadedBookingWidget> createState() =>
      _LoadedBookingWidgetState();
}

class _LoadedBookingWidgetState extends ConsumerState<LoadedBookingWidget> {
  List<BookingDataDto> bookingList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    // print(widget.bookingDto.orders);
    _filtering(_currentIndex);
    super.initState();
  }

  void _filtering(int index) {
    bookingList.clear();
    _currentIndex = index;

    print("Filtrando en el índice: $index"); // Agrega esta línea

    switch (index) {
      case 0:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "awaiting")
            .toList();
        break;
      case 1:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "approved")
            .toList();
        break;
      case 2:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "complete")
            .toList();
        break;
      case 3:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "decliened")
            .toList();
        break;
    }

    print("Elementos filtrados: ${bookingList.length}"); // Agrega esta línea

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final list = [
      "Awaiting (${_countOrders("awaiting")})",
      "Approved (${_countOrders("approved")})",
      "Complete (${_countOrders("complete")})",
      "Declined (${_countOrders("decliened")})",
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          backgroundColor: scaffoldBgColor,
          toolbarHeight: Utils.vSize(75.0),
          centerTitle: true,
          title: const CustomText(
            text: "Booking",
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
          bottom: ToggleButtonScrollComponent(
            onChange: _filtering,
            textList: list,
            initialLabelIndex: _currentIndex,
          ),
        ),
        bookingList.isNotEmpty
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    BookingComponent(booking: bookingList[index]),
                childCount: bookingList.length,
              ))
            : SliverToBoxAdapter(
                child: SizedBox(
                  height: size.height * 0.6,
                  width: size.width,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomImage(
                        url: null,
                        path: KImages.emptyBookingImage,
                      ),
                      CustomText(
                          text: 'Empty Item',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700)
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  int _countOrders(String status) {
    return widget.bookingDto.orders!
        .where((element) => element.orderStatus == status)
        .length;
  }
}
