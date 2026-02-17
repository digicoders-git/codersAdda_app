// views/training_courses.dart
import 'package:coders_adda_app/models/training_courses.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/veiw_model/training_courses.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';


class TrainingCourses extends StatelessWidget {
  const TrainingCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TrainingCoursesViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Training Programs',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.cardColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer<TrainingCoursesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                children: [
                  // Header Text
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSizer.deviceHeight3),
                    child: Text(
                      'Choose Your Learning Path',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: AppSizer.deviceSp18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Summer Training Card
                  _buildCourseCard(
                    context,
                    viewModel.courses[0],
                    AppColors.primaryColor,
                  ),
                  
                  //SizedBox(height: AppSizer.deviceHeight3),
                  
                  // Internship Card
                  _buildCourseCard(
                    context,
                    viewModel.courses[1],
                    AppColors.accentColor,
                  ),

                  // Winter Training Card
                  _buildCourseCard(
                    context,
                    viewModel.courses[2],
                    AppColors.primaryColor,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    TrainingCourse course,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Provider.of<TrainingCoursesViewModel>(context, listen: false)
          .navigateToCourseDetails(context, course),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Icon/Image
              Container(
                width: AppSizer.deviceWidth20,
                height: AppSizer.deviceWidth20,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  image: course.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(course.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: course.imageUrl.isEmpty
                    ? Icon(
                        course.type == 'summer_training' 
                            ? Icons.school 
                            : Icons.work,
                        color: color,
                        size: AppSizer.deviceSp24,
                      )
                    : null,
              ),
              
              SizedBox(width: AppSizer.deviceWidth4),
              
              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: AppSizer.deviceSp18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1),
                    
                    // Duration Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth2,
                        vertical: AppSizer.deviceHeight0_5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.duration,
                        style: TextStyle(
                          color: color,
                          fontSize: AppSizer.deviceSp12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1),
                    
                    // Description
                    Text(
                      course.description,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: AppSizer.deviceSp14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight2),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.outline,
                          size: AppSizer.deviceSp16,
                        ),
                        SizedBox(width: AppSizer.deviceWidth1),
                        Text(
                          course.location,
                          style: TextStyle(
                            color: AppColors.outline,
                            fontSize: AppSizer.deviceSp12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.outline,
                size: AppSizer.deviceSp16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}