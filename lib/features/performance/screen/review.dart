import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class ReviewOnTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor, // Primary color for app theme
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        title: Text(
          'Review On Tasks',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Customer Review By Tasks Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildReviewCard(
                name: 'Donna Bins',
                username: '@DONNABINS',
                taskName: 'Painting',
                rating: 4.5,
                date: '25 Jan',
                reviewText:
                    'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet.',
                avatar: KImages.pp,
              ),
              SizedBox(height: 20),
              _buildReviewCard(
                name: 'Donna Bins',
                username: '@DONNABINS',
                taskName: 'Painting',
                rating: 4.5,
                date: '25 Jan',
                reviewText:
                    'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet.',
                avatar: KImages.pp,
              ),
              SizedBox(height: 20),
              _buildReviewCard(
                name: 'Donna Bins',
                username: '@DONNABINS',
                taskName: 'Painting',
                rating: 4.5,
                date: '25 Jan',
                reviewText:
                    'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet.',
                avatar: KImages.pp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String username,
    required String taskName,
    required double rating,
    required String date,
    required String reviewText,
    required String avatar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(avatar),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  // Handle delete action
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Name : $taskName',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),
                SizedBox(height: 5),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < rating ? Colors.orange : Colors.grey,
                          size: 18,
                        );
                      }),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  reviewText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
