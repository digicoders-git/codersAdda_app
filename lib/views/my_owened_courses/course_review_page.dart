import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
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
                final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
                final courseVM = Provider.of<CoursePlayerViewModel>(context, listen: false);
                
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizer.deviceWidth4),
                    ),
                  ),
                  builder: (bottomSheetContext) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: profileVM),
                      ChangeNotifierProvider.value(value: courseVM),
                    ],
                    child: const WriteReviewSheet(),
                  ),
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

class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({Key? key}) : super(key: key);

  @override
  _WriteReviewSheetState createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizer.deviceWidth4,
        right: AppSizer.deviceWidth4,
        top: AppSizer.deviceHeight3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Write a Review',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => 
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth1),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.buttonColor,
                    size: AppSizer.deviceSp32,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience with this course...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
              ),
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () async {
                if (_rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a rating')),
                  );
                  return;
                }
                
                setState(() => _isSubmitting = true);
                
                final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
                final studentName = profileVM.user?.name ?? '';
                
                final viewModel = Provider.of<CoursePlayerViewModel>(context, listen: false);
                final success = await viewModel.submitReview(
                  _rating,
                  _commentController.text.trim(),
                  studentName: studentName,
                );
                
                if (mounted) {
                  setState(() => _isSubmitting = false);
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted! It will be visible after admin approval.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to submit review')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Submit Review',
                      style: TextStyle(color: Colors.white, fontSize: AppSizer.deviceSp16),
                    ),
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),
        ],
      ),
    );
  }
}