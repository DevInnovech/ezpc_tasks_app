import 'package:ezpc_tasks_app/features/About%20me/models/review_model.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AboutMeReviews extends StatelessWidget {
  final List<ReviewModel> reviews;

  const AboutMeReviews({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          leading: ClipOval(
            child: CustomImage(
              path: review.imagen,
              height: 45.0,
              width: 45.0,
              fit: BoxFit.cover,
              isFile: review.imagen.startsWith('http'),
              url: null,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(review.date).toString(),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${review.comment.substring(0, 18)}..."),
              Row(
                children: [
                  Text(
                    review.rating.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.star, color: Colors.amber),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
