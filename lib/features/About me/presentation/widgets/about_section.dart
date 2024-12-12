import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class AboutSection extends StatefulWidget {
  final String descripcion;
  final String providerName;
  final String providerTitle;
  final String imagePath;

  const AboutSection({
    super.key,
    required this.descripcion,
    required this.providerName,
    required this.providerTitle,
    required this.imagePath,
  });

  @override
  _AboutSectionState createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "About Tasks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            isExpanded
                ? widget.descripcion
                : "${widget.descripcion.substring(0, 50)}...",
            textAlign: TextAlign.left,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(isExpanded ? "Read less" : "Read more"),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Imagen y detalles del proveedor
                Row(
                  children: [
                    ClipOval(
                      child: CustomImage(
                        path: widget.imagePath,
                        height: 60.0,
                        width: 60.0,
                        fit: BoxFit.cover,
                        isFile: widget.imagePath.startsWith('http'),
                        url: widget.imagePath,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.providerName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.providerTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Íconos de acción
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.black),
                      onPressed: () {
                        // Lógica para el botón de mensaje
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.black),
                      onPressed: () {
                        // Lógica para el botón de llamada
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ]));
  }
}
