import 'dart:io';
import 'package:coders_adda_app/services/download_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'package:flutter/material.dart';

class DownloadedPdfsPage extends StatefulWidget {
  const DownloadedPdfsPage({Key? key}) : super(key: key);

  @override
  State<DownloadedPdfsPage> createState() => _DownloadedPdfsPageState();
}

class _DownloadedPdfsPageState extends State<DownloadedPdfsPage> {
  final DownloadService _downloadService = DownloadService();
  List<DownloadedItem> _resources = [];
  List<DownloadedItem> _ebooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedItems();
  }

  Future<void> _loadDownloadedItems() async {
    setState(() {
      _isLoading = true;
    });
    
    final items = await _downloadService.getDownloadedItems();
    
    // Also verify if the files exist locally
    List<DownloadedItem> validResources = [];
    List<DownloadedItem> validEbooks = [];

    for (var item in items) {
      if (await File(item.localPath).exists()) {
        if (item.type == 'resource') {
          validResources.add(item);
        } else if (item.type == 'ebook') {
          validEbooks.add(item);
        }
      } else {
        // Clean up invalid entry
        await _downloadService.removeDownloadedItem(item.id);
      }
    }

    setState(() {
      _resources = validResources;
      _ebooks = validEbooks;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(DownloadedItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: const Text('Are you sure you want to delete this downloaded file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _downloadService.removeDownloadedItem(item.id);
      _loadDownloadedItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully.')),
        );
      }
    }
  }

  void _openPdf(DownloadedItem item) {
    // Note: InAppPdfViewerPage usually takes a network URL.
    // If syncfusion_flutter_pdfviewer supports both file and network, we need to handle it.
    // Syncfusion PdfViewer.file(File(path)) is used for local files.
    // But since we are using InAppPdfViewerPage, let's pass the local path. 
    // We may need to ensure InAppPdfViewerPage can handle local file paths, or we navigate differently.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InAppPdfViewerPage(
          pdfUrl: item.localPath,
          title: item.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Downloaded PDFs',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Resources'),
              Tab(text: 'E-Books'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : TabBarView(
                children: [
                  _buildList(_resources),
                  _buildList(_ebooks),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<DownloadedItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: AppColors.onSurfaceVariant),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'No downloaded files found.',
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizer.deviceWidth4,
              vertical: AppSizer.deviceHeight1,
            ),
            leading: Container(
              padding: EdgeInsets.all(AppSizer.deviceWidth2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizer.deviceSp16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: AppSizer.deviceHeight1),
              child: Row(
                children: [
                  Icon(Icons.sd_storage, size: 14, color: AppColors.onSurfaceVariant),
                  SizedBox(width: 4),
                  Text(
                    item.size,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteItem(item),
            ),
            onTap: () => _openPdf(item),
          ),
        );
      },
    );
  }
}
