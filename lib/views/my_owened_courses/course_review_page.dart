import 'package:coders_adda_app/models/my_learning_courses_play_model.dart';
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
              onPressed: () {},
              icon: Icon(Icons.add, size: AppSizer.deviceSp18),
              label: Text('Write a review'),
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
          viewModel.overallRating.toString(),
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
              index < 4 ? Icons.star : Icons.star_half,
              color: AppColors.buttonColor,
              size: AppSizer.deviceSp20,
            );
          }),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        
        Text(
          'Overall Rating',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizer.deviceSp16,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        
        // Rating Distribution
        ...List.generate(5, (index) {
          final stars = 5 - index;
          final percentage = viewModel.ratingDistribution[stars] ?? 0;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
            child: Row(
              children: [
                SizedBox(
                  width: AppSizer.deviceWidth25,
                  child: Row(
                    children: [
                      ...List.generate(stars, (_) => 
                        Icon(Icons.star, color: AppColors.buttonColor, size: AppSizer.deviceSp16)),
                      ...List.generate(5 - stars, (_) => 
                        Icon(Icons.star_border, color: AppColors.buttonColor, size: AppSizer.deviceSp16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: AppSizer.deviceHeight1,
                        decoration: BoxDecoration(
                          color: AppColors.outline,
                          borderRadius: BorderRadius.circular(AppSizer.deviceWidth1),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage / 100,
                        child: Container(
                          height: AppSizer.deviceHeight1,
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor,
                            borderRadius: BorderRadius.circular(AppSizer.deviceWidth1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),
                SizedBox(
                  width: AppSizer.deviceWidth10,
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: AppSizer.deviceHeight4),
        
        Divider(color: AppColors.outline),
        SizedBox(height: AppSizer.deviceHeight3),
        
        // Reviews List
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight3),
        
        ...viewModel.reviews.map((review) => ReviewCard(review: review)).toList(),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewItem review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: AppSizer.deviceSp24,
            child: Text(
              review.initial,
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
                  review.name,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Row(
                  children: [
                    ...List.generate(review.rating, (_) => 
                      Icon(Icons.star, color: AppColors.buttonColor, size: AppSizer.deviceSp18)),
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