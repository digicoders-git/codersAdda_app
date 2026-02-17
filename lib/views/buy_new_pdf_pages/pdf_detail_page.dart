import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/course_purchase_page.dart';
import 'package:flutter/material.dart';

class PdfDetailPage extends StatelessWidget {
  final PdfItem pdf;

  const PdfDetailPage({Key? key, required this.pdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDF Details',
          style: TextStyle(fontSize: AppSizer.deviceSp20),
        ),
        actions: [
         // IconButton(
            //icon: Icon(Icons.share),
           // onPressed: _sharePdf,
         // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF Header
            _buildPdfHeader(),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            // PDF Description
            _buildPdfDescription(),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            // PDF Details
            _buildPdfDetails(),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            // Author Info
            _buildAuthorInfo(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionButton(context),
    );
  }

  Widget _buildPdfHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Row(
          children: [
            // PDF Icon
            Container(
              width: AppSizer.deviceWidth20,
              height: AppSizer.deviceWidth20,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
              ),
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: AppSizer.deviceSp32,
                ),
              ),
            ),
            
            SizedBox(width: AppSizer.deviceWidth4),
            
            // PDF Title and Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pdf.title,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: AppSizer.deviceHeight1),
                  
                  Row(
                    children: [
                      // File Size
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: AppColors.onSurfaceVariant,
                            size: AppSizer.deviceSp14,
                          ),
                          SizedBox(width: AppSizer.deviceWidth1),
                          Text(
                            pdf.fileSize,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(width: AppSizer.deviceWidth4),
                      
                      // Downloads
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            color: AppColors.onSurfaceVariant,
                            size: AppSizer.deviceSp14,
                          ),
                          SizedBox(width: AppSizer.deviceWidth1),
                          Text(
                            '${pdf.viewCount} views',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Price Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight1,
              ),
              decoration: BoxDecoration(
                color: pdf.isFree 
                    ? AppColors.successColor.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pdf.isFree ? 'FREE' : '₹${pdf.price}',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.bold,
                  color: pdf.isFree 
                      ? AppColors.successColor 
                      : AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: AppSizer.deviceHeight1),
        
        Text(
          pdf.description,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPdfDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF Details',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: AppSizer.deviceHeight2),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Category', pdf.category, Icons.category),
                _buildDetailItem('File Size', pdf.fileSize, Icons.description),
                _buildDetailItem('Format', 'PDF', Icons.format_shapes),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: AppSizer.deviceSp20),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Row(
          children: [
            // Author Avatar
            Container(
              width: AppSizer.deviceWidth12,
              height: AppSizer.deviceWidth12,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pdf.author.split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizer.deviceSp14,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: AppSizer.deviceWidth3),
            
            // Author Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Author',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight0_5),
                  Text(
                    pdf.author,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: pdf.isFree
              ? FilledButton(
                  onPressed: () {
                    // FREE PDF - Direct download
                    _downloadPdf(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                  ),
                  child: Text(
                    'VIEW PDF',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : FilledButton(
                  onPressed: () {
                    // PAID PDF - Navigate to CourseCheckoutPage
                    // Create a Course object from PdfItem for checkout
                    final courseForCheckout = Course(
                      id: pdf.id,
                      title: pdf.title,
                      description: pdf.description,
                      instructor: pdf.author,
                      price: pdf.price,
                      thumbnail: pdf.thumbnail,
                      category: pdf.category,
                      technology: pdf.category,
                      isFree: false,
                      rating: 4.5,
                      totalStudents: pdf.viewCount,
                      duration: 'Lifetime Access',
                      totalLessons: 1,
                      createdAt: pdf.uploadedAt,
                    );
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseCheckoutPage(course: courseForCheckout),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                  ),
                  child: Text(
                    'BUY NOW - ₹${pdf.price}',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _downloadPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('VIEW PDF'),
        content: Text('Do you want to view pdf "${pdf.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('View "${pdf.title}"...'),
                  backgroundColor: AppColors.successColor,
                ),
              );
              // Implement actual download logic
            },
            child: Text('View'),
          ),
        ],
      ),
    );
  }

//   void _sharePdf() {
//     // Implement share functionality
//     // You can use share_plus package
//   }
 }