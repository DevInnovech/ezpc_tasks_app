import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';

class ServiceImage extends StatelessWidget {
  const ServiceImage({super.key});

  @override
  Widget build(BuildContext context) {
    const image = ''; // Replace with image state

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (image.isEmpty) ...[
          GestureDetector(
            onTap: () async {
              final pickedImage = await Utils.pickSingleImage();
              if (pickedImage != null) {
                // Handle image selection
              }
            },
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
                  child: const CustomImage(
                    path: image,
                    isFile: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 20,
                child: InkWell(
                  onTap: () async {
                    final pickedImage = await Utils.pickSingleImage();
                    if (pickedImage != null) {
                      // Handle image change
                    }
                  },
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
