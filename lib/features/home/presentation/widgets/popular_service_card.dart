import 'package:ezpc_tasks_app/features/home/presentation/widgets/scrool_text.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

// Modelo de datos para la tarjeta (puedes usarlo en toda la app)
class PopularServiceCard extends StatelessWidget {
  final String? image;
  final String serviceName;
  final String category;
  final int count;
  final int rank;
  final VoidCallback onTap;

  const PopularServiceCard({
    super.key,
    required this.serviceName,
    required this.category,
    required this.count,
    required this.rank,
    required this.onTap,
    required this.image,
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
        child: Stack(
          clipBehavior: Clip.hardEdge, // Asegura que el contenido no salga
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del servicio
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150 * 0.5, // Altura relativa al ancho
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: image != null
                        ? Image.asset(
                            'assets/images/pp.jpg', // Imagen por defecto
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nombre del servicio
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

                // Categoría (con desplazamiento si es largo)
                ScrollingText(
                  text: category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  velocity: 50.0,
                ),
                const SizedBox(height: 8),

                // Conteo de popularidad (estrella y texto en una fila)
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "$count times",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Insignia del ranking (en la esquina superior derecha)
            Positioned(
              top: 0, // Ajustar posición para no salir del borde
              right: 0, // Ajustar posición para mantenerlo dentro
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "Top $rank",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getRankColor(int rank) {
  switch (rank) {
    case 1:
      return primaryColor; // Dorado intenso para el Top 1
    case 2:
      return primaryColor.withGreen(100); // Plateado para el Top 2
    case 3:
      return primaryColor.withRed(100); // Bronce para el Top 3
    default:
      return primaryColor.withBlue(100); // Amarillo estándar
  }
}
