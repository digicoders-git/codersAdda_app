import 'package:share_plus/share_plus.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/veiw_model/shorts_viewmodel.dart';
import 'package:coders_adda_app/views/shorts_pages/short_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/models/shorts_model.dart';
import 'package:coders_adda_app/views/navigation_class.dart';
import 'package:coders_adda_app/views/shorts_pages/shorts_comments_bottom_sheet.dart';

class ShortsPage extends StatefulWidget {
  final bool isActive;
  const ShortsPage({super.key, this.isActive = true});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  late ShortsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ShortsViewModel();
    // Arguments are handled in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // We only want to fetch once when the widget is initialized and active
    if (widget.isActive && _viewModel.shorts.isEmpty && !_viewModel.isLoading) {
      String? initialShortId;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        initialShortId = args['shortId'] as String?;
      }
      _viewModel.fetchShorts(initialShortId: initialShortId);
    }
  }

  @override
  void didUpdateWidget(ShortsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
        _viewModel.fetchShorts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ShortsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.shorts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Stack(
              children: [
                // Video Player Area with Actions and Info nested inside PageView
                _buildVideoPlayer(context, viewModel),
                
                // Top Bar (stays fixed at the top)
                _buildTopBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, ShortsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.fetchShorts();
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: viewModel.shorts.length,
        onPageChanged: viewModel.setCurrentIndex,
        itemBuilder: (context, index) {
          final short = viewModel.shorts[index];
          return Stack(
            children: [
              ShortVideoPlayer(
                short: short,
                isCurrent: viewModel.currentIndex == index && widget.isActive,
              ),
              _buildRightSideActions(context, viewModel, short),
              _buildBottomInfo(context, viewModel, short),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSizer.deviceHeight2,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainNavigation()),
                  );
                }
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: AppSizer.deviceSp20,
              ),
            ),

            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: AppSizer.deviceSp20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSideActions(BuildContext context, ShortsViewModel viewModel, ShortVideo short) {
    final isLiked = viewModel.isLiked(short.id);

    return Positioned(
      right: AppSizer.deviceWidth4,
      bottom: AppSizer.deviceHeight5,
      child: Column(
        children: [
          // Profile Picture with + icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: AppSizer.deviceWidth10,
                height: AppSizer.deviceWidth10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  color: AppColors.primaryColor,
                ),
                child: Center(
                  child: Text(
                    short.instructorName.isNotEmpty ? short.instructorName[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp16),
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.primaryColor,
                      size: AppSizer.deviceSp12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight3),
          
          // Like Button
          _buildActionButton(
            context,
            isLiked ? Icons.favorite : Icons.favorite,
            '${short.totalLikes}',
            isLiked ? Colors.red : Colors.white,
            () => viewModel.toggleLike(short.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Comment Button
          _buildActionButton(
            context,
            Icons.chat,
            '${short.totalComments}',
            Colors.white,
            () => _showCommentsBottomSheet(context, viewModel, short.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          _buildActionButton(
            context,
            Icons.send,
            '${short.totalShares}',
            Colors.white,
            () {
              viewModel.addShare(short.id);
              Share.share('Check out this short video on Coders Adda: ${short.caption}\n\nWatch now:\nhttps://codersadda.digicoders.in/short?id=${short.id}\n\nOr download the app:\nhttps://play.google.com/store/apps/details?id=digi.coders.codersadda');
            },
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // More Button
          _buildActionButton(
            context,
            Icons.more_horiz,
            'More',
            Colors.white,
            () {},
          ),

          SizedBox(height: AppSizer.deviceHeight2),

          // Music Disk
          Container(
            width: AppSizer.deviceWidth10,
            height: AppSizer.deviceWidth10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.grey.shade800, width: 8),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/codersaddalogo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.blue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppSizer.deviceSp20,
          ),
          SizedBox(height: AppSizer.deviceHeight0_5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizer.deviceSp12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context, ShortsViewModel viewModel, ShortVideo short) {
    return Positioned(
      left: AppSizer.deviceWidth4,
      bottom: AppSizer.deviceHeight2,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator Info
            Row(
              children: [
                Container(
                  width: AppSizer.deviceWidth10,
                  height: AppSizer.deviceWidth10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/codersaddalogo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.blue);
                      },
                    ),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                Flexible(
                  child: Text(
                    '@${short.instructorName.isNotEmpty ? short.instructorName : 'Er.Mayank Pandey'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 30),
                  ),
                  child: const Text(
                    "Follow",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizer.deviceHeight1),
            
            // Description
            Text(
              short.caption,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: AppSizer.deviceHeight1),
            
            // Music Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: AppSizer.deviceSp14,
                  ),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(
                    'Original Sound - Coders Adda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizer.deviceSp12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, ShortsViewModel viewModel, String shortId) {
    ShortsCommentsBottomSheet.show(context, viewModel, shortId);
  }
}

