import 'package:ezpc_tasks_app/features/order%20clientes/data%20&%20models/provider_tracking_provider.dart';
import 'package:flutter/material.dart';

class ExpandableStatusDescription extends StatefulWidget {
  final TrackingStatus status;

  const ExpandableStatusDescription({Key? key, required this.status})
      : super(key: key);

  @override
  _ExpandableStatusDescriptionState createState() =>
      _ExpandableStatusDescriptionState();
}

class _ExpandableStatusDescriptionState
    extends State<ExpandableStatusDescription> {
  bool _isExpanded = false;

  String getTitle(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.reserved:
        return "Proveedor Reservado";
      case TrackingStatus.onTheWay:
        return "Proveedor en Camino";
      case TrackingStatus.atLocation:
        return "Proveedor en Ubicación";
      default:
        return "Seguimiento no disponible";
    }
  }

  String getDescription(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.reserved:
        return "Tu orden está esperando ser iniciada para el seguimiento.";
      case TrackingStatus.onTheWay:
        return "El proveedor está en camino. Llegará a tu ubicación en breve.";
      case TrackingStatus.atLocation:
        return "El proveedor está en tu ubicación y está trabajando en el servicio.";
      default:
        return "El estado no está disponible actualmente.";
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = getTitle(widget.status);
    String description = getDescription(widget.status);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
