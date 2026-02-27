import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseSyllabusPage extends StatelessWidget {
  final CoursePlayerViewModel viewModel;

  const CourseSyllabusPage({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Content'),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
      ),
      body: ChangeNotifierProvider.value(
        value: viewModel,
        child: Consumer<CoursePlayerViewModel>(
          builder: (context, vm, child) {
            final sections = vm.courseSections;
            
            if (sections.isEmpty) {
              return const Center(child: Text('No curriculum data available'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Card(
                  margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                    side: BorderSide(color: AppColors.outline),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: vm.selectedTopicId == section.id,
                    title: Text(
                      section.title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    subtitle: Text('${section.lessonCount} Lessons • ${section.duration}'),
                    trailing: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
                    children: [
                      if (section.lessons.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No lessons in this section'),
                        )
                      else
                        ...section.lessons.map((lesson) {
                          final isSelected = vm.selectedLesson?.id == lesson.id;
                          return InkWell(
                            onTap: () {
                              vm.selectLesson(lesson, section.id);
                              Navigator.pop(context); // Go back to player
                            },
                            child: Container(
                              padding: EdgeInsets.all(AppSizer.deviceWidth4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.transparent,
                                border: Border(top: BorderSide(color: AppColors.outline.withOpacity(0.3))),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: AppSizer.deviceWidth8,
                                    height: AppSizer.deviceWidth8,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                                    ),
                                    child: Icon(
                                      isSelected ? Icons.pause : Icons.play_arrow,
                                      color: isSelected ? Colors.white : AppColors.primaryColor,
                                      size: AppSizer.deviceSp16,
                                    ),
                                  ),
                                  SizedBox(width: AppSizer.deviceWidth4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson.title,
                                          style: TextStyle(
                                            fontSize: AppSizer.deviceSp14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                            color: isSelected ? AppColors.primaryColor : AppColors.textColor,
                                          ),
                                        ),
                                        SizedBox(height: AppSizer.deviceHeight1),
                                        Row(
                                          children: [
                                            Icon(Icons.schedule, size: AppSizer.deviceSp12, color: AppColors.onSurfaceVariant),
                                            SizedBox(width: AppSizer.deviceWidth1),
                                            Text(
                                              lesson.duration,
                                              style: TextStyle(fontSize: AppSizer.deviceSp12, color: AppColors.onSurfaceVariant),
                                            ),
                                            if (lesson.isLocked) ...[
                                              SizedBox(width: AppSizer.deviceWidth3),
                                              Icon(Icons.lock, size: AppSizer.deviceSp12, color: Colors.orange),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
