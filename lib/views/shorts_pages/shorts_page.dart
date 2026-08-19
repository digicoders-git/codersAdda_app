import 'package:share_plus/share_plus.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/veiw_model/shorts_viewmodel.dart';
import 'package:coders_adda_app/views/shorts_pages/short_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/models/shorts_model.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/views/navigation_class.dart';

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
          children: [
            // Back Button
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
              child: Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: AppSizer.deviceSp20,
                ),
              ),
            ),
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
          // Profile Picture
          Container(
            width: AppSizer.deviceWidth12,
            height: AppSizer.deviceWidth12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: AppColors.primaryColor,
            ),
            child: Center(
              child: Text(
                short.instructorName.isNotEmpty ? short.instructorName[0] : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Like Button
          _buildActionButton(
            context,
            isLiked ? Icons.favorite : Icons.favorite_border,
            '${short.totalLikes}',
            isLiked ? Colors.red : Colors.white,
            () => viewModel.toggleLike(short.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Comment Button
          _buildActionButton(
            context,
            Icons.comment,
            '${short.totalComments}',
            Colors.white,
            () => _showCommentsBottomSheet(context, viewModel, short.id),
          ),
          
          SizedBox(height: AppSizer.deviceHeight2),
          
          _buildActionButton(
            context,
            CupertinoIcons.paperplane,
            '${short.totalShares}',
            Colors.white,
            () {
              // Share the app install link instead of the raw video URL
              viewModel.addShare(short.id);
              Share.share('Check out this short video on Coders Adda: ${short.caption}\n\nWatch now:\nhttps://codersadda.digicoders.in/short?id=${short.id}\n\nOr download the app:\nhttps://play.google.com/store/apps/details?id=digi.coders.codersadda');
            },
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

  Widget _buildBottomInfo(BuildContext context, ShortsViewModel viewModel, ShortVideo short) {
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
                Flexible(
                  child: Text(
                    '@${short.instructorName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizer.deviceSp16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: AppSizer.deviceSp16,
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
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, ShortsViewModel viewModel, String shortId) {
    viewModel.fetchComments(shortId);
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                    Consumer<ShortsViewModel>(
                      builder: (context, vm, _) {
                        final comments = vm.getComments(shortId);
                        return Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${comments.length} Comments',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                              ),
                              const Divider(),
                              Expanded(
                                child: comments.isEmpty
                                    ? const Center(child: Text('No comments yet. Be the first!', style: TextStyle(color: Colors.grey)))
                                    : ListView.builder(
                                        itemCount: comments.length,
                                        itemBuilder: (context, index) {
                                          final comment = comments[index];
                                          return _buildCommentWithReplies(vm, shortId, comment);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: AppColors.primaryColor),
                            onPressed: () async {
                              if (commentController.text.trim().isNotEmpty) {
                                final text = commentController.text;
                                commentController.clear();
                                await viewModel.addComment(shortId, text);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildCommentWithReplies(ShortsViewModel vm, String shortId, ShortComment comment, {bool isReply = false}) {
    // Access ProfileViewModel to get current user ID
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final currentUserId = profileViewModel.user?.id;
    final isMyComment = comment.user.id == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: isReply ? 56.0 : 16.0, right: 16.0),
          leading: comment.user.profilePicture.isNotEmpty
            ? CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundColor: Colors.blue,
                child: ClipOval(
                  child: Image.network(
                    comment.user.profilePicture,
                    width: isReply ? 28 : 36,
                    height: isReply ? 28 : 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Icon(Icons.person, color: Colors.white, size: isReply ? 16 : 20),
                  ),
                ),
              )
            : CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: isReply ? 16 : 20),
              ),
          title: Row(
            children: [
              Text(comment.user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 14, color: Colors.black)),
              if (comment.isAdminReply) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 14),
              ]
            ],
          ),
          subtitle: Text(comment.commentText, style: TextStyle(color: Colors.black87, fontSize: isReply ? 12 : 14)),
          trailing: isMyComment 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () {
                      final ctrl = TextEditingController(text: comment.commentText);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Edit Comment'),
                          content: TextField(
                            controller: ctrl,
                            decoration: const InputDecoration(hintText: 'Enter your comment'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () async {
                                if (ctrl.text.trim().isNotEmpty) {
                                  Navigator.pop(ctx);
                                  await vm.editComment(shortId, comment.id, ctrl.text.trim());
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () async {
                      await vm.deleteComment(shortId, comment.id);
                    },
                  ),
                ],
              )
            : null,
        ),
        if (comment.replies.isNotEmpty)
          ...comment.replies.map((reply) => _buildCommentWithReplies(vm, shortId, reply, isReply: true)).toList(),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.flag, color: Colors.black), title: const Text('Report', style: TextStyle(color: Colors.black)), onTap: () {}),
          ListTile(leading: const Icon(Icons.not_interested, color: Colors.black), title: const Text('Not interested', style: TextStyle(color: Colors.black)), onTap: () {}),
          ListTile(leading: const Icon(Icons.save_alt, color: Colors.black), title: const Text('Save video', style: TextStyle(color: Colors.black)), onTap: () {}),
        ],
      ),
    );
  }
}
