import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/pdf_viewmodel.dart';
import 'package:coders_adda_app/views/buy_new_pdf_pages/pdf_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/views/navigation_class.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class PdfPage extends StatefulWidget {
  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> with SingleTickerProviderStateMixin {
  late PdfViewModel viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    viewModel = PdfViewModel();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != viewModel.selectedTabIndex) {
      viewModel.setSelectedTabIndex(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavigation()),
                );
              }
            },
          ),
          title: Text(
            'PDF Resources',
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
            tabs: [
              Tab(text: 'Free PDFs'),
              Tab(text: 'Premium PDFs'),
            ],
            onTap: (index) {
              viewModel.setSelectedTabIndex(index);
            },
          ),
        ),
        body: Consumer<PdfViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    _buildCategoryFilter(viewModel),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: () => viewModel.refreshData(),
                            child: _buildPdfsList(context, viewModel.freePdfs),
                          ),
                          RefreshIndicator(
                            onRefresh: () => viewModel.refreshData(),
                            child: _buildPdfsList(context, viewModel.paidPdfs),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(PdfViewModel viewModel) {
    return Container(
      height: AppSizer.deviceHeight8,
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = viewModel.selectedCategoryId == category.id;
          
          return Builder(
            builder: (chipContext) {
              return Container(
                margin: EdgeInsets.only(
                  right: AppSizer.deviceWidth2,
                  top: AppSizer.deviceHeight1,
                  bottom: AppSizer.deviceHeight1,
                ),
                child: FilterChip(
                  label: Text(
                    '${category.name} (${category.ebookCount})',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      color: isSelected ? Colors.white : AppColors.textColor,
                    ),
                  ),
                  selected: isSelected,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primaryColor,
                  checkmarkColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryColor : AppColors.outline,
                    ),
                  ),
                  onSelected: (selected) {
                    viewModel.setSelectedCategory(category);
                    Scrollable.ensureVisible(
                      chipContext,
                      alignment: 0.5,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPdfsList(BuildContext context, List<PdfItem> pdfs) {
    if (pdfs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: AppSizer.deviceSp64,
              color: Colors.grey,
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'No PDFs Found',
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'Try selecting a different category',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: pdfs.length,
      itemBuilder: (context, index) {
        final pdf = pdfs[index];
        return _buildPdfCard(context, pdf);
      },
    );
  }

  Widget _buildPdfCard(BuildContext context, PdfItem pdf) {
    return GestureDetector(
      onTap: () {
        // Card click pe PDF viewer open karega for free PDFs
        _handleCardClick(context, pdf);
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
        child: Padding(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Row(
            children: [
              // PDF Icon
              Container(
                width: AppSizer.deviceWidth15,
                height: AppSizer.deviceWidth15,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                ),
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: AppSizer.deviceSp24,
                  ),
                ),
              ),
              
              SizedBox(width: AppSizer.deviceWidth3),
              
              // PDF Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PDF Title
                    Text(
                      pdf.title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    
                    // PDF Description
                    Text(
                      pdf.description,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1),
                    
                    // PDF Meta Info
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
                              pdf.fileSize,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: AppSizer.deviceWidth3),
                        
                        // Downloads
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: AppColors.onSurfaceVariant,
                              size: AppSizer.deviceSp14,
                            ),
                            SizedBox(width: AppSizer.deviceWidth1),
                            Text(
                              '${pdf.viewCount}',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: AppSizer.deviceWidth3),
                        
                        // Category
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth2,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pdf.category,
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp12,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                  SizedBox(width: AppSizer.deviceWidth4,),         
                  
                  Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      final isPurchased = profileVM.user?.purchaseEbookIds.contains(pdf.id) ?? false;
                      
                      if (isPurchased) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer.deviceWidth2,
                            vertical: AppSizer.deviceHeight0_5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_open, size: AppSizer.deviceSp12, color: AppColors.successColor),
                              SizedBox(width: 4),
                              Text(
                                'UNLOCKED',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth2,
                          vertical: AppSizer.deviceHeight0_5,
                        ),
                        decoration: BoxDecoration(
                          color: pdf.isFree 
                              ? AppColors.successColor.withOpacity(0.1)
                              : AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pdf.isFree ? 'FREE' : '₹${pdf.price}',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            fontWeight: FontWeight.bold,
                            color: pdf.isFree 
                                ? AppColors.successColor 
                                : AppColors.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  
                 
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              
              
            ],
          ),
        ),
      ),
    );
  }

  void _handleCardClick(BuildContext context, PdfItem pdf) {
    if (pdf.isFree) {
      NavigationService.navigateTo(
        context,
        PdfDetailPage(pdf: pdf),
      );
    } else {
      NavigationService.navigateTo(
        context,
        PdfDetailPage(pdf: pdf),
      );
    }
  }


  void _handlePdfAction(BuildContext context, PdfItem pdf) {
    if (pdf.isFree) {
      NavigationService.navigateTo(
        context,
        PdfDetailPage(pdf: pdf),
      );
      // Download free PDF
      //_downloadPdf(context, pdf);
    } else {
      // Navigate to PDF detail page for paid PDFs
      NavigationService.navigateTo(
        context,
        PdfDetailPage(pdf: pdf),
      );
    }
  }
}