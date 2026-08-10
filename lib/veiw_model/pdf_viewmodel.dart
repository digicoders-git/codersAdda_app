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
    final bool lookingForFree = _selectedTabIndex == 0;
    return _allPdfs.where((pdf) => pdf.isFree == lookingForFree).toList();
  }

  PdfViewModel() {
    refreshData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    final priceType = _selectedTabIndex == 0 ? 'free' : 'paid';
    await Future.wait([
      fetchCategories(priceType),
      fetchPdfs(categoryId: _selectedCategoryId),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories(String priceType) async {
    final cats = await _pdfService.getEbookCategories(priceType: priceType);
    int totalCount = cats.fold(0, (sum, item) => sum + item.ebookCount);
    
    _categories = [
      PdfCategory(id: 'all', name: 'All', ebookCount: totalCount, icon: '📚'),
      ...cats
    ];
  }

  Future<void> fetchPdfs({String? categoryId}) async {
    try {
      final priceType = _selectedTabIndex == 0 ? 'free' : 'paid';
      
      if (_selectedCategoryId == 'all') {
        _allPdfs = await _pdfService.getEbooks(
          isActive: true, 
          priceType: priceType, 
          categoryId: null
        );
      } else {
        // Fetch by name as requested (API returns both free & paid)
        _allPdfs = await _pdfService.getEbooksByCategoryName(_selectedCategory);
      }
    } catch (e) {
      print('Error in fetchPdfs: $e');
    }
  }

  void setSelectedCategory(PdfCategory category) {
    if (_selectedCategoryId != category.id) {
      _selectedCategory = category.name;
      _selectedCategoryId = category.id;
      // Triggers fetchPdfs inside refreshData or just call it here
      _isLoading = true;
      notifyListeners();
      fetchPdfs(categoryId: _selectedCategoryId).then((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      _selectedCategoryId = 'all';
      _selectedCategory = 'All';
      refreshData();
    }
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
