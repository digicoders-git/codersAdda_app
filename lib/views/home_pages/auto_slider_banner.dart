import 'dart:async';
import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:flutter/material.dart';

class BannerSliderWidget extends StatefulWidget {
  final List<BannerItem> banners;
  final bool isLoading;

  const BannerSliderWidget({
    Key? key, 
    required this.banners, 
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<BannerSliderWidget> createState() => _BannerSliderWidgetState();
}

class _BannerSliderWidgetState extends State<BannerSliderWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (!widget.isLoading && widget.banners.isNotEmpty) {
      _startAutoSlide();
    }
  }

  @override
  void didUpdateWidget(covariant BannerSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading && widget.banners.isNotEmpty) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.banners.isEmpty) return;
      
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: AppSizer.deviceHeight20,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (widget.banners.isEmpty) {
      return Container(
        height: AppSizer.deviceHeight20,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        child: const Center(
          child: Text('Coming Soon...'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: AppSizer.deviceHeight20,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () {
                  NavigationService.navigateTo(context, SubscriptionPage());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth1),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                      ),
                      child: Stack(
                        children: [
                          // Background Image or Gradient
                          if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                                image: DecorationImage(
                                  image: NetworkImage(banner.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryColor, AppColors.accentColor],
                                ),
                              ),
                            ),
                          
                          // Text Overlay (optional, based on API data)
                          if (banner.title.isNotEmpty || banner.subtitle.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(AppSizer.deviceWidth4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (banner.title.isNotEmpty)
                                    Text(
                                      banner.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppSizer.deviceSp16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (banner.subtitle.isNotEmpty)
                                    Text(
                                      banner.subtitle,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: AppSizer.deviceSp12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}