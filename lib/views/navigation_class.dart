
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/views/home_pages/home_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';
import 'package:coders_adda_app/views/profile_pages/profile_page.dart';
import 'package:coders_adda_app/views/shorts_pages/shorts_fullscreen_page.dart';
import 'package:coders_adda_app/views/downloaded_pdfs/downloaded_pdfs_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class MainNavigation extends StatefulWidget {
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch user profile data at start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchUserProfile();
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    MyLearningPage(),
    Container(), // Shorts
    const DownloadedPdfsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined, 
                activeIcon: Icons.home, 
                label: 'Home', 
                index: 0
              ),
              _buildNavItem(
                icon: Icons.video_library_outlined, 
                activeIcon: Icons.video_library, 
                label: 'Learning', 
                index: 1
              ),
              _buildNavItem(
                icon: Icons.play_circle_fill, 
                activeIcon: Icons.play_circle_fill, 
                label: 'Shorts', 
                index: 2, 
                isSpecial: true
              ),
              _buildNavItem(
                icon: Icons.download_outlined, 
                activeIcon: Icons.download, 
                label: 'Downloads', 
                index: 3
              ),
              _buildNavItem(
                icon: Icons.person_outlined, 
                activeIcon: Icons.person, 
                label: 'Profile', 
                index: 4
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isSpecial = false,
  }) {
    bool isActive = _currentIndex == index;
    
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: isActive
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.35),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              )
            : null,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: () {
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShortsFullscreenPage(),
                  ),
                );
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            borderRadius: BorderRadius.circular(15),
            splashColor: AppColors.primaryColor.withOpacity(0.2),
            highlightColor: AppColors.primaryColor.withOpacity(0.1),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (isSpecial && !isActive)
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                      else
                        Icon(
                          isActive ? activeIcon : icon,
                          color: isActive ? Colors.white : const Color(0xFF172554),
                          size: isSpecial ? 22 : 20,
                        ),
                      
                      // Active indicator dot
                      if (isActive)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}