import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class FAQsTab extends StatelessWidget {
  const FAQsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoursePlayerViewModel>(context);
    
    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: viewModel.faqs.length,
      itemBuilder: (context, index) {
        final faq = viewModel.faqs[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
            side: BorderSide(color: AppColors.outline),
          ),
          child: ExpansionTile(
            title: Text(
              faq.question,
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            trailing: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
            children: [
              Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth4),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.textColor,
                    height: 1.5,
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