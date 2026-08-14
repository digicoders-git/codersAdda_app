import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:coders_adda_app/services/offline_pdf_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class OfflinePdfsPage extends StatefulWidget {
  @override
  _OfflinePdfsPageState createState() => _OfflinePdfsPageState();
}

class _OfflinePdfsPageState extends State<OfflinePdfsPage> {
  List<OfflinePdfModel> _downloadedPdfs = [];

  @override
  void initState() {
    super.initState();
    _loadPdfs();
  }

  void _loadPdfs() {
    setState(() {
      _downloadedPdfs = OfflinePdfService.getDownloadedPdfs();
    });
  }

  void _deletePdf(OfflinePdfModel pdf) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Download"),
        content: Text("Are you sure you want to remove this PDF from offline downloads?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Remove file from disk
      final file = File(pdf.localPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Remove from Hive
      await OfflinePdfService.removePdf(pdf.id);
      
      _loadPdfs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF removed from downloads")),
      );
    }
  }

  void _openPdf(OfflinePdfModel pdf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfflinePdfViewerPage(pdf: pdf),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _downloadedPdfs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_done, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No downloaded PDFs yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              itemCount: _downloadedPdfs.length,
              itemBuilder: (context, index) {
                final pdf = _downloadedPdfs[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(AppSizer.deviceWidth3),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.picture_as_pdf, color: Colors.red),
                    ),
                    title: Text(
                      pdf.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        pdf.category,
                        style: TextStyle(color: AppColors.primaryColor, fontSize: AppSizer.deviceSp12),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deletePdf(pdf),
                    ),
                    onTap: () => _openPdf(pdf),
                  ),
                );
              },
            ),
    );
  }
}

class OfflinePdfViewerPage extends StatelessWidget {
  final OfflinePdfModel pdf;

  OfflinePdfViewerPage({required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdf.title, style: TextStyle(fontSize: AppSizer.deviceSp16, color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SfPdfViewer.file(
        File(pdf.localPath),
        canShowScrollHead: false,
      ),
    );
  }
}
