
import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

class MyLearningPdfViewer extends StatelessWidget {
  final MyLearningPdf pdf;

  const MyLearningPdfViewer({Key? key, required this.pdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pdf.title,
          style: TextStyle(fontSize: AppSizer.deviceSp20),
        ),
      ),
      body: Column(
        children: [
          // PDF Info
          Container(
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            color: AppColors.surfaceVariant,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizer.deviceWidth3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: AppSizer.deviceSp24,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdf.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizer.deviceSp16,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight0_5),
                      Text(
                        'File Size: ${pdf.size}',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: AppSizer.deviceSp12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // PDF Viewer Placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: AppSizer.deviceSp64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: AppSizer.deviceHeight2),
                  Text(
                    'PDF Viewer',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Text(
                    'PDF content would be displayed here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: AppSizer.deviceHeight3),
                  ElevatedButton(
                    onPressed: () {
                      // Open PDF in external viewer
                    },
                    child: Text(
                      'Open PDF',
                      style: TextStyle(fontSize: AppSizer.deviceSp14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}