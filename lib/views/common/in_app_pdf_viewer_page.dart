import 'dart:io';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class InAppPdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const InAppPdfViewerPage({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<InAppPdfViewerPage> createState() => _InAppPdfViewerPageState();
}

class _InAppPdfViewerPageState extends State<InAppPdfViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  double _downloadProgress = 0;
  String? _localPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initDio();
    _preparePdf();
  }

  void _initDio() {
    // Replaced Dio with http to fix 401 unauthorized Cloudinary issues
  }

  Future<void> _preparePdf() async {
    if (widget.pdfUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Invalid PDF URL";
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final directory = await getTemporaryDirectory();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${widget.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf";
      _localPath = "${directory.path}/$fileName";

      final file = File(_localPath!);
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final request = http.Request('GET', Uri.parse(widget.pdfUrl.trim()));
      final response = await http.Client().send(request);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final total = response.contentLength ?? -1;
        int count = 0;
        final fileSink = file.openWrite();

        await for (final chunk in response.stream) {
          fileSink.add(chunk);
          count += chunk.length;
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = count / total;
            });
          }
        }
        await fileSink.close();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load PDF: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        foregroundColor: AppColors.textColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'PDF Resource',
              style: TextStyle(
                fontSize: AppSizer.deviceSp11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      value: _downloadProgress > 0 ? _downloadProgress : null),
                  SizedBox(height: 20),
                  Text(
                    _downloadProgress > 0
                        ? "Loading PDF... ${(_downloadProgress * 100).toInt()}%"
                        : "Connecting to server...",
                    style: TextStyle(fontSize: AppSizer.deviceSp14, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _preparePdf,
                          icon: Icon(Icons.refresh),
                          label: Text("Retry"),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        ),
                      ],
                    ),
                  ),
                )
              : SfPdfViewer.file(
                  File(_localPath!),
                  key: _pdfViewerKey,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                ),
    );
  }
}
