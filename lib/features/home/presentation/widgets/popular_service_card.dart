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
  final String serviceName;
  final int count;
  final VoidCallback onTap;

  const PopularServiceCard({
    super.key,
    required this.serviceName,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150, // Ancho de la tarjeta
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
            const Icon(Icons.star, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              serviceName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "Used $count times",
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
