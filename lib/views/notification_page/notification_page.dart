import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/notification_viewmodel.dart';
import 'package:coders_adda_app/models/notification_model.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/home_pages/all_course_details_page.dart';
import 'package:coders_adda_app/views/buy_new_pdf_pages/pdf_detail_page.dart';
import 'package:coders_adda_app/views/quiz_program_pages/quiz_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_player_page.dart';
import 'package:coders_adda_app/views/job_pages/job_page.dart';
import 'package:coders_adda_app/views/profile_pages/my_certificates_page.dart';

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  return '${(diff.inDays / 30).floor()}mo ago';
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  // Type → Icon mapping
  IconData _getIcon(String type) {
    String t = type.toLowerCase().replaceAll('_', '');
    if (t.contains('lecture') || t.contains('video')) return Icons.play_circle_outline_rounded;
    if (t.contains('topic') || t.contains('book')) return Icons.menu_book_rounded;
    if (t.contains('note') || t.contains('pdf')) return Icons.description_outlined;
    if (t.contains('quiz')) return Icons.quiz_rounded;
    if (t.contains('course')) return Icons.school_rounded;
    if (t.contains('offer') || t.contains('discount')) return Icons.local_offer_rounded;
    if (t.contains('alert') || t.contains('warning')) return Icons.warning_amber_rounded;
    if (t.contains('system')) return Icons.workspace_premium_rounded;
    return Icons.notifications_rounded;
  }

  Color _getIconBgColor(String type) {
    String t = type.toLowerCase().replaceAll('_', '');
    if (t.contains('lecture') || t.contains('video')) return AppColors.logoNavy.withOpacity(0.1);
    if (t.contains('topic') || t.contains('book')) return Colors.indigo.shade50;
    if (t.contains('note') || t.contains('pdf')) return Colors.teal.shade50;
    if (t.contains('quiz')) return Colors.pink.shade50;
    if (t.contains('course')) return Colors.blue.shade50;
    if (t.contains('offer') || t.contains('discount')) return AppColors.logoGreen.withOpacity(0.1);
    if (t.contains('alert') || t.contains('warning')) return Colors.red.shade50;
    if (t.contains('system')) return AppColors.logoOrange.withOpacity(0.1);
    return AppColors.primaryColor.withOpacity(0.08);
  }

  Color _getIconColor(String type) {
    String t = type.toLowerCase().replaceAll('_', '');
    if (t.contains('lecture') || t.contains('video')) return AppColors.logoNavy;
    if (t.contains('topic') || t.contains('book')) return Colors.indigo;
    if (t.contains('note') || t.contains('pdf')) return Colors.teal;
    if (t.contains('quiz')) return Colors.pink;
    if (t.contains('course')) return Colors.blue;
    if (t.contains('offer') || t.contains('discount')) return AppColors.logoGreen;
    if (t.contains('alert') || t.contains('warning')) return Colors.red;
    if (t.contains('system')) return AppColors.logoOrange;
    return AppColors.primaryColor;
  }

  // Grouping by date section label
  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDay = DateTime(date.year, date.month, date.day);

    if (notifDay == today) return 'Today';
    if (notifDay == yesterday) return 'Yesterday';
    final diff = today.difference(notifDay).inDays;
    if (diff <= 7) return 'This Week';
    return 'Older';
  }

  void _handleTap(BuildContext context, NotificationModel notif) {
    // Mark as read
    if (!notif.isRead) {
      context.read<NotificationViewModel>().markAsRead(notif.id);
    }

    // Navigate based on actionLink
    final link = notif.actionLink ?? '';
    if (link.isEmpty) return;

    _navigateToLink(context, link);
  }

  static void _navigateToLink(BuildContext context, String link) {
    try {
      if (link.startsWith('/course-detail/')) {
        final courseId = link.replaceFirst('/course-detail/', '');
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyLearningCoursePlayer(courseId: courseId)));
      }
      else if (link.startsWith('/ebook-details/')) {
        final ebookId = link.replaceFirst('/ebook-details/', '');
        final dummyPdf = PdfItem(
          id: ebookId, title: 'Loading...', description: '', fileSize: '', category: '', categoryId: '', isFree: false, priceType: 'paid', downloadUrl: '', thumbnail: '', uploadedAt: DateTime.now(), author: '', isActive: true
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => PdfDetailPage(pdf: dummyPdf)));
      }
      else if (link.startsWith('/course-test/')) {
        final courseId = link.replaceFirst('/course-test/', '');
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyLearningCoursePlayer(courseId: courseId)));
      }
      else if (link.trim().toLowerCase() == '/quiz') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage()));
      }
      else if (link == '/subscription') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionPage()));
      }
      else if (link == '/jobs' || link == '/job') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => JobsPage()));
      }
      else if (link == '/certificates' || link == '/my-certificates') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCertificatesPage()));
      }
      else {
        debugPrint('Unhandled notification link: $link');
      }
    } catch (e) {
      debugPrint('Navigation error for link $link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.logoNavy,
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.logoNavy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (_, vm, __) {
              if (vm.notifications.isEmpty || vm.notifications.every((n) => n.isRead)) {
                return const SizedBox();
              }
              return TextButton(
                onPressed: () => vm.markAllAsRead(),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizer.deviceSp13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (vm.notifications.isEmpty) {
            return _buildEmptyState(vm);
          }

          // Group notifications by date label
          final Map<String, List<NotificationModel>> grouped = {};
          final order = <String>[];
          for (final n in vm.notifications) {
            final label = _getDateLabel(n.createdAt);
            if (!grouped.containsKey(label)) {
              grouped[label] = [];
              order.add(label);
            }
            grouped[label]!.add(n);
          }

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () => vm.fetchNotifications(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight2,
              ),
              itemCount: order.length,
              itemBuilder: (context, sectionIdx) {
                final label = order[sectionIdx];
                final items = grouped[label]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(label),
                    SizedBox(height: AppSizer.deviceHeight1),
                    ...items.map((n) => _buildNotificationCard(context, n)),
                    SizedBox(height: AppSizer.deviceHeight2),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(NotificationViewModel vm) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => vm.fetchNotifications(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 40,
                  color: AppColors.primaryColor.withOpacity(0.5),
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight3),
              Text(
                'No Notifications Yet',
                style: TextStyle(
                  color: AppColors.logoNavy,
                  fontSize: AppSizer.deviceSp17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight1),
              Text(
                'You\'re all caught up!\nNew updates will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: AppSizer.deviceSp14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer.deviceHeight0_5),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.logoNavy,
          fontSize: AppSizer.deviceSp16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel n) {
    final iconBg = _getIconBgColor(n.type);
    final iconColor = _getIconColor(n.type);
    final icon = _getIcon(n.type);

    return GestureDetector(
      onTap: () => _handleTap(context, n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
        decoration: BoxDecoration(
          color: n.isRead
              ? AppColors.cardColor
              : AppColors.primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: n.isRead
                ? Colors.transparent
                : AppColors.primaryColor.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: AppSizer.deviceWidth12,
                height: AppSizer.deviceWidth12,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: AppSizer.deviceSp22),
              ),

              SizedBox(width: AppSizer.deviceWidth3),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              color: AppColors.logoNavy,
                              fontSize: AppSizer.deviceSp15,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: AppSizer.deviceWidth2,
                            height: AppSizer.deviceWidth2,
                            margin: EdgeInsets.only(
                              top: AppSizer.deviceHeight0_5,
                              left: AppSizer.deviceWidth2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight0_5),

                    Text(
                      n.body,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: AppSizer.deviceSp13,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSizer.deviceHeight0_5),

                    // Image preview if available
                    if (n.image != null && n.image!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          n.image!,
                          height: AppSizer.deviceHeight10,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight0_5),
                    ],

                    Row(
                      children: [
                        Text(
                          _timeAgo(n.createdAt),
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant.withOpacity(0.65),
                            fontSize: AppSizer.deviceSp12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (n.actionLink != null && n.actionLink!.isNotEmpty) ...[
                          const Spacer(),
                          Text(
                            'View →',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: AppSizer.deviceSp12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
  }
}