import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/models/certificate_model.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class MyCertificatesPage extends StatefulWidget {
  const MyCertificatesPage({super.key});

  @override
  State<MyCertificatesPage> createState() => _MyCertificatesPageState();
}

class _MyCertificatesPageState extends State<MyCertificatesPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String? errorMessage;
  List<CertificateModel> courseCertificates = [];
  List<CertificateModel> quizCertificates = [];
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCertificates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCertificates() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final courseResponse = await _apiClient.get(ApiUrls.myCertificates);
      final quizResponse = await _apiClient.get(ApiUrls.getMyQuizCertificates);

      bool hasCourseSuccess = courseResponse['success'] == true;
      bool hasQuizSuccess = quizResponse['success'] == true;

      if (hasCourseSuccess || hasQuizSuccess) {
        final List<dynamic> courseList = courseResponse['certificates'] ?? [];
        final List<dynamic> quizList = quizResponse['data'] ?? [];

        setState(() {
          courseCertificates = courseList.map((c) => CertificateModel.fromJson(c)).toList();
          quizCertificates = quizList.map((c) => CertificateModel.fromJson(c)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load certificates.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadCertificate(String urlString) async {
    if (urlString.isEmpty) return;
    
    // Resolve localhost to API base URL if needed
    try {
      String resolvedUrl = urlString;
      if (resolvedUrl.contains('localhost')) {
        final uri = Uri.parse(resolvedUrl);
        final baseUri = Uri.parse(ApiUrls.baseUrl);
        resolvedUrl = resolvedUrl.replaceFirst('${uri.scheme}://${uri.host}:${uri.port}', '${baseUri.scheme}://${baseUri.host}:${baseUri.port}');
      }
      final Uri url = Uri.parse(resolvedUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open certificate download link")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching url: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Certificates',
          style: TextStyle(
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCertificates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(courseCertificates, 'Course'),
        _buildList(quizCertificates, 'Quiz'),
      ],
    );
  }

  Widget _buildList(List<CertificateModel> list, String type) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No $type certificates found',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete ${type.toLowerCase()}s to earn certificates!',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCertificates,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final cert = list[index];
          return _buildCertificateCard(cert, type);
        },
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel cert, String type) {
    final String title = type == 'Course' 
        ? (cert.course?.title ?? 'Unknown Course')
        : (cert.quiz?.title ?? 'Unknown Quiz');
        
    final String thumbnail = type == 'Course'
        ? (cert.course?.thumbnail ?? '')
        : ''; // Quizzes don't have thumbnails in the model currently

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (thumbnail.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnail,
                      width: AppSizer.deviceWidth20,
                      height: AppSizer.deviceWidth15,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: AppSizer.deviceWidth20,
                        height: AppSizer.deviceWidth15,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else
                  Container(
                    width: AppSizer.deviceWidth20,
                    height: AppSizer.deviceWidth15,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      type == 'Course' ? Icons.menu_book : Icons.quiz, 
                      color: AppColors.primaryColor
                    ),
                  ),
                SizedBox(width: AppSizer.deviceWidth4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      Text(
                        'ID: ${cert.certificateId}',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (cert.certificateUrl.isNotEmpty) {
                    _downloadCertificate(cert.certificateUrl);
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download / View Certificate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
