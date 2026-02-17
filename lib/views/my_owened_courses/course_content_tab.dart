import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseContentTab extends StatelessWidget {
  const CourseContentTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoursePlayerViewModel>(context);
    
    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: viewModel.courseSections.length,
      itemBuilder: (context, index) {
        final section = viewModel.courseSections[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
            side: BorderSide(color: AppColors.outline),
          ),
          child: ExpansionTile(
            title: Text(
              section.title,
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            trailing: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
            children: [
              if (section.topics.isEmpty)
                Padding(
  padding: EdgeInsets.all(AppSizer.deviceWidth4),
  child: Container(
    padding: EdgeInsets.all(AppSizer.deviceWidth4),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
      border: Border.all(color: AppColors.outline.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          width: AppSizer.deviceWidth8,
          height: AppSizer.deviceWidth8,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
          ),
          child: Icon(
            Icons.play_arrow,
            color: AppColors.primaryColor,
            size: AppSizer.deviceSp16,
          ),
        ),
        SizedBox(width: AppSizer.deviceWidth4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introduction to Course',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight1),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: AppSizer.deviceSp12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(
                    '10:30 mins',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth3),
                  Icon(
                    Icons.videocam,
                    size: AppSizer.deviceSp12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(
                    'Video',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.lock_open,
          color: AppColors.primaryColor,
          size: AppSizer.deviceSp18,
        ),
      ],
    ),
  ),
),
            ],
          ),
        );
      },
    );
  }
}