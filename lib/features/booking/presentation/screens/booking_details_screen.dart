import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/booking_details_component.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/details_bottom_section.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/single_expansion_tile.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/details_custom_shape.dart';
import 'package:ezpc_tasks_app/shared/widgets/fetch_error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDetailsState = ref.watch(bookingDetailsProvider(id));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: bookingDetailsState.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => FetchErrorText(text: error.toString()),
        data: (bookingDetails) => LoadedBookingDetailsWidget(
          bookingDetails: bookingDetails,
        ),
      ),
    );
  }
}

class LoadedBookingDetailsWidget extends StatelessWidget {
  LoadedBookingDetailsWidget({super.key, required this.bookingDetails});

  final BookingDetailsDto bookingDetails;
  final panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    final headingText = [
      'Included Service',
      'Booking Information',
      'Client Details',
    ];
    return SlidingUpPanel(
      body: Column(
        children: [
          Padding(
            padding: Utils.symmetric(v: 50.0).copyWith(bottom: 0.0),
            child: const CustomAppBar(title: 'Booking Details'),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: Utils.only(bottom: 124.0, top: 20.0),
              children: [
                SingleExpansionTile(
                  heading: headingText[0],
                  isExpand: true,
                  child: IncludeService(service: bookingDetails),
                ),
                SingleExpansionTile(
                  heading: headingText[1],
                  child: BookingDetailsAddress(service: bookingDetails),
                ),
                SingleExpansionTile(
                  heading: headingText[2],
                  child: ClientInformation(service: bookingDetails),
                ),
              ],
            ),
          ),
        ],
      ),
      maxHeight: Utils.vSize(301.0),
      color: transparent,
      backdropOpacity: 1.0,
      backdropColor: transparent,
      parallaxOffset: 0.0,
      controller: panelController,
      boxShadow: const [
        BoxShadow(blurRadius: 0.0, color: transparent, offset: Offset(0, -3))
      ],
      panelBuilder: (controller) {
        return DetailBottomSection(
          bookingDetails: bookingDetails,
          panelController: panelController,
        );
      },
      collapsed: Container(
        width: double.infinity,
        height: Utils.vSize(100.0),
        decoration: const BoxDecoration(
          boxShadow: [],
        ),
        child: CustomPaint(
          painter: DetailsCustomShape(),
          child: Padding(
            padding: Utils.symmetric(v: 10.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: CustomImage(
                    url: null,
                    path: KImages.lineIcon,
                    color: blackColor.withOpacity(0.8),
                  ),
                ),
                Utils.verticalSpace(16.0),
                PrimaryButton(
                  text: 'Bill Details',
                  onPressed: () {
                    panelController.isPanelOpen
                        ? panelController.close()
                        : panelController.open();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
