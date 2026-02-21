import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/course_purchase_page.dart';
import 'package:coders_adda_app/services/pdf_service.dart';
import 'package:flutter/material.dart';

class PdfDetailPage extends StatefulWidget {
  final PdfItem pdf;

  const PdfDetailPage({Key? key, required this.pdf}) : super(key: key);

  @override
  State<PdfDetailPage> createState() => _PdfDetailPageState();
}

class _PdfDetailPageState extends State<PdfDetailPage> {
  late PdfItem currentPdf;
  bool isLoading = true;
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    currentPdf = widget.pdf;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final detailedPdf = await _pdfService.getEbookDetails(widget.pdf.id);
      if (detailedPdf != null && mounted) {
        setState(() {
          currentPdf = detailedPdf;
          isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDF Details',
          style: TextStyle(fontSize: AppSizer.deviceSp20),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
      bottomNavigationBar: isLoading ? null : _buildBottomActionButton(context),
    );
  }

  Widget _buildPdfHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Row(
          children: [
            // PDF Icon / Thumbnail
            Container(
              width: AppSizer.deviceWidth20,
              height: AppSizer.deviceWidth20,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                image: currentPdf.thumbnail.isNotEmpty 
                  ? DecorationImage(
                      image: NetworkImage(currentPdf.thumbnail),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: currentPdf.thumbnail.isEmpty 
                ? Center(
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: AppSizer.deviceSp32,
                    ),
                  )
                : null,
            ),
            
            SizedBox(width: AppSizer.deviceWidth4),
            
            // PDF Title and Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPdf.title,
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
                            currentPdf.fileSize,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(width: AppSizer.deviceWidth4),
                      
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth2,
                          vertical: AppSizer.deviceHeight0_5,
                        ),
                        decoration: BoxDecoration(
                          color: currentPdf.isActive 
                            ? AppColors.successColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentPdf.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp10,
                            color: currentPdf.isActive 
                              ? AppColors.successColor 
                              : Colors.grey,
                          ),
                        ),
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
                color: currentPdf.isFree 
                    ? AppColors.successColor.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentPdf.isFree ? 'FREE' : '₹${currentPdf.price}',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.bold,
                  color: currentPdf.isFree 
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
          currentPdf.description,
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
                _buildDetailItem('Category', currentPdf.category, Icons.category),
                _buildDetailItem('File Size', currentPdf.fileSize, Icons.description),
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
                  currentPdf.author.isNotEmpty 
                      ? currentPdf.author.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                      : '?',
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
                    currentPdf.author,
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
          child: currentPdf.isFree
              ? FilledButton(
                  onPressed: () {
                    // FREE PDF - Enroll for free
                    _enrollForFree(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                  ),
                  child: Text(
                    'ENROLL FOR FREE',
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
                      id: currentPdf.id,
                      title: currentPdf.title,
                      description: currentPdf.description,
                      instructor: currentPdf.author,
                      price: currentPdf.price,
                      thumbnail: currentPdf.thumbnail,
                      category: currentPdf.category,
                      technology: currentPdf.category,
                      isFree: false,
                      rating: 4.5,
                      totalStudents: currentPdf.viewCount,
                      duration: 'Lifetime Access',
                      totalLessons: 1,
                      createdAt: currentPdf.uploadedAt,
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
                    'BUY NOW - ₹${currentPdf.price}',
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

  void _enrollForFree(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _pdfService.enrollFreeEbook(currentPdf.id);
      
      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enrolled successfully!'),
              backgroundColor: AppColors.successColor,
            ),
          );
          // After success, you might want to navigate to PDF viewer or update UI
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Enrollment failed'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
