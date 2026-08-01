import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoursePlayerViewModel>(context);
    final reviews = viewModel.reviews;
    final ratingCount = reviews.length;
    final avgRating = viewModel.course?.rating ?? 0.0;
    
    return ListView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Learner's Review",
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizer.deviceWidth4),
                    ),
                  ),
                  builder: (context) => const WriteReviewSheet(),
                );
              },
              icon: Icon(Icons.add, size: AppSizer.deviceSp18),
              label: const Text('Write a review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        
        // Overall Rating
        Text(
          avgRating.toStringAsFixed(1),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizer.deviceSp22,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < avgRating.floor() ? Icons.star : (index < avgRating ? Icons.star_half : Icons.star_border),
              color: AppColors.buttonColor,
              size: AppSizer.deviceSp20,
            );
          }),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        
        Text(
          'Overall Rating ($ratingCount reviews)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizer.deviceSp16,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight3),
        
        const Divider(),
        SizedBox(height: AppSizer.deviceHeight2),
        
        // Reviews List
        if (reviews.isEmpty)
          const Center(child: Text('No reviews yet'))
        else
          ...reviews.map((review) => ReviewCard(review: review)).toList(),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final CourseReview review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initial = review.studentName.isNotEmpty ? review.studentName[0].toUpperCase() : '?';
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: AppSizer.deviceSp24,
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.studentName,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Row(
                  children: [
                    ...List.generate(5, (index) => 
                      Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: AppColors.buttonColor,
                        size: AppSizer.deviceSp18,
                      ),
                    ),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Text(
                      review.rating.toString(),
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizer.deviceHeight1),
                Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.textColor,
                    height: 1.4,
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