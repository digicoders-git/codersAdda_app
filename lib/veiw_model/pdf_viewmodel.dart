import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/services/pdf_service.dart';
import 'package:flutter/material.dart';

class PdfViewModel with ChangeNotifier {
  List<PdfItem> _allPdfs = [];
  List<PdfCategory> _categories = [];
  String _selectedCategory = 'All';
  String _selectedCategoryId = 'all';
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  final PdfService _pdfService = PdfService();

  List<PdfItem> get allPdfs => _allPdfs;
  List<PdfCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get selectedCategoryId => _selectedCategoryId;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;

  List<PdfItem> get freePdfs => _allPdfs.where((pdf) => pdf.isFree).toList();
  List<PdfItem> get paidPdfs => _allPdfs.where((pdf) => !pdf.isFree).toList();

  List<PdfItem> get filteredPdfs {
    return _selectedTabIndex == 0 ? freePdfs : paidPdfs;
  }

  PdfViewModel() {
    refreshData();
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchCategories(),
      fetchPdfs(categoryId: _selectedCategoryId),
    ]);
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    
    final cats = await _pdfService.getEbookCategories();
    int totalCount = cats.fold(0, (sum, item) => sum + item.ebookCount);
    
    _categories = [
      PdfCategory(id: 'all', name: 'All', ebookCount: totalCount, icon: '📚'),
      ...cats
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPdfs({String? categoryId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final String? catId = (categoryId == null || categoryId == 'all') ? null : categoryId;
      
      // Fetch both free and paid PDFs as per requirement
      final freeResults = await _pdfService.getEbooks(isActive: true, priceType: 'free', categoryId: catId);
      final paidResults = await _pdfService.getEbooks(isActive: true, priceType: 'paid', categoryId: catId);
      
      _allPdfs = [...freeResults, ...paidResults];
    } catch (e) {
      print('Error in fetchPdfs: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedCategory(PdfCategory category) {
    _selectedCategory = category.name;
    _selectedCategoryId = category.id;
    fetchPdfs(categoryId: _selectedCategoryId);
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
        categoryId: _allPdfs[index].categoryId,
        isFree: _allPdfs[index].isFree,
        priceType: _allPdfs[index].priceType,
        price: _allPdfs[index].price,
        downloadUrl: _allPdfs[index].downloadUrl,
        thumbnail: _allPdfs[index].thumbnail,
        viewCount: _allPdfs[index].viewCount + 1,
        uploadedAt: _allPdfs[index].uploadedAt,
        author: _allPdfs[index].author,
        isActive: _allPdfs[index].isActive,
      );
      notifyListeners();
    }
  }
}
