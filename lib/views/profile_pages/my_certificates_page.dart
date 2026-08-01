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

class _MyCertificatesPageState extends State<MyCertificatesPage> {
  bool isLoading = true;
  String? errorMessage;
  List<CertificateModel> certificates = [];
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiClient.get(ApiUrls.myCertificates);

      if (response['success'] == true) {
        final List<dynamic> certList = response['certificates'] ?? [];
        setState(() {
          certificates = certList.map((c) => CertificateModel.fromJson(c)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load certificates.';
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
    final Uri url = Uri.parse(urlString);
    try {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening link: $e")),
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

    if (certificates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No certificates found',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete courses to earn certificates!',
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
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          return _buildCertificateCard(cert);
        },
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel cert) {
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
                if (cert.course?.thumbnail != null && cert.course!.thumbnail.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cert.course!.thumbnail,
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
                    child: Icon(Icons.menu_book, color: AppColors.primaryColor),
                  ),
                SizedBox(width: AppSizer.deviceWidth4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.course?.title ?? 'Unknown Course',
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
