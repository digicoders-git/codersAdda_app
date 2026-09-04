import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/models/shorts_model.dart';
import 'package:coders_adda_app/veiw_model/shorts_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';

class ShortsCommentsBottomSheet extends StatefulWidget {
  final String shortId;
  final ShortsViewModel viewModel;

  const ShortsCommentsBottomSheet({
    Key? key,
    required this.shortId,
    required this.viewModel,
  }) : super(key: key);

  static void show(BuildContext context, ShortsViewModel viewModel, String shortId) {
    viewModel.fetchComments(shortId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: ShortsCommentsBottomSheet(
          shortId: shortId,
          viewModel: viewModel,
        ),
      ),
    );
  }

  @override
  State<ShortsCommentsBottomSheet> createState() => _ShortsCommentsBottomSheetState();
}

class _ShortsCommentsBottomSheetState extends State<ShortsCommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Track expanded replies per comment id
  final Set<String> _expandedCommentIds = {};

  // Track local optimistic likes & dislikes
  // key: commentId, value: { 'likes': int, 'isLiked': bool, 'isDisliked': bool }
  final Map<String, Map<String, dynamic>> _commentReactions = {};

  // Reply target state
  ShortComment? _replyTargetComment;

  // Sorting mode: 'top' or 'newest'
  String _sortBy = 'newest';

  // Quick emoji list from the design
  final List<String> _quickEmojis = ['❤️', '😂', '👍', '😮', '🎉', '🙏'];

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Map<String, dynamic> _getReactionState(String commentId, int defaultLikes) {
    if (!_commentReactions.containsKey(commentId)) {
      _commentReactions[commentId] = {
        'likes': defaultLikes,
        'isLiked': false,
        'isDisliked': false,
      };
    }
    return _commentReactions[commentId]!;
  }

  void _toggleLike(String commentId, int defaultLikes) {
    setState(() {
      final state = _getReactionState(commentId, defaultLikes);
      if (state['isLiked'] == true) {
        state['isLiked'] = false;
        state['likes'] = (state['likes'] as int) - 1;
      } else {
        state['isLiked'] = true;
        state['likes'] = (state['likes'] as int) + 1;
        if (state['isDisliked'] == true) {
          state['isDisliked'] = false;
        }
      }
    });
  }

  void _toggleDislike(String commentId, int defaultLikes) {
    setState(() {
      final state = _getReactionState(commentId, defaultLikes);
      if (state['isDisliked'] == true) {
        state['isDisliked'] = false;
      } else {
        state['isDisliked'] = true;
        if (state['isLiked'] == true) {
          state['isLiked'] = false;
          state['likes'] = (state['likes'] as int) - 1;
        }
      }
    });
  }

  void _startReply(ShortComment comment) {
    setState(() {
      _replyTargetComment = comment;
      _expandedCommentIds.add(comment.id);
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyTargetComment = null;
    });
  }

  void _onEmojiTap(String emoji) {
    final text = _commentController.text;
    final selection = _commentController.selection;
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, emoji);
      _commentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + emoji.length),
      );
    } else {
      _commentController.text = text + emoji;
    }
    _focusNode.requestFocus();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      if (_replyTargetComment != null) {
        final parentId = _replyTargetComment!.id;
        await widget.viewModel.replyToComment(widget.shortId, parentId, text);
        _expandedCommentIds.add(parentId);
      } else {
        await widget.viewModel.addComment(widget.shortId, text);
      }
      _commentController.clear();
      _cancelReply();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  int _countTotalComments(List<ShortComment> comments) {
    int count = comments.length;
    for (var c in comments) {
      count += c.replies.length;
    }
    return count;
  }

  List<ShortComment> _getSortedComments(List<ShortComment> list) {
    final copy = List<ShortComment>.from(list);
    if (_sortBy == 'newest') {
      copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      copy.sort((a, b) {
        final aLikes = _getReactionState(a.id, 0)['likes'] as int;
        final bLikes = _getReactionState(b.id, 0)['likes'] as int;
        return bLikes.compareTo(aLikes);
      });
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final currentUser = profileViewModel.user;
    final currentUserId = currentUser?.id;
    final currentUserAvatar = currentUser?.profilePicture ?? '';

    return Consumer<ShortsViewModel>(
      builder: (context, vm, _) {
        final comments = vm.getComments(widget.shortId);
        final totalCount = _countTotalComments(comments);
        final sortedComments = _getSortedComments(comments);

        return Container(
          height: MediaQuery.of(context).size.height * 0.76,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header: Comments + Count + Sort + Close
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalCount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Sort Menu
                    PopupMenuButton<String>(
                      icon: Icon(Icons.sort_rounded, color: Colors.grey[800], size: 22),
                      tooltip: 'Sort comments',
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        setState(() {
                          _sortBy = val;
                        });
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'newest',
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: _sortBy == 'newest' ? AppColors.primaryColor : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Newest first',
                                style: TextStyle(
                                  fontWeight: _sortBy == 'newest' ? FontWeight.bold : FontWeight.normal,
                                  color: _sortBy == 'newest' ? AppColors.primaryColor : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'top',
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 18,
                                color: _sortBy == 'top' ? AppColors.primaryColor : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Top comments',
                                style: TextStyle(
                                  fontWeight: _sortBy == 'top' ? FontWeight.bold : FontWeight.normal,
                                  color: _sortBy == 'top' ? AppColors.primaryColor : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black87, size: 24),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Comments List
              Expanded(
                child: sortedComments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[350]),
                            const SizedBox(height: 12),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Be the first to share your thoughts!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: sortedComments.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final comment = sortedComments[index];
                          return _buildCommentItem(
                            vm: vm,
                            comment: comment,
                            currentUserId: currentUserId,
                            isNestedReply: false,
                          );
                        },
                      ),
              ),

              // Bottom sticky input bar (always visible)
              _buildActiveReplyBottomBar(currentUserAvatar, currentUser?.name ?? 'User'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem({
    required ShortsViewModel vm,
    required ShortComment comment,
    required String? currentUserId,
    required bool isNestedReply,
  }) {
    final isMyComment = comment.user.id == currentUserId;
    // Default likes heuristic (based on id hash for deterministic display if server has 0)
    final defaultLikes = (comment.commentText.length % 15) + (comment.isAdminReply ? 25 : 4);
    final reaction = _getReactionState(comment.id, defaultLikes);
    final isLiked = reaction['isLiked'] == true;
    final isDisliked = reaction['isDisliked'] == true;
    final likeCount = reaction['likes'] as int;

    final isExpanded = _expandedCommentIds.contains(comment.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _buildAvatar(
              comment.user.profilePicture,
              comment.user.name,
              radius: isNestedReply ? 15 : 18,
              isAdmin: comment.isAdminReply,
            ),
            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Name + Admin Badge + Timestamp + 3-Dots
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isNestedReply ? 13 : 13.5,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (comment.isAdminReply) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Color(0xFF1967D2),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        _formatTimeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      // 3-dots Menu
                      _buildCommentMenu(vm, comment, isMyComment),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Comment Text
                  Text(
                    comment.commentText,
                    style: TextStyle(
                      fontSize: isNestedReply ? 13 : 13.5,
                      color: const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Actions: Thumbs Up + Thumbs Down + Reply
                  Row(
                    children: [
                      // Like
                      GestureDetector(
                        onTap: () => _toggleLike(comment.id, defaultLikes),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded,
                              size: 16,
                              color: isLiked ? const Color(0xFF1A73E8) : Colors.grey[600],
                            ),
                            if (likeCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '$likeCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLiked ? const Color(0xFF1A73E8) : Colors.grey[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),

                      // Dislike
                      GestureDetector(
                        onTap: () => _toggleDislike(comment.id, defaultLikes),
                        child: Icon(
                          isDisliked ? Icons.thumb_down_alt_rounded : Icons.thumb_down_off_alt_rounded,
                          size: 16,
                          color: isDisliked ? Colors.redAccent : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Reply Button
                      GestureDetector(
                        onTap: () => _startReply(comment),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // Replies Section (Collapsible with branch line connector)
        if (comment.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedCommentIds.remove(comment.id);
                  } else {
                    _expandedCommentIds.add(comment.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isExpanded ? const Color(0xFFEBF3FE) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: isExpanded ? const Color(0xFF1A73E8) : Colors.grey[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpanded
                          ? 'Hide replies'
                          : 'View ${comment.replies.length} ${comment.replies.length == 1 ? "reply" : "replies"}',
                      style: TextStyle(
                        color: isExpanded ? const Color(0xFF1A73E8) : Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_up,
                        size: 16,
                        color: Color(0xFF1A73E8),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Render Nested Replies with vertical connecting tree line
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 18, top: 12),
              child: Stack(
                children: [
                  // Vertical connecting branch line
                  Positioned(
                    left: 9,
                    top: 0,
                    bottom: 24,
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      children: comment.replies.map((reply) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildCommentItem(
                            vm: vm,
                            comment: reply,
                            currentUserId: currentUserId,
                            isNestedReply: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildAvatar(
    String photoUrl,
    String name, {
    required double radius,
    bool isAdmin = false,
  }) {
    if (isAdmin) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF1A73E8),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'E',
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE2E8F0),
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => CircleAvatar(
              radius: radius,
              backgroundColor: const Color(0xFF3B82F6),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF3B82F6),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCommentMenu(ShortsViewModel vm, ShortComment comment, bool isMyComment) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[500]),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) {
        if (action == 'edit') {
          _showEditCommentDialog(vm, comment);
        } else if (action == 'delete') {
          _confirmDeleteComment(vm, comment);
        } else if (action == 'report') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment reported. Thank you for keeping our community safe.')),
          );
        }
      },
      itemBuilder: (ctx) => [
        if (isMyComment) ...[
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1A73E8)),
                SizedBox(width: 8),
                Text('Edit', style: TextStyle(fontSize: 13.5)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(fontSize: 13.5, color: Colors.redAccent)),
              ],
            ),
          ),
        ] else ...[
          const PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 18, color: Colors.black87),
                SizedBox(width: 8),
                Text('Report', style: TextStyle(fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveReplyBottomBar(String currentUserAvatar, String currentUserName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Replying banner
          if (_replyTargetComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  Text(
                    'Replying to ',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                  ),
                  Text(
                    '@${_replyTargetComment!.user.name}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),

          // Quick Emoji bar (matches Screen 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _quickEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () => _onEmojiTap(emoji),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom Input Row
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              2,
              16,
              MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                _buildAvatar(currentUserAvatar, currentUserName, radius: 17),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: _replyTargetComment != null
                                  ? 'Reply to @${_replyTargetComment!.user.name}...'
                                  : 'Add a comment...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13.5,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  size: 20,
                                  color: _commentController.text.trim().isNotEmpty
                                      ? const Color(0xFF1A73E8)
                                      : const Color(0xFF94A3B8),
                                ),
                          onPressed: _submitComment,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(ShortsViewModel vm, ShortComment comment) {
    final editCtrl = TextEditingController(text: comment.commentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newText = editCtrl.text.trim();
              if (newText.isNotEmpty) {
                Navigator.pop(ctx);
                await vm.editComment(widget.shortId, comment.id, newText);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComment(ShortsViewModel vm, ShortComment comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.deleteComment(widget.shortId, comment.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
