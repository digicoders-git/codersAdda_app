// views/shorts_page.dart
import 'package:coders_adda_app/veiw_model/shorts_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class ShortsPage extends StatelessWidget {
  const ShortsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShortsViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ShortsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Stack(
              children: [
                // Video Player Area
                _buildVideoPlayer(context, viewModel),
                
                // Top Bar
                _buildTopBar(context),
                
                // Right Side Actions
                
                _buildRightSideActions(context, viewModel),
                
                // Bottom Info
                _buildBottomInfo(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, ShortsViewModel viewModel) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: viewModel.shorts.length,
      onPageChanged: viewModel.setCurrentIndex,
      itemBuilder: (context, index) {
        final short = viewModel.shorts[index];
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade900,
                Colors.black,
              ],
            ),
            image: short.thumbnail.isNotEmpty ? DecorationImage(
              image: NetworkImage(short.thumbnail),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ) : null,
          ),
          child: short.thumbnail.isEmpty ? Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: AppSizer.deviceSp64,
            ),
          ) : null,
        );
      },
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
          children: [
           
             Spacer(),
            
            // Search Button
            GestureDetector(
              onTap: () {
                // Search functionality
              },
              child: Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: AppSizer.deviceSp20,
                ),
              ),
            ),
            
            SizedBox(width: AppSizer.deviceWidth2),
            
            // More Options
            GestureDetector(
              onTap: () {
                _showMoreOptions(context);
              },
              child: Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: AppSizer.deviceSp20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSideActions(BuildContext context, ShortsViewModel viewModel) {
    final currentShort = viewModel.currentShort;
    if (currentShort == null) return const SizedBox();

    return Positioned(
      right: AppSizer.deviceWidth4,
      bottom: AppSizer.deviceHeight5,
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: AppSizer.deviceWidth12,
            height: AppSizer.deviceWidth12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Like Button
          _buildActionButton(
            context,
            Icons.favorite,
            '${currentShort.likes}',
            Colors.red,
            () => viewModel.likeVideo(currentShort.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Comment Button
          _buildActionButton(
            context,
            Icons.comment,
            '${currentShort.comments}',
            Colors.white,
            () => viewModel.incrementComments(currentShort.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Share Button
          _buildActionButton(
            context,
            Icons.share,
            'Share',
            Colors.white,
            () => viewModel.shareVideo(currentShort.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // More Button
          Container(
            padding: EdgeInsets.all(AppSizer.deviceWidth2),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: AppSizer.deviceSp20,
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
          Container(
            padding: EdgeInsets.all(AppSizer.deviceWidth2),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizer.deviceSp20,
            ),
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

  Widget _buildBottomInfo(BuildContext context, ShortsViewModel viewModel) {
    final currentShort = viewModel.currentShort;
    if (currentShort == null) return const SizedBox();

    return Positioned(
      left: AppSizer.deviceWidth4,
      bottom: AppSizer.deviceHeight2,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator Info
            Row(
              children: [
                Text(
                  currentShort.creator,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth2),
                GestureDetector(
                  onTap: () => viewModel.followCreator(currentShort.creator),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth2,
                      vertical: AppSizer.deviceHeight0_5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizer.deviceSp10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizer.deviceHeight1),
            
            // Description
            Text(
              currentShort.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: AppSizer.deviceHeight1),
            
            // Music Info
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: AppSizer.deviceSp16,
                ),
                SizedBox(width: AppSizer.deviceWidth1),
                Text(
                  'Original Sound - Flutter Dev',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizer.deviceSp12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: AppSizer.deviceWidth10,
              height: AppSizer.deviceHeight0_5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            SizedBox(height: AppSizer.deviceHeight2),
            
            _buildOptionItem(Icons.flag, 'Report', () {}),
            _buildOptionItem(Icons.block, 'Not Interested', () {}),
            _buildOptionItem(Icons.save_alt, 'Save', () {}),
            _buildOptionItem(Icons.share, 'Share to...', () {}),
            _buildOptionItem(Icons.qr_code, 'QR Code', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: AppSizer.deviceSp24),
      title: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: AppSizer.deviceSp16),
      ),
      onTap: onTap,
    );
  }
}