
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/views/home_pages/home_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';
import 'package:coders_adda_app/views/profile_pages/profile_page.dart';
import 'package:coders_adda_app/views/shorts_pages/shorts_page.dart';
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
    ShortsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
                icon: Icons.person_outlined, 
                activeIcon: Icons.person, 
                label: 'Profile', 
                index: 3
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.accentColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(15),
            splashColor: AppColors.primaryColor.withOpacity(0.2),
            highlightColor: AppColors.primaryColor.withOpacity(0.1),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (isSpecial && !isActive)
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange,
                                Colors.red,
                              ],
                            ),
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
                          color: isActive ? Colors.white : AppColors.textColor,
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
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textColor,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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