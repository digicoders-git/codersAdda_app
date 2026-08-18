import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FAQsTab extends StatefulWidget {
  const FAQsTab({Key? key}) : super(key: key);

  @override
  State<FAQsTab> createState() => _FAQsTabState();
}

class _FAQsTabState extends State<FAQsTab> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoursePlayerViewModel>(context);
    
    if (viewModel.faqs.isEmpty) {
      return const Center(child: Text('No FAQs available for this course'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: viewModel.faqs.length,
      itemBuilder: (context, index) {
        final faq = viewModel.faqs[index];
        final isExpanded = _expandedIndex == index;
        
        return Card(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
            side: BorderSide(color: AppColors.outline),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: Key('$index-$isExpanded'),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  if (expanded) {
                    _expandedIndex = index;
                  } else {
                    if (_expandedIndex == index) {
                      _expandedIndex = null;
                    }
                  }
                });
              },
              title: Text(
                faq.question,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                color: AppColors.primaryColor
              ),
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
          ),
        );
      },
    );
  }
}