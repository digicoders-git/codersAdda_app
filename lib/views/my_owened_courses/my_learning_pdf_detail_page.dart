import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

class MyPdfDetailPage extends StatelessWidget {
  final String pdfId;

  MyPdfDetailPage({required this.pdfId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDF Details',
          style: TextStyle(fontSize: AppSizer.deviceSp20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AppSizer.deviceHeight30,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
                border: Border.all(color: AppColors.outline),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: AppSizer.deviceWidth15,
                    ),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      'PDF Preview',
                      style: TextStyle(fontSize: AppSizer.deviceSp14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'Flutter Architecture Guide',
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'File size: 3.2 MB',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: AppSizer.deviceSp14,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            FilledButton(
              onPressed: () {},
              child: Text(
                'Download PDF',
                style: TextStyle(fontSize: AppSizer.deviceSp14),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            // OutlinedButton(
            //   onPressed: () {},
            //   child: Text(
            //     'Buy Individual - ₹99',
            //     style: TextStyle(fontSize: AppSizer.deviceSp14),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
