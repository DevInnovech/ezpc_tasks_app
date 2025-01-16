import 'package:flutter/material.dart';

// Modelo de datos para la tarjeta (puedes usarlo en toda la app)
class PopularService {
  final String serviceName;
  final int count;

  PopularService({
    required this.serviceName,
    required this.count,
  });
}

// Widget independiente para mostrar una tarjeta de servicio popular
class PopularServiceCard extends StatelessWidget {
  final PopularService service;

  const PopularServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Acción al hacer clic en la tarjeta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected service: ${service.serviceName}')),
        );
      },
      child: Container(
        width: 150, // Ancho de la tarjeta
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono representativo (puedes personalizar)
            const Icon(Icons.star, size: 40, color: Colors.blue),
            const SizedBox(height: 8),

            // Nombre del servicio
            Text(
              service.serviceName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Conteo del servicio
            Text(
              "Used ${service.count} times",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
