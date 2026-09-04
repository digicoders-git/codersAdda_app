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
          title: Image.asset(
            'assets/images/mainLogo.png',
            height: AppSizer.deviceHeight10,
            fit: BoxFit.contain,
          ),
          backgroundColor: AppColors.cardColor,
          elevation: 0,
          centerTitle: true,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                ),
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

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight1_5,
              ),
              child: Column(
                children: [
                  // Header Text
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
                    child: Text(
                      'Choose Your Learning Path',
                      style: TextStyle(
                        color: AppColors.logoNavy,
                        fontSize: AppSizer.deviceSp15,
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
                  SizedBox(height: AppSizer.deviceHeight1_5),
                  
                  // Internship Card
                  _buildCourseCard(
                    context,
                    viewModel.courses[1],
                    AppColors.accentColor,
                  ),
                  SizedBox(height: AppSizer.deviceHeight1_5),

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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Icon/Image
              Container(
                width: AppSizer.deviceWidth14,
                height: AppSizer.deviceWidth14,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                        size: AppSizer.deviceSp18,
                      )
                    : null,
              ),
              
              SizedBox(width: AppSizer.deviceWidth3),
              
              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: TextStyle(
                        color: AppColors.logoNavy,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    
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
                          fontSize: AppSizer.deviceSp10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    
                    // Description
                    Text(
                      course.description,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: AppSizer.deviceSp12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.outline,
                          size: AppSizer.deviceSp13,
                        ),
                        SizedBox(width: AppSizer.deviceWidth1),
                        Text(
                          course.location,
                          style: TextStyle(
                            color: AppColors.outline,
                            fontSize: AppSizer.deviceSp11,
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
                size: AppSizer.deviceSp13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}