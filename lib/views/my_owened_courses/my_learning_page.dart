import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_viewmodel.dart';
import 'package:coders_adda_app/views/buy_new_pdf_pages/pdf_page.dart';
import 'package:coders_adda_app/views/home_pages/all_cource_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_pdf_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_player_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/views/navigation_class.dart';

class MyLearningPage extends StatefulWidget {
  final int initialTabIndex;

  const MyLearningPage({super.key, this.initialTabIndex = 0});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage> with SingleTickerProviderStateMixin {
  late MyLearningViewModel viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    viewModel = MyLearningViewModel()..selectCategory(widget.initialTabIndex);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != viewModel.selectedCategoryIndex) {
      viewModel.selectCategory(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<MyLearningViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
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
              title: Image.asset(
                'assets/images/mainLogo.png',
                height: AppSizer.deviceHeight10,
                fit: BoxFit.contain,
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(AppSizer.deviceHeight7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelColor: const Color(0xFF0052FF),
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.5, color: Color(0xFF0052FF)),
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      labelStyle: TextStyle(
                        fontSize: AppSizer.deviceSp12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: AppSizer.deviceSp12,
                        fontWeight: FontWeight.w500,
                      ),
                      labelPadding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth3),
                      tabs: const [
                        Tab(icon: Icon(Icons.school, size: 24), text: 'Free Courses'),
                        Tab(icon: Icon(Icons.workspace_premium, size: 24), text: 'Premium Courses'),
                        Tab(icon: Icon(Icons.menu_book, size: 24), text: 'Free E-Books'),
                        Tab(icon: Icon(Icons.library_books, size: 24), text: 'Premium E-Books'),
                      ],
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () => viewModel.fetchMyLibrary(),
                  child: _buildCoursesList(
                    context,
                    viewModel.freeCourses,
                    'Free Courses',
                    tabType: 0,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () => viewModel.fetchMyLibrary(),
                  child: _buildCoursesList(
                    context,
                    viewModel.premiumCourses,
                    'Premium Courses',
                    tabType: 1,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () => viewModel.fetchMyLibrary(),
                  child: _buildPdfsList(
                    context,
                    viewModel.freePdfs,
                    'Free E-Books',
                    tabType: 2,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () => viewModel.fetchMyLibrary(),
                  child: _buildPdfsList(
                    context,
                    viewModel.premiumPdfs,
                    'Premium E-Books',
                    tabType: 3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // _buildTabButtons and _buildSelectedContent removed as we now use TabBar and TabBarView

  Widget _buildCoursesList(
    BuildContext context,
    List<MyLearningCourse> courses,
    String title, {
    required int tabType,
  }) {
    if (courses.isEmpty) {
      if (tabType == 0) {
        return _buildEmptyState(
          context: context,
          icon: Icons.school,
          title: 'No Free Courses Yet',
          message: 'Looks like you haven\'t enrolled in any\nfree courses yet.',
          buttonText: 'Explore Free Courses',
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllCoursePage(initialIndex: 0)),
            );
          },
        );
      } else {
        return _buildEmptyState(
          context: context,
          icon: Icons.workspace_premium,
          title: 'No Premium Courses Yet',
          message: 'Looks like you haven\'t enrolled in any\npremium courses yet.',
          buttonText: 'Explore Premium Courses',
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllCoursePage(initialIndex: 1)),
            );
          },
        );
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(context, course);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, MyLearningCourse course) {
    final double rating = course.rating > 0 ? course.rating : 0.0;
    final int totalRatings = 0; // The UI doesn't seem to display this in the circle, but kept for compatibility
    final String duration = course.duration.isNotEmpty ? course.duration : "0h 0m";
    final int totalVideos = course.totalVideos > 0 ? course.totalVideos : 0;
    final String category = course.technology.isNotEmpty ? course.technology : "Course";

    return GestureDetector(
      onTap: () {
        // Navigate to course player
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyLearningCoursePlayer(courseId: course.id)),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
            color: AppColors.cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Thumbnail with Overlay
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: AppSizer.deviceHeight22,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizer.deviceWidth4),
                        topRight: Radius.circular(AppSizer.deviceWidth4),
                      ),
                      image: course.thumbnail.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(course.thumbnail),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: course.thumbnail.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: AppColors.primaryColor,
                              size: AppSizer.deviceSp32,
                            ),
                          )
                        : null,
                  ),

                  // Gradient Overlay
                  Container(
                    width: double.infinity,
                    height: AppSizer.deviceHeight22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizer.deviceWidth4),
                        topRight: Radius.circular(AppSizer.deviceWidth4),
                      ),
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),

                  // Progress Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: Colors.black.withOpacity(0.4),
                      color: course.progress == 1.0
                          ? AppColors.successColor
                          : AppColors.primaryColor,
                      minHeight: AppSizer.deviceHeight0_5,
                    ),
                  ),

                  // Progress Percentage
                  if (course.progress > 0)
                    Positioned(
                      bottom: AppSizer.deviceHeight1,
                      right: AppSizer.deviceWidth3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth2,
                          vertical: AppSizer.deviceHeight0_5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(course.progress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizer.deviceSp12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Category Badge
                  Positioned(
                    top: AppSizer.deviceHeight1,
                    left: AppSizer.deviceWidth3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth3,
                        vertical: AppSizer.deviceHeight0_5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizer.deviceSp13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Completed Badge
                  if (course.progress == 1.0)
                    Positioned(
                      top: AppSizer.deviceHeight1,
                      right: AppSizer.deviceWidth3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth3,
                          vertical: AppSizer.deviceHeight0_5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: AppSizer.deviceSp12,
                            ),
                            SizedBox(width: AppSizer.deviceWidth1),
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSizer.deviceSp10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Course Details
              Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Instructor
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.onSurfaceVariant,
                          size: AppSizer.deviceSp16,
                        ),
                        SizedBox(width: AppSizer.deviceWidth2),
                        Expanded(
                          child: Text(
                            'By ${course.instructor}',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp14,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Course Stats Row
                    Row(
                      children: [
                        // Rating
                        _buildStatItem(
                          Icons.star,
                          rating.toString(),
                          AppColors.buttonColor,
                        ),

                        SizedBox(width: AppSizer.deviceWidth3),

                        // Duration
                        _buildStatItem(
                          Icons.access_time,
                          duration,
                          AppColors.buttonColor,
                        ),

                        SizedBox(width: AppSizer.deviceWidth3),

                        // Videos Count
                        _buildStatItem(
                          Icons.video_library,
                          '$totalVideos videos',
                          AppColors.buttonColor,
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight2),

                    // Progress and Action Button
                    Container(
                      padding: EdgeInsets.all(AppSizer.deviceWidth3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth3,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Progress Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp12,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: AppSizer.deviceHeight0_5),
                                Text(
                                  '${(course.progress * 100).toInt()}% completed',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Button
                          Container(
                            width: AppSizer.deviceWidth14,
                            height: AppSizer.deviceWidth14,
                            decoration: BoxDecoration(
                              color: course.progress == 1.0
                                  ? AppColors.successColor
                                  : AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              course.progress == 0.0
                                  ? Icons.play_arrow
                                  : course.progress == 1.0
                                  ? Icons.replay
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: AppSizer.deviceSp18,
                            ),
                          ),
                        ],
                      ),
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

  // Helper widget for course stats
  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizer.deviceHeight1,
          horizontal: AppSizer.deviceWidth2,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizer.deviceSp16,
              height: AppSizer.deviceSp16,
              child: Icon(icon, color: color, size: AppSizer.deviceSp16),
            ),
            SizedBox(width: AppSizer.deviceWidth1),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfsList(
    BuildContext context,
    List<MyLearningPdf> pdfs,
    String title, {
    required int tabType,
  }) {
    if (pdfs.isEmpty) {
      if (tabType == 2) {
        return _buildEmptyState(
          context: context,
          icon: Icons.menu_book,
          title: 'No Free E-Books Yet',
          message: 'Looks like you haven\'t accessed any\nfree e-books yet.',
          buttonText: 'Explore Free E-Books',
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PdfPage(initialTabIndex: 0)),
            );
          },
        );
      } else {
        return _buildEmptyState(
          context: context,
          icon: Icons.library_books,
          title: 'No Premium E-Books Yet',
          message: 'Looks like you haven\'t purchased any\npremium e-books yet.',
          buttonText: 'Explore Premium E-Books',
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PdfPage(initialTabIndex: 1)),
            );
          },
        );
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),

          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizer.deviceHeight3,
              crossAxisSpacing: AppSizer.deviceWidth3,
              childAspectRatio: 3 / 5.2,
            ),
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final pdf = pdfs[index];
              return _buildPdfCard(context, pdf);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context, MyLearningPdf pdf) {

    return GestureDetector(
      onTap: () {
        // Navigate to PDF detailed page for full view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyLearningPdfViewer(pdf: pdf),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Icon with Badge
              Stack(
                children: [
                  Container(
                    height: AppSizer.deviceHeight15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSizer.deviceWidth3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: AppSizer.deviceSp40,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Free/Premium Badge - Top Left
                  Positioned(
                    top: AppSizer.deviceHeight1,
                    left: AppSizer.deviceWidth2,
                    child: Container(
                      padding: EdgeInsets.symmetric(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pdf.isFree)
                            Icon(
                              Icons.lock_open,
                              color: AppColors.successColor,
                              size: AppSizer.deviceSp20,
                            )
                          else
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(colors: [AppColors.primaryColor, AppColors.primaryColor]).createShader(bounds);
                              },
                              child: Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: AppSizer.deviceSp20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizer.deviceHeight2),

              // Content area that can expand
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PDF Title
                        Text(
                          pdf.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppSizer.deviceHeight1),

                        // PDF Size
                        Row(
                          children: [
                            Text(
                              pdf.size,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp13,
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceWidth1),
                            // Rating Section
                            Row(
                              children: [
                                // Star Rating
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.buttonColor,
                                      size: AppSizer.deviceSp16,
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth1),
                                    Text(
                                      pdf.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(width: AppSizer.deviceWidth2),

                                // Total Ratings
                                Text(
                                  '(${pdf.totalReviews})',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        //SizedBox(height: AppSizer.deviceHeight1),

                        // Views Count
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: AppColors.onSurfaceVariant,
                              size: AppSizer.deviceSp14,
                            ),
                            SizedBox(width: AppSizer.deviceWidth1),
                            Text(
                              '${pdf.views}+ views',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Open PDF Text
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizer.deviceHeight1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth2,
                        ),
                      ),
                      child: Text(
                        'Tap to Open PDF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
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

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onExplore,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large Circular Icon Background
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEBF3FE), // Soft sky blue
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 64,
                          color: const Color(0xFF0052FF), // Vibrant Blue
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight4),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),

                    // Subtitle / Description
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp15,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight3_5),

                    // Explore Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onExplore,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer.deviceWidth6,
                            vertical: AppSizer.deviceHeight1_5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052FF),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0052FF).withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.explore_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                buttonText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizer.deviceSp15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TabItem {
  final String title;
  final IconData icon;

  TabItem({required this.title, required this.icon});
}

final List<TabItem> tabs = [
  TabItem(title: 'Free Courses', icon: Icons.school),
  TabItem(title: 'Premium Courses', icon: Icons.workspace_premium),
  TabItem(title: 'Free E-Books', icon: Icons.menu_book),
  TabItem(title: 'Premium E-Books', icon: Icons.library_books),
];
