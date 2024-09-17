import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'dart:io';

class ServiceImage extends StatefulWidget {
  final void Function(String imageUrl) onImageSelected;

  const ServiceImage({super.key, required this.onImageSelected});

  @override
  _ServiceImageState createState() => _ServiceImageState();
}

class _ServiceImageState extends State<ServiceImage> {
  String? image; // Variable para guardar el path de la imagen seleccionada
  String? fileName; // Variable para guardar el nombre del archivo seleccionado

  Future<void> _pickImage() async {
    final pickedImagePath = await Utils.pickSingleImage();
    if (pickedImagePath != null) {
      setState(() {
        image = pickedImagePath; // Guardamos la ruta de la imagen
        fileName = File(pickedImagePath)
            .uri
            .pathSegments
            .last; // Extraemos el nombre del archivo
      });
      widget.onImageSelected(pickedImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (image == null) ...[
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 70.0,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DottedBorder(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                borderType: BorderType.RRect,
                radius: const Radius.circular(10.0),
                color: Colors.blue,
                dashPattern: const [6, 3],
                strokeCap: StrokeCap.square,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_outlined, color: Colors.blue),
                    const SizedBox(width: 5.0),
                    CustomText(
                      text: fileName != null
                          ? fileName!
                          : "Browse Image", // Mostrar el nombre del archivo o el texto por defecto
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          Stack(
            children: [
              Container(
                height: 180.0,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CustomImage(
                    path: image!,
                    isFile: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 20,
                child: InkWell(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    maxRadius: 16.0,
                    backgroundColor: Color(0xff18587A),
                    child: Icon(Icons.edit, color: Colors.white, size: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
