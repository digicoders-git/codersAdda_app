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
  final int initialTabIndex;
  const PdfPage({super.key, this.initialTabIndex = 0});

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
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    viewModel.setSelectedTabIndex(widget.initialTabIndex);
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
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF172554)),
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
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF172554),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
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
    if (viewModel.categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 38,
      margin: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = viewModel.selectedCategoryId == category.id;
          
          return GestureDetector(
            onTap: () => viewModel.setSelectedCategory(category),
            child: Container(
              margin: EdgeInsets.only(right: AppSizer.deviceWidth2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    '${category.name} (${category.ebookCount})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfsList(BuildContext context, List<PdfItem> pdfs) {
    if (pdfs.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration placeholder
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: AppSizer.deviceWidth50,
                    height: AppSizer.deviceWidth50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.insert_drive_file,
                    size: AppSizer.deviceWidth25,
                    color: Colors.white,
                  ),
                  Positioned(
                    top: AppSizer.deviceHeight2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PDF',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp20),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppSizer.deviceHeight4,
                    right: AppSizer.deviceWidth10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.download, color: Colors.white, size: 24),
                    ),
                  )
                ],
              ),
              SizedBox(height: AppSizer.deviceHeight3),
              Text(
                'No PDFs Found!',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF172554),
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight1_5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth10),
                child: Text(
                  'Looks like there are no PDFs available in this category.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: AppSizer.deviceSp14,
                  ),
                ),
              ),
            ],
          ),
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
        _handleCardClick(context, pdf);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Icon (Red Container)
              Container(
                width: AppSizer.deviceWidth18,
                height: AppSizer.deviceWidth18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // Light red
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: const Color(0xFFDC2626), // Red
                    size: AppSizer.deviceSp32,
                  ),
                ),
              ),
              
              SizedBox(width: AppSizer.deviceWidth4),
              
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
                        color: const Color(0xFF172554),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    
                    // PDF Description/Subtitle
                    Text(
                      pdf.description.isNotEmpty ? pdf.description : 'Unknown Details',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp13,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1),
                    
                    // PDF Meta Info
                    Row(
                      children: [
                        // File Size
                        Icon(
                          Icons.description_outlined,
                          color: const Color(0xFF64748B),
                          size: AppSizer.deviceSp14,
                        ),
                        SizedBox(width: AppSizer.deviceWidth1),
                        Text(
                          pdf.fileSize,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        
                        SizedBox(width: AppSizer.deviceWidth4),
                        
                        // Downloads/Views
                        Icon(
                          Icons.remove_red_eye_outlined,
                          color: const Color(0xFF64748B),
                          size: AppSizer.deviceSp14,
                        ),
                        SizedBox(width: AppSizer.deviceWidth1),
                        Text(
                          '${pdf.viewCount}',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppSizer.deviceHeight1_5),
                    
                    // Category & Price Tags
                    Row(
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // Light blue
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pdf.category,
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp11,
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSizer.deviceWidth2),
                        
                        // Price/Status Tag
                        Consumer<ProfileViewModel>(
                          builder: (context, profileVM, child) {
                            final isPurchased = profileVM.user?.purchaseEbookIds.contains(pdf.id) ?? false;
                            
                            if (isPurchased) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'UNLOCKED',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              );
                            }
                            
                            // User question requested: "Should we show 0 or keep dynamic?" We will show price tag like mockups.
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: pdf.isFree 
                                    ? const Color(0xFFDCFCE7) 
                                    : const Color(0xFFFEE2E2), // Light red as in mockup
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pdf.isFree ? 'FREE' : '₹${pdf.price}',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp11,
                                  fontWeight: FontWeight.w600,
                                  color: pdf.isFree 
                                      ? const Color(0xFF16A34A) 
                                      : const Color(0xFFDC2626), // Red as in mockup
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Right side download button
              Container(
                margin: EdgeInsets.only(top: AppSizer.deviceHeight2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  Icons.download_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
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
    } else {
      NavigationService.navigateTo(
        context,
        PdfDetailPage(pdf: pdf),
      );
    }
  }
}