import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/widgets/custom_loader.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/home_viewmodel.dart';
import 'package:coders_adda_app/views/home_pages/auto_slider_banner.dart';
import 'package:coders_adda_app/views/home_pages/auto_sliding_course_list.dart';
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
import 'package:coders_adda_app/views/common/help_support_page.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/notification_viewmodel.dart';
import 'package:coders_adda_app/views/profile_pages/edite_profile.dart';
import 'package:coders_adda_app/views/downloaded_pdfs/downloaded_pdfs_page.dart';
import 'package:coders_adda_app/views/test_program_pages/general_tests_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_player_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            drawer: _buildDrawer(context),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu, color: AppColors.logoNavy),
                      ),
                    ),
                  );
                }
              ),
              iconTheme: const IconThemeData(color: AppColors.logoNavy),
              actionsIconTheme: const IconThemeData(color: AppColors.logoNavy),
              title: Image.asset(
                'assets/images/mainLogo.png',
                height: AppSizer.deviceHeight10, 
                fit: BoxFit.contain,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.logoNavy),
                  onPressed: () {
                    NavigationService.navigateTo(context, SearchPage());
                  },
                ),
                Consumer<NotificationViewModel>(
                  builder: (ctx, notifVm, _) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: notifVm,
                              child: const NotificationPage(),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.notifications_outlined, color: AppColors.logoNavy),
                            if (notifVm.unreadCount > 0)
                              Positioned(
                                top: 4,
                                right: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.logoOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      notifVm.unreadCount > 9 ? '9+' : '${notifVm.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
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
    final profileViewModel = Provider.of<ProfileViewModel>(context);
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
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
              ),
              child: SafeArea(
                bottom: false,
                child: Consumer<ProfileViewModel>(
                  builder: (context, profileVM, child) {
                    final user = profileVM.user;
                    return Padding(
                      padding: EdgeInsets.all(AppSizer.deviceWidth4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/mainLogo.png',
                            height: AppSizer.deviceHeight5,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: AppSizer.deviceHeight1_5),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: AppSizer.deviceSp12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppSizer.deviceHeight0_5),
                          Row(
                            children: [
                              Container(
                                width: AppSizer.deviceWidth10,
                                height: AppSizer.deviceWidth10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  color: AppColors.onSurfaceVariant,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    user?.profilePicture ?? 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person, size: AppSizer.deviceWidth5, color: AppColors.onSurfaceVariant);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name ?? 'Student',
                                      style: TextStyle(
                                        color: AppColors.logoNavy,
                                        fontSize: AppSizer.deviceSp14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight0_5),
                                    Text(
                                      user?.email ?? 'student@email.com',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppSizer.deviceSp11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(AppSizer.deviceWidth1),
                                decoration: const BoxDecoration(
                                  color: AppColors.logoBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: AppSizer.deviceSp13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                        vertical: AppSizer.deviceHeight0_5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDrawerStat('${profileViewModel.user?.courseCount ?? 0}', 'Courses'),
                          _buildDrawerStat('${profileViewModel.user?.completedCount ?? 0}', 'Completed'),
                          _buildDrawerStat('${profileViewModel.user?.progressPercentage ?? 0}%', 'Progress'),
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
                      AppColors.logoBlue,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          TrainingCourses(),
                        );
                      },
                    ),
                    _drawerItem(Icons.wallet, 'My Wallet', AppColors.logoGreen, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, WalletsPage());
                    }),
                    _drawerItem(
                      Icons.workspace_premium,
                      'Subscription',
                      AppColors.logoOrange,
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
                      AppColors.logoOrange,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          QuizPage(),
                        );
                      },
                    ),
                    _drawerItem(
                      Icons.assignment,
                      'General Tests',
                      AppColors.logoOrange,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          const GeneralTestsPage(),
                        );
                      },
                    ),
                    _drawerItem(Icons.person, 'My Jobs', AppColors.onSurfaceVariant, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, MyJobDetailsPage());
                    }),
                    _drawerItem(
                      Icons.campaign_rounded,
                      'Campus Ambassador',
                      AppColors.logoBlue,
                      () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          context,
                          const RefralProgram(),
                        );
                      },
                    ),
                    Divider(
                      height: AppSizer.deviceHeight2,
                      thickness: 1,
                      color: AppColors.outline.withOpacity(0.3),
                    ),
                    _drawerItem(Icons.download, 'Downloads', AppColors.logoGreen, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, const DownloadedPdfsPage());
                    }),
                    _drawerItem(Icons.person, 'Profile', AppColors.logoNavy, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, ProfilePage());
                    }),
                    _drawerItem(Icons.settings, 'Settings', AppColors.onSurfaceVariant, () {
                      Navigator.pop(context);
                      _showComingSoon(context);
                    }),
                    _drawerItem(Icons.help, 'Help & Support', AppColors.logoBlue, () {
                      Navigator.pop(context);
                      NavigationService.navigateTo(context, const HelpSupportPage());
                    }),
                    Divider(
                      height: AppSizer.deviceHeight2,
                      thickness: 1,
                      color: AppColors.outline.withOpacity(0.3),
                    ),
                    _drawerItem(Icons.logout, 'Logout', AppColors.errorColor, () async {
                      Navigator.pop(context);
                      await context.read<AuthViewModel>().signOut();
                      if (context.mounted) {
                        context.read<ProfileViewModel>().clearProfile();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    }),
                    SizedBox(height: AppSizer.deviceHeight2),
                  ],
                ),
              ),
            ),
            // Fixed bottom logo
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSizer.deviceWidth4, 
                    top: AppSizer.deviceHeight2, 
                    bottom: AppSizer.deviceHeight2
                  ),
                  child: Image.asset(
                    'assets/images/mainLogo.png',
                    height: AppSizer.deviceHeight8, // Made logo bigger
                    fit: BoxFit.contain,
                    color: Colors.grey.withOpacity(0.5),
                    colorBlendMode: BlendMode.srcATop,
                  ),
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
            fontSize: AppSizer.deviceSp14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp10,
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
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      leading: Container(
        width: AppSizer.deviceWidth8,
        height: AppSizer.deviceWidth8,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
        ),
        child: Icon(icon, color: color, size: AppSizer.deviceSp15),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer.deviceSp13,
          fontWeight: FontWeight.w500,
          color: AppColors.logoNavy,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: AppSizer.deviceSp11,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizer.deviceWidth4,
        vertical: AppSizer.deviceHeight0_5,
      ),
    );
  }

  // void _shareApp() {
  //   print('Share app functionality');
  // }
  // ===================== Body =====================
  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.fetchHomeData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          children: [
            SizedBox(height: AppSizer.deviceHeight1),
            _buildWelcomeSection(),
            SizedBox(height: AppSizer.deviceHeight1_5),
            _buildPageCards(context),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildBannerSlider(context, viewModel),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildContinueWatching(context, viewModel),
          _buildProfileCompletionWidget(),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildCouponsSlider(context, viewModel),
          SizedBox(height: AppSizer.deviceHeight1_5),
          if (viewModel.isLoading && viewModel.homeData.coursesOnSale.isEmpty)
            const Center(child: CustomLoader())
          else ...[
            _buildCoursesOnSale(context, viewModel.homeData.coursesOnSale),
            SizedBox(height: AppSizer.deviceHeight1_5),
            _buildFreeCourses(context, viewModel.homeData.freeCourses),
            SizedBox(height: AppSizer.deviceHeight1_5),
          ],
          _buildQuizzesAmbassadorSection(context),
            SizedBox(height: AppSizer.deviceHeight2),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueWatching(BuildContext context, HomeViewModel viewModel) {
    final progress = viewModel.recentProgress;
    if (progress == null) return const SizedBox.shrink();

    final course = progress['course'];
    final lecture = progress['lecture'];
    if (course == null || lecture == null) return const SizedBox.shrink();

    final String courseId = course['_id'] ?? '';
    final String courseTitle = course['title'] ?? 'Course';
    final String lectureTitle = lecture['title'] ?? 'Lecture';
    final int watchedSeconds = progress['watchedSeconds'] ?? 0;
    final int durationSeconds = progress['durationSeconds'] ?? 1; // avoid divide by zero
    final double percent = (watchedSeconds / durationSeconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Continue Learning",
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyLearningCoursePlayer(courseId: courseId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.logoNavy, AppColors.logoBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.logoNavy.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lectureTitle,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.logoOrange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: AppColors.logoBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight3),
      ],
    );
  }

  // ===================== Welcome Section =====================
  Widget _buildWelcomeSection() {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        final userName = profileVM.user?.name ?? 'Alex';
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizer.deviceWidth5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E50FF),
                Color(0xFF0033E0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Hello, $userName!',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Icon(
                    Icons.verified,
                    color: Colors.amber, 
                    size: AppSizer.deviceSp18,
                  ),
                ],
              ),
              SizedBox(height: AppSizer.deviceHeight1),
              Text(
                'What would you like to learn today?',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageCards(BuildContext context) {
    final pages = [
      {
        'name': 'COURSES',
        'subtitle': 'Explore best courses',
        'icon': Icons.school,
        'color': const Color(0xFF1E50FF),
        'onTap': () {
          NavigationService.navigateToCoursePage(context);
        },
      },
      {
        'name': 'E-BOOKS',
        'subtitle': 'Read & learn anytime',
        'icon': Icons.picture_as_pdf,
        'color': const Color(0xFFFF7A00),
        'onTap': () {
          NavigationService.navigateToPdfPage(context);
        },
      },
      {
        'name': 'JOBS',
        'subtitle': 'Find best opportunities',
        'icon': Icons.work,
        'color': const Color(0xFF00B050),
        'onTap': () {
          NavigationService.navigateTo(context, JobsPage());
        },
      },
      {
        'name': 'PROFILE',
        'subtitle': 'Manage your account',
        'icon': Icons.person,
        'color': const Color(0xFF8A2BE2),
        'onTap': () {
          NavigationService.navigateTo(context, ProfilePage());
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizer.deviceHeight2,
        crossAxisSpacing: AppSizer.deviceWidth3,
        childAspectRatio: 1.2, // Increased to make cards shorter
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final item = pages[index];
        final cardColor = item['color'] as Color;
        return GestureDetector(
          onTap: item['onTap'] as VoidCallback,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.04), // Very light tint of the theme color
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardColor.withOpacity(0.1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: cardColor,
                  size: AppSizer.deviceSp32,
                ),
                const Spacer(),
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['subtitle'] as String,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: cardColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== Profile Completion =====================
  Widget _buildProfileCompletionWidget() {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        if (profileVM.user == null) return const SizedBox.shrink();
        
        final percentage = profileVM.user!.calculatedProgressPercentage.toInt();
        if (percentage == 100) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            NavigationService.navigateTo(context, EditProfilePage(user: profileVM.user!));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Circular Progress Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.logoBlue.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.logoBlue),
                        strokeWidth: 4,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 16, color: AppColors.logoBlue),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logoBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Texts & Linear Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete your profile ($percentage%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: AppSizer.deviceSp14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap here to add missing details.',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.logoBlue),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== Coupons Slider =====================
  Widget _buildCouponsSlider(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.activeCoupons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
          child: Text(
            'Special Offers',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
              color: AppColors.logoNavy,
            ),
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        SizedBox(
          height: AppSizer.deviceHeight15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
            itemCount: viewModel.activeCoupons.length,
            itemBuilder: (context, index) {
              final coupon = viewModel.activeCoupons[index];
              return Container(
                width: AppSizer.deviceWidth70,
                margin: EdgeInsets.only(right: AppSizer.deviceWidth4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.logoOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'COUPON',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              coupon.code,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              coupon.description,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

  final List<List<Color>> gradients = [
    [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    [const Color(0xFF2563EB), const Color(0xFF0EA5E9)],
    [const Color(0xFF059669), const Color(0xFF10B981)],
    [const Color(0xFFDC2626), const Color(0xFFF97316)],
    [const Color(0xFF7C3AED), const Color(0xFFDB2777)],
    [const Color(0xFF0F172A), const Color(0xFF1E3A5F)],
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Trending Courses',
            style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold, color: const Color(0xFF172554))),
          InkWell(
            onTap: () => NavigationService.navigateToCoursePage(context, initialIndex: 1),
            child: Row(children: [
              Text('View More', style: TextStyle(color: const Color(0xFF2563EB), fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_ios, color: const Color(0xFF2563EB), size: AppSizer.deviceSp13),
            ]),
          ),
        ],
      ),
      SizedBox(height: AppSizer.deviceHeight1),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSizer.deviceWidth3,
          mainAxisSpacing: AppSizer.deviceWidth3,
          childAspectRatio: 0.65,
        ),
        itemCount: courses.length > 6 ? 6 : courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final grad = gradients[index % gradients.length];
          return GestureDetector(
            onTap: () => NavigationService.navigateToCourseDetail(context, course),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail with gradient fallback
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: Stack(
                      children: [
                        // Gradient background always shown
                        Container(
                          height: AppSizer.deviceHeight13,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: Center(
                            child: Icon(Icons.play_lesson, color: Colors.white.withOpacity(0.4), size: 36),
                          ),
                        ),
                        // Network image on top
                        Image.network(
                          course.thumbnail,
                          height: AppSizer.deviceHeight13,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        // TRENDING badge
                        Positioned(
                          top: 7, left: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.local_fire_department, color: Colors.white, size: 10),
                              const SizedBox(width: 2),
                              Text('TRENDING', style: TextStyle(color: Colors.white, fontSize: AppSizer.deviceSp10, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: AppSizer.deviceSp15, fontWeight: FontWeight.bold, color: const Color(0xFF172554), height: 1.2)),
                          SizedBox(height: AppSizer.deviceHeight0_5),
                          Text(course.instructor, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: AppSizer.deviceSp12, color: const Color(0xFF64748B))),
                          const Spacer(),
                          // Rating row
                          Row(children: [
                            const Icon(Icons.star, color: Color(0xFFF97316), size: 14),
                            const SizedBox(width: 2),
                            Text('${course.rating > 0 ? course.rating.toStringAsFixed(1) : "0.0"}(${course.reviews.length})',
                              style: TextStyle(fontSize: AppSizer.deviceSp11, fontWeight: FontWeight.bold, color: const Color(0xFFF97316))),
                            const SizedBox(width: 5),
                            const Icon(Icons.access_time, color: Color(0xFF2563EB), size: 12),
                            const SizedBox(width: 2),
                            Flexible(child: Text(course.duration.isNotEmpty ? course.duration : '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: AppSizer.deviceSp11, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600))),
                          ]),
                          SizedBox(height: AppSizer.deviceHeight0_5),
                          Text('₹${course.price}',
                            style: TextStyle(fontSize: AppSizer.deviceSp17, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

//////////////////////////////////////////////////////////////////////////////
Widget _buildFreeCourses(BuildContext context, List<Course> courses) {
  if (courses.isEmpty) return SizedBox();

  final List<List<Color>> gradients = [
    [const Color(0xFF059669), const Color(0xFF10B981)],
    [const Color(0xFF2563EB), const Color(0xFF6366F1)],
    [const Color(0xFF7C3AED), const Color(0xFFDB2777)],
    [const Color(0xFF0F172A), const Color(0xFF1E3A5F)],
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Free Courses',
            style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold, color: const Color(0xFF172554))),
          InkWell(
            onTap: () => NavigationService.navigateToCoursePage(context, initialIndex: 0),
            child: Row(children: [
              Text('View More', style: TextStyle(color: const Color(0xFF2563EB), fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_ios, color: const Color(0xFF2563EB), size: AppSizer.deviceSp13),
            ]),
          ),
        ],
      ),
      SizedBox(height: AppSizer.deviceHeight1),
      SizedBox(
        height: AppSizer.deviceHeight15,
        child: PageView.builder(
          itemCount: courses.length,
          controller: PageController(viewportFraction: 0.97),
          itemBuilder: (context, index) {
            final course = courses[index];
            final grad = gradients[index % gradients.length];
            return GestureDetector(
              onTap: () => NavigationService.navigateToCourseDetail(context, course),
              child: Container(
                margin: const EdgeInsets.only(right: 6, bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    // Left thumbnail
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                      child: SizedBox(
                        width: AppSizer.deviceWidth35,
                        height: double.infinity,
                        child: Stack(fit: StackFit.expand, children: [
                          // Gradient fallback
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: Center(child: Icon(Icons.play_lesson, color: Colors.white.withOpacity(0.4), size: 36)),
                          ),
                          // Network image
                          Image.network(
                            course.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                          // FREE badge
                          Positioned(
                            top: 8, left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(6)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.lock_open, color: Colors.white, size: 12),
                                const SizedBox(width: 2),
                                Text('FREE', style: TextStyle(color: Colors.white, fontSize: AppSizer.deviceSp10, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    // Right content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizer.deviceWidth3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: AppSizer.deviceSp16, fontWeight: FontWeight.bold, color: const Color(0xFF172554), height: 1.2)),
                            SizedBox(height: AppSizer.deviceHeight0_5),
                            Text(course.instructor, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: AppSizer.deviceSp13, color: const Color(0xFF64748B))),
                            SizedBox(height: AppSizer.deviceHeight1),
                            Row(children: [
                              const Icon(Icons.star, color: Color(0xFFF97316), size: 14),
                              const SizedBox(width: 3),
                              Text('${course.rating > 0 ? course.rating.toStringAsFixed(1) : "4.0"}(${course.reviews.length})',
                                style: TextStyle(fontSize: AppSizer.deviceSp12, fontWeight: FontWeight.bold, color: const Color(0xFFF97316))),
                              const SizedBox(width: 6),
                              const Icon(Icons.access_time, color: Color(0xFF2563EB), size: 12),
                              const SizedBox(width: 2),
                              Flexible(child: Text(course.duration.isNotEmpty ? course.duration : '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: AppSizer.deviceSp12, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600))),
                            ]),
                            SizedBox(height: AppSizer.deviceHeight0_5),
                            Text('₹0',
                              style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                title: 'Campus Ambassador',
                subtitle:
                    'Represent CodersAdda in your college & earn exciting rewards',
                icon: Icons.campaign_rounded,
                iconColor: AppColors.primaryColor,
                buttonText: 'Apply Now',
                gradientColors: [AppColors.outline, AppColors.backgroundColor],
                onTap: () {
                  NavigationService.navigateTo(context, const RefralProgram());
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
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
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
                          color: AppColors.logoNavy,
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

