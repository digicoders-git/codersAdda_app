import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/services/pdf_service.dart';
import 'package:flutter/material.dart';

class PdfViewModel with ChangeNotifier {
  List<PdfItem> _allPdfs = [];
  List<PdfCategory> _categories = [];
  String _selectedCategory = 'All';
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  final PdfService _pdfService = PdfService();

  List<PdfItem> get allPdfs => _allPdfs;
  List<PdfCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;

  List<PdfItem> get freePdfs => _allPdfs.where((pdf) => pdf.isFree).toList();
  List<PdfItem> get paidPdfs => _allPdfs.where((pdf) => !pdf.isFree).toList();

  List<PdfItem> get filteredPdfs {
    if (_selectedCategory == 'All') {
      return _selectedTabIndex == 0 ? freePdfs : paidPdfs;
    }
    
    final pdfs = _selectedTabIndex == 0 ? freePdfs : paidPdfs;
    return pdfs.where((pdf) => pdf.category == _selectedCategory).toList();
  }

  PdfViewModel() {
    fetchCategories();
    _loadDemoData();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    
    final cats = await _pdfService.getEbookCategories();
    _categories = [
      PdfCategory(id: 'all', name: 'All', pdfCount: 0, icon: '📚'),
      ...cats
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void _loadDemoData() {
    // Demo PDFs
    _allPdfs = [
      // Free PDFs
      PdfItem(
        id: '1',
        title: 'Flutter Complete Guide',
        description: 'Complete guide to Flutter development with Dart programming',
        fileSize: '2.4 MB',
        category: 'Programming',
        isFree: true,
        price: 0,
        downloadUrl: 'https://example.com/pdf1.pdf',
        thumbnail: '',
        viewCount: 1500,
        uploadedAt: DateTime.now().subtract(Duration(days: 30)),
        author: 'Sarah Wilson',
      ),
      PdfItem(
        id: '2',
        title: 'JavaScript Basics',
        description: 'Learn JavaScript fundamentals for web development',
        fileSize: '1.8 MB',
        category: 'Programming',
        isFree: true,
        price: 0,
        downloadUrl: 'https://example.com/pdf2.pdf',
        thumbnail: '',
        viewCount: 2300,
        uploadedAt: DateTime.now().subtract(Duration(days: 45)),
        author: 'Mike Chen',
      ),
      PdfItem(
        id: '3',
        title: 'UI/UX Design Principles',
        description: 'Essential design principles for modern applications',
        fileSize: '3.2 MB',
        category: 'Design',
        isFree: true,
        price: 0,
        downloadUrl: 'https://example.com/pdf3.pdf',
        thumbnail: '',
        viewCount: 1800,
        uploadedAt: DateTime.now().subtract(Duration(days: 60)),
        author: 'Emily Davis',
      ),
      PdfItem(
        id: '4',
        title: 'Data Science Handbook',
        description: 'Comprehensive guide to data science and machine learning',
        fileSize: '4.1 MB',
        category: 'Science',
        isFree: true,
        price: 0,
        downloadUrl: 'https://example.com/pdf4.pdf',
        thumbnail: '',
        viewCount: 1200,
        uploadedAt: DateTime.now().subtract(Duration(days: 25)),
        author: 'Dr. Anjali Sharma',
      ),

      // Paid PDFs
      PdfItem(
        id: '5',
        title: 'Advanced Flutter Architecture',
        description: 'Master advanced Flutter architecture patterns and best practices',
        fileSize: '3.5 MB',
        category: 'Programming',
        isFree: false,
        price: 299,
        downloadUrl: 'https://example.com/pdf5.pdf',
        thumbnail: '',
        viewCount: 800,
        uploadedAt: DateTime.now().subtract(Duration(days: 20)),
        author: 'Sarah Wilson',
      ),
      PdfItem(
        id: '6',
        title: 'React Native Masterclass',
        description: 'Complete guide to React Native mobile development',
        fileSize: '2.9 MB',
        category: 'Programming',
        isFree: false,
        price: 249,
        downloadUrl: 'https://example.com/pdf6.pdf',
        thumbnail: '',
        viewCount: 950,
        uploadedAt: DateTime.now().subtract(Duration(days: 15)),
        author: 'Raj Kumar',
      ),
      PdfItem(
        id: '7',
        title: 'Digital Marketing Strategy',
        description: 'Advanced digital marketing strategies for business growth',
        fileSize: '2.7 MB',
        category: 'Business',
        isFree: false,
        price: 199,
        downloadUrl: 'https://example.com/pdf7.pdf',
        thumbnail: '',
        viewCount: 650,
        uploadedAt: DateTime.now().subtract(Duration(days: 10)),
        author: 'Priya Singh',
      ),
      PdfItem(
        id: '8',
        title: 'Machine Learning Algorithms',
        description: 'Deep dive into machine learning algorithms and implementations',
        fileSize: '4.8 MB',
        category: 'Science',
        isFree: false,
        price: 399,
        downloadUrl: 'https://example.com/pdf8.pdf',
        thumbnail: '',
        viewCount: 550,
        uploadedAt: DateTime.now().subtract(Duration(days: 5)),
        author: 'Dr. Anjali Sharma',
      ),
    ];

    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void incrementDownloadCount(String pdfId) {
    final index = _allPdfs.indexWhere((pdf) => pdf.id == pdfId);
    if (index != -1) {
      _allPdfs[index] = PdfItem(
        id: _allPdfs[index].id,
        title: _allPdfs[index].title,
        description: _allPdfs[index].description,
        fileSize: _allPdfs[index].fileSize,
        category: _allPdfs[index].category,
        isFree: _allPdfs[index].isFree,
        price: _allPdfs[index].price,
        downloadUrl: _allPdfs[index].downloadUrl,
        thumbnail: _allPdfs[index].thumbnail,
        viewCount: _allPdfs[index].viewCount + 1,
        uploadedAt: _allPdfs[index].uploadedAt,
        author: _allPdfs[index].author,
      );
      notifyListeners();
    }
  }
}