import 'dart:io';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';

class ServiceImage extends StatefulWidget {
  final void Function(String imageUrl) onImageSelected;
  final String?
      initialImageUrl; // Para mostrar la imagen inicial si está guardada

  const ServiceImage(
      {super.key, required this.onImageSelected, this.initialImageUrl});

  @override
  _ServiceImageState createState() => _ServiceImageState();
}

class _ServiceImageState extends State<ServiceImage> {
  File? imageFile; // Ahora almacenamos el archivo en lugar de la cadena
  String? fileName; // Para mostrar el nombre del archivo

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null) {
      imageFile = File(
          widget.initialImageUrl!); // Inicializamos con la imagen existente
      fileName = widget.initialImageUrl!
          .split('/')
          .last; // Extraemos el nombre del archivo
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await Utils
        .pickSingleImage(); // Suponiendo que devuelve un String (la ruta del archivo)
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage); // Creamos un File con la ruta devuelta
        fileName = pickedImage
            .split('/')
            .last; // Extraemos el nombre del archivo de la ruta
      });
      widget.onImageSelected(pickedImage); // Guardamos la ruta en el estado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageFile == null) ...[
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, color: Colors.blue),
                    SizedBox(width: 5.0),
                    CustomText(
                      text: "Browse Image",
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
                    path: imageFile!.path, // Usamos la ruta del archivo
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
              Positioned(
                bottom: 10,
                left: 10,
                child: Text(fileName ?? '',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
