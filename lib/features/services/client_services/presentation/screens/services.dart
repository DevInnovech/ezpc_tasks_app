import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/services/client_services/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/services/client_services/data/scheduleProvider.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_filter.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class Service extends ConsumerStatefulWidget {
  final ServiceModel selectedService;
  final String selectedSize;
  final String hours;
  final int quantity;

  const Service({
    super.key,
    required this.selectedService,
    required this.selectedSize,
    required this.hours,
    required this.quantity,
  });

  @override
  ConsumerState<Service> createState() => _ServiceState();
}

class _ServiceState extends ConsumerState<Service> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? selectedTimeSlot;
  late ProviderModel? selectedProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize the provider selected with the provider of the service
    selectedProvider = widget.selectedService.provider;
    if (selectedProvider != null && selectedProvider!.timeSlots!.isNotEmpty) {
      final firstAvailableSlot = selectedProvider!.timeSlots!.firstWhere(
        (slot) => slot.isAvailable,
        orElse: () => selectedProvider!.timeSlots!.first,
      );
      selectedTimeSlot = firstAvailableSlot.time;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableSchedules = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Task Provider Availability")),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarSection(),
                  GenericFilterWidget(
                    onFilterSelected: (selectedFilters) {
                      if (selectedFilters != null) {
                        print('Selected Filters: $selectedFilters');
                      } else {
                        print('No filters selected');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildProviderList(availableSchedules),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 16,
            right: 16,
            child: PrimaryButton(
              text: "Next",
              onPressed: () {
                if (selectedProvider != null && selectedTimeSlot != null) {
                  print("vamonos ");
                  setState(() {
                    ServiceModel updateservices = ServiceModel(
                        id: widget.selectedService.id,
                        name: widget.selectedService.name,
                        slug: widget.selectedService.slug,
                        price: widget.selectedService.price,
                        categoryId: widget.selectedService.categoryId,
                        subCategoryId: widget.selectedService.subCategoryId,
                        details: widget.selectedService.details,
                        image: widget.selectedService.image,
                        packageFeature: widget.selectedService.packageFeature,
                        benefits: widget.selectedService.benefits,
                        whatYouWillProvide:
                            widget.selectedService.whatYouWillProvide,
                        status: widget.selectedService.status,
                        provider: selectedProvider!);

                    print("Selected Provider: ${selectedProvider!.name}");
                    print("Selected Time Slot: $selectedTimeSlot");
                    Navigator.pushNamed(
                      context,
                      RouteNames
                          .lastServiceScreen, // Use the correct route name here
                      arguments: {
                        'selectedService':
                            updateservices, // Pass the selected service
                        'selectedSize':
                            widget.selectedSize, // Pass the selected size
                        'hours': widget.hours, // Pass the selected hours
                        'quantity': widget.quantity, // Pass the quantity
                        'time': selectedTimeSlot
                      },
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a provider and time slot."),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            ref.read(bookingProvider.notifier).setServiceAndDate(
                  widget.selectedService.id,
                  selectedDay,
                );
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(
              color: primaryColor.withOpacity(0.6),
            ),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle:
                TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
            leftChevronPadding: EdgeInsets.all(12.0),
            rightChevronPadding: EdgeInsets.all(12.0),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderList(
      AsyncValue<List<ProviderModel>> availableSchedules) {
    return availableSchedules.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (providers) {
        if (selectedProvider != null) {
          providers
              .removeWhere((provider) => provider.id == selectedProvider!.id);
          providers.insert(0, selectedProvider!);
        }

        return Column(
          children: providers.map((provider) {
            return _buildProviderCard(provider);
          }).toList(),
        );
      },
    );
  }

  Widget _buildProviderCard(ProviderModel provider) {
    final isSelectedProvider = provider.id == selectedProvider?.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProvider = provider;
          selectedTimeSlot = null;
        });

        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: isSelectedProvider ? Colors.blueAccent : Colors.black12,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(provider),
              const SizedBox(height: 12),
              _buildTimeSlots(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProviderModel provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea al inicio superior
      children: [
        // Imagen del proveedor
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CustomImage(
            url: null,
            path: provider.image,
            height: 60, // Ajusta la altura de la imagen según lo que necesites
            width: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre y botón en la misma fila
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildViewServicesButton()
                  // Botón en el encabezado
                ],
              ),
              // Profesión del proveedor
              Text(
                provider.profession!,
                style: const TextStyle(color: Colors.grey),
              ),

              // Calificación del proveedor
              Row(
                children: [
                  for (var i = 0; i < provider.rating.round(); i++)
                    const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    '${provider.rating.toStringAsFixed(1)} (${provider.reviews} Reviews)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

// Este es el widget para el botón "View Services"
  Widget _buildViewServicesButton() {
    return ElevatedButton(
      onPressed: () {
        // Button action
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.zero, // Remove padding
        backgroundColor: greyColor.withOpacity(0.15), // Transparent background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded borders
          // Blue border
        ),
        minimumSize: const Size(0, 0), // Minimal size constraint
        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap, // Shrink the button size
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 8, vertical: 0), // Small padding for the text
        child: Text(
          "+Services",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: primaryColor, // Text color matching the border
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots(ProviderModel provider) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(provider.timeSlots!.length, (index) {
        final timeSlot = provider.timeSlots![index];
        final isAvailable = timeSlot.isAvailable;

        return GestureDetector(
          onTap: selectedProvider == provider && isAvailable
              ? () {
                  setState(() {
                    selectedTimeSlot = timeSlot.time;
                  });
                  ref.read(bookingProvider.notifier).setTimeSlot(timeSlot.time);
                }
              : null,
          child: Container(
            width: 75,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable && selectedProvider == provider
                  ? selectedTimeSlot == timeSlot.time
                      ? primaryColor
                      : Colors.white
                  : greyColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAvailable && selectedProvider == provider
                    ? primaryColor
                    : greyColor.withOpacity(0.4),
              ),
            ),
            child: Center(
              child: Text(
                timeSlot.time,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isAvailable && selectedProvider == provider
                      ? selectedTimeSlot == timeSlot.time
                          ? Colors.white
                          : primaryColor
                      : greyColor.withOpacity(1),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
