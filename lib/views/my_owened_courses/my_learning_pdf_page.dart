import 'dart:io';
import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:url_launcher/url_launcher.dart';

class MyLearningPdfViewer extends StatefulWidget {
  final MyLearningPdf pdf;

  const MyLearningPdfViewer({Key? key, required this.pdf}) : super(key: key);

  @override
  State<MyLearningPdfViewer> createState() => _MyLearningPdfViewerState();
}

class _MyLearningPdfViewerState extends State<MyLearningPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late Dio _dio;
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
    _dio = Dio();
    // Special configuration to bypass SSL Certificate Verification
    // This fixes the CERTIFICATE_VERIFY_FAILED error for sites like nsi.gov.in
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Future<void> _preparePdf() async {
    if (widget.pdf.downloadUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Invalid PDF URL";
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final directory = await getTemporaryDirectory();
      final fileName = "${widget.pdf.id}_${widget.pdf.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf";
      _localPath = "${directory.path}/$fileName";

      final file = File(_localPath!);
      if (await file.exists()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _dio.download(
        widget.pdf.downloadUrl,
        _localPath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = count / total;
            });
          }
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load PDF: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pdf.title,
          style: TextStyle(fontSize: AppSizer.deviceSp18),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: _downloadProgress > 0 ? _downloadProgress : null),
                  SizedBox(height: 20),
                  Text(
                    _downloadProgress > 0 
                      ? "Loading PDF... ${(_downloadProgress * 100).toInt()}%" 
                      : "Connecting to server...",
                    style: TextStyle(fontSize: AppSizer.deviceSp14),
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
                        ElevatedButton(onPressed: _preparePdf, child: Text("Retry")),
                      ],
                    ),
                  ),
                )
              : SfPdfViewer.file(
                  File(_localPath!),
                  key: _pdfViewerKey,
                ),
    );
  }
}