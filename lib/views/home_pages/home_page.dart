import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/home_viewmodel.dart';
import 'package:coders_adda_app/views/home_pages/auto_slider_banner.dart';
import 'package:coders_adda_app/views/home_pages/home_trending_course_page.dart';
import 'package:coders_adda_app/views/job_pages/my_job_details_page.dart';
import 'package:coders_adda_app/views/job_pages/job_page.dart';
import 'package:coders_adda_app/views/notification_page/notification_page.dart';
import 'package:coders_adda_app/views/profile_pages/profile_page.dart';
import 'package:coders_adda_app/views/quiz_program_pages/quiz_page.dart';
import 'package:coders_adda_app/views/refral_program_page/refral_program.dart';
import 'package:coders_adda_app/views/search_page.dart/search_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:coders_adda_app/views/training_pages/training_courses.dart';
import 'package:coders_adda_app/views/wallet_pages/wallets_page.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final HomeViewModel viewModel = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            drawer: _buildDrawer(context),
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'CodersAdda',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    NavigationService.navigateTo(context, SearchPage());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_outlined),
                  onPressed: () {
                    NavigationService.navigateTo(context, NotificationPage());
                  },
                ),
              ],
            ),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: AppSizer.deviceHeight18,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.accentColor],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      final user = profileVM.user;
                      return Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSizer.deviceSp18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceHeight1),
                            Row(
                              children: [
                                Container(
                                  width: AppSizer.deviceWidth12,
                                  height: AppSizer.deviceWidth12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        user?.profilePicture ?? 'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSizer.deviceWidth3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Student',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppSizer.deviceSp18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: AppSizer.deviceHeight0_5),
                                      Text(
                                        user?.email ?? 'student@email.com',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: AppSizer.deviceSp14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(AppSizer.deviceWidth1),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: AppSizer.deviceSp16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.only(
                    top: AppSizer.deviceHeight2,
                    bottom: AppSizer.deviceHeight2,
                  ),
                  children: [
                    // Quick Stats
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth4,
                        vertical: AppSizer.deviceHeight1,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDrawerStat('12', 'Courses'),
                          _buildDrawerStat('8', 'Completed'),
                          _buildDrawerStat('95%', 'Progress'),
                        ],
                      ),
                    ),
                    Divider(
                      height: AppSizer.deviceHeight2,
                      thickness: 1,
                      color: AppColors.outline.withOpacity(0.3),
                    ),
                    _drawerItem(
                      Icons.menu_book,
                      'Training Programs',
                      Colors.blue,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          TrainingCourses(),
                        );
                      },
                    ),
                    _drawerItem(Icons.wallet, 'My Wallet', Colors.green, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, WalletsPage());
                    }),
                    _drawerItem(
                      Icons.workspace_premium,
                      'Subscription',
                      Colors.amber,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          SubscriptionPage(),
                        );
                      },
                    ),
                     _drawerItem(
                      Icons.quiz,
                      'Daily Quiz',
                      Colors.deepOrangeAccent,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          QuizPage(),
                        );
                      },
                    ),
                    _drawerItem(Icons.person, 'My Jobs', Colors.grey, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, MyJobDetailsPage());
                    }),
                    Divider(
                      height: AppSizer.deviceHeight2,
                      thickness: 1,
                      color: AppColors.outline.withOpacity(0.3),
                    ),
                    _drawerItem(Icons.person, 'Profile', Colors.purple, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, ProfilePage());
                    }),
                    _drawerItem(Icons.settings, 'Settings', Colors.grey, () {
                      Navigator.pop(context);
                      _showComingSoon(context);
                    }),
                    _drawerItem(Icons.help, 'Help & Support', Colors.blue, () {
                      Navigator.pop(context);
                      _showComingSoon(context);
                    }),
                    Divider(
                      height: AppSizer.deviceHeight2,
                      thickness: 1,
                      color: AppColors.outline.withOpacity(0.3),
                    ),
                    _drawerItem(Icons.logout, 'Logout', Colors.red, () async {
                      Navigator.pop(context);
                      await context.read<AuthViewModel>().signOut();
                      if (context.mounted) {
                        context.read<ProfileViewModel>().clearProfile();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizer.deviceSp16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: AppSizer.deviceWidth10,
        height: AppSizer.deviceWidth10,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
        ),
        child: Icon(icon, color: color, size: AppSizer.deviceSp18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer.deviceSp16,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.all(AppSizer.deviceWidth1),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: AppSizer.deviceSp12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizer.deviceWidth4,
        vertical: AppSizer.deviceHeight1,
      ),
    );
  }

  // void _shareApp() {
  //   print('Share app functionality');
  // }
  // ===================== Body =====================
  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        children: [
          _buildWelcomeSection(),
          SizedBox(height: AppSizer.deviceHeight3),
          _buildPageCards(context),
          SizedBox(height: AppSizer.deviceHeight3),
          _buildBannerSlider(context, viewModel),
          SizedBox(height: AppSizer.deviceHeight3),
          if (viewModel.isLoading && viewModel.homeData.coursesOnSale.isEmpty)
            Center(child: CircularProgressIndicator())
          else ...[
            _buildCoursesOnSale(context, viewModel.homeData.coursesOnSale),
            SizedBox(height: AppSizer.deviceHeight3),
            _buildFreeCourses(context, viewModel.homeData.freeCourses),
            SizedBox(height: AppSizer.deviceHeight3),
          ],
          _buildQuizzesAmbassadorSection(context),
          SizedBox(height: AppSizer.deviceHeight3),
        ],
      ),
    );
  }

  // ===================== Welcome Section =====================
  Widget _buildWelcomeSection() {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        final userName = profileVM.user?.name ?? 'Alex';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Hello, $userName!',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(width: AppSizer.deviceWidth1),
                    Icon(
                      Icons.verified,
                      color: Colors.blueAccent,
                      size: AppSizer.deviceSp18,
                    ),
                  ],
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  'What would you like to learn today?',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Builder(
              builder: (buildContext) => InkWell(
                onTap: () {
                  NavigationService.navigateTo(buildContext, SubscriptionPage());
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(AppSizer.deviceWidth2),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: Colors.blueAccent,
                    size: AppSizer.deviceSp22,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===================== Page Cards =====================
  Widget _buildPageCards(BuildContext context) {
    final pages = [
      {
        'name': 'COURSEs',
        'icon': Icons.school,
        'onTap': () {
          NavigationService.navigateToCoursePage(context);
        },
      },
      {
        'name': 'E-BOOKs',
        'icon': Icons.picture_as_pdf,
        'onTap': () {
          NavigationService.navigateToPdfPage(context);
        },
      },
      {
        'name': 'JOBs',
        'icon': Icons.work,
        'onTap': () {
          NavigationService.navigateTo(context, JobsPage());
        },
      },
      {
        'name': 'PROFILE',
        'icon': Icons.person,
        'onTap': () {
          NavigationService.navigateTo(context, ProfilePage());
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizer.deviceHeight2,
        crossAxisSpacing: AppSizer.deviceWidth2,
        childAspectRatio: 3 / 2,
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final item = pages[index];
        return GestureDetector(
          onTap: item['onTap'] as VoidCallback,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
            ),
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(AppSizer.deviceWidth3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: AppColors.primaryColor,
                    size: AppSizer.deviceSp28,
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Text(
                    item['name'] as String,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('This feature is under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
Widget _buildBannerSlider(BuildContext context, HomeViewModel viewModel) {
  return BannerSliderWidget(
    banners: viewModel.homeData.banners,
    isLoading: viewModel.isLoading,
  );
}

////////////////////////////////////////////////////////////////////////////
Widget _buildCoursesOnSale(BuildContext context, List<Course> courses) {
  if (courses.isEmpty) return SizedBox();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trending Courses',
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(height: AppSizer.deviceHeight1),
      SizedBox(
        height: AppSizer.deviceHeight30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return GestureDetector(
              onTap: () {
                NavigationService.navigateToCourseDetail(context, course);
              },
              child: Container(
                width: AppSizer.deviceWidth43,
                margin: EdgeInsets.only(right: AppSizer.deviceWidth1),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Container with Badge
                      Stack(
                        children: [
                         Container(
  height: AppSizer.deviceHeight13,
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppSizer.deviceWidth3),
      topRight: Radius.circular(AppSizer.deviceWidth3),
    ),
    image: DecorationImage(
      image: NetworkImage(course.thumbnail), 
      fit: BoxFit.cover,
    ),
  ),
),
                          // Trending Badge
                          Positioned(
                            //top: AppSizer.deviceHeight1,
                            //left: AppSizer.deviceWidth0_5,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth2,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Colors.red,
                                          Colors.orange,
                                          Colors.yellow,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Icon(
                                      Icons.local_fire_department,
                                      size: AppSizer.deviceSp20,
                                      color: Colors
                                          .white, // ye color base hota hai jisme gradient apply hota hai
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Content
                      Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceHeight0_5),

                            // Instructor
                            Text(
                              course.instructor,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizer.deviceHeight1),

                            // Rating and Duration Row
                            Row(
                              children: [
                                // Rating
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizer.deviceWidth1_5,
                                    vertical: AppSizer.deviceHeight0_5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: AppColors.primaryColor,
                                        size: AppSizer.deviceSp16,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '(2.5k)',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSizer.deviceWidth2),

                                // Duration
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizer.deviceWidth1_5,
                                    vertical: AppSizer.deviceHeight0_5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled_outlined,
                                        color: AppColors.primaryColor,
                                        size: AppSizer.deviceSp12,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '12h',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizer.deviceHeight1),

                            // Price Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${course.price}',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp14,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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
          },
        ),
      ),
    ],
  );
}

//////////////////////////////////////////////////////////////////////////////
Widget _buildFreeCourses(BuildContext context, List<Course> courses) {
  if (courses.isEmpty) return SizedBox();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Free Courses',
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
            ),
          ),

          InkWell(
            onTap: () {
              
            },
            child: Row(
              children: [
                Text(
                  'Veiw More',
                  style: TextStyle(
                    color: AppColors.buttonColor,
                    fontSize: AppSizer.deviceSp14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                color: AppColors.primaryColor,
                 size: AppSizer.deviceSp14,
                )
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: AppSizer.deviceHeight1),
      SizedBox(
        height: AppSizer.deviceHeight30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return GestureDetector(
              onTap: () {
                NavigationService.navigateToCourseDetail(context, course);
              },
              child: Container(
                width: AppSizer.deviceWidth43,
                margin: EdgeInsets.only(right: AppSizer.deviceWidth1),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Container with Free Badge
                      Stack(
                        children: [
                           Container(
  height: AppSizer.deviceHeight13,
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppSizer.deviceWidth3),
      topRight: Radius.circular(AppSizer.deviceWidth3),
    ),
    image: DecorationImage(
      image: NetworkImage(course.thumbnail), 
      fit: BoxFit.cover,
    ),
  ),
),
                          // Free Badge
                          Positioned(
                            top: AppSizer.deviceHeight1,
                            left: AppSizer.deviceWidth2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth2,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                //color: AppColors.successColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_open,
                                    color: AppColors.successColor,
                                    size: AppSizer.deviceSp20,
                                  ),
                                  // SizedBox(width: 2),
                                  // Text(
                                  //   'FREE',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: AppSizer.deviceSp10,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Content
                      Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceHeight0_5),

                            // Instructor
                            Text(
                              course.instructor,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizer.deviceHeight1),

                            // Rating and Duration Row
                            Row(
                              children: [
                                // Rating
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizer.deviceWidth1_5,
                                    vertical: AppSizer.deviceHeight0_5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: AppColors.buttonColor,
                                        size: AppSizer.deviceSp16,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '4.7',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.buttonColor,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '(1.8k)',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSizer.deviceWidth2),

                                // Duration
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizer.deviceWidth1_5,
                                    vertical: AppSizer.deviceHeight0_5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled_outlined,
                                        color: AppColors.primaryColor,
                                        size: AppSizer.deviceSp12,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '8h',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizer.deviceHeight1),

                            // Free Price Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '₹0',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp14,
                                        color: AppColors.successColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth1),
                                    Text(
                                      '₹${course.price}',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp10,
                                        color: AppColors.onSurfaceVariant,
                                        decoration: TextDecoration.lineThrough,
                                      ),
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
          },
        ),
      ),
    ],
  );
}

///////////////////////////////////////////////////////////////////////////
Widget _buildQuizzesAmbassadorSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore More',
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            Icons.explore,
            color: AppColors.primaryColor,
            size: AppSizer.deviceSp20,
          ),
        ],
      ),
      SizedBox(height: AppSizer.deviceHeight2),

      Container(
        height: AppSizer.deviceHeight18,
        child: Row(
          children: [
            Expanded(
              child: _buildDetailedFeatureCard(
                context,
                title: 'Daily Quizzes',
                subtitle:
                    'Challenge yourself with daily tech quizzes and win exciting rewards',
                icon: Icons.quiz,
                iconColor: AppColors.primaryColor,
                buttonText: 'Start Quiz',
                gradientColors: [AppColors.outline, AppColors.backgroundColor],
                onTap: () {
                  NavigationService.navigateTo(context, QuizPage());
                },
              ),
            ),

            SizedBox(width: AppSizer.deviceWidth3),

            Expanded(
              child: _buildDetailedFeatureCard(
                context,
                title: 'Refral Programs',
                subtitle:
                    'Become a partner and represent CodersAdda in your college',
                icon: Icons.people_alt,
                iconColor: AppColors.primaryColor,
                buttonText: 'Apply Now',
                gradientColors: [AppColors.outline, AppColors.backgroundColor],
                onTap: () {
                  NavigationService.navigateTo(context, RefralProgram());
                },
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildDetailedFeatureCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color iconColor,
  required String buttonText,
  required List<Color> gradientColors,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon and Title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizer.deviceWidth2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: AppSizer.deviceSp20,
                      ),
                    ),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth2,
                    vertical: AppSizer.deviceHeight1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      color: AppColors.buttonColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
