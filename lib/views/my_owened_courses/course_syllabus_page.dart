import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/topic_lectures_page.dart';
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: viewModel,
        child: Consumer<CoursePlayerViewModel>(
          builder: (context, vm, child) {
            if (vm.isCurriculumLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: AppSizer.deviceHeight2),
                    const Text('Loading topics...'),
                  ],
                ),
              );
            }

            final topics = vm.curriculumTopics;

            if (topics.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books_outlined, size: 64, color: AppColors.onSurfaceVariant),
                    SizedBox(height: AppSizer.deviceHeight2),
                    Text(
                      'No topics available for this course',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: AppSizer.deviceSp16),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth4, vertical: AppSizer.deviceHeight1),
                  color: AppColors.primaryColor.withOpacity(0.06),
                  child: Row(
                    children: [
                      Icon(Icons.format_list_bulleted, color: AppColors.primaryColor, size: 20),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Text(
                        '${topics.length} Topic${topics.length > 1 ? 's' : ''} in this course',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizer.deviceSp14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
                        elevation: 2,
                        shadowColor: AppColors.primaryColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.outline.withOpacity(0.4)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSizer.deviceWidth4,
                              vertical: AppSizer.deviceHeight1),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            topic.topic,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to view lectures',
                            style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: AppColors.onSurfaceVariant),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.play_lesson_outlined,
                                color: AppColors.primaryColor, size: 20),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TopicLecturesPage(
                                  topic: topic,
                                  viewModel: vm,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
