import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/lecture_video_player_page.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'package:coders_adda_app/views/quiz_program_pages/play_quiz_page.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TopicLecturesPage extends StatefulWidget {
  final CurriculumTopic topic;
  final CoursePlayerViewModel viewModel;

  const TopicLecturesPage({
    Key? key,
    required this.topic,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<TopicLecturesPage> createState() => _TopicLecturesPageState();
}

class _TopicLecturesPageState extends State<TopicLecturesPage> {
  final CourseService _courseService = CourseService();
  final ApiClient _apiClient = ApiClient();
  List<CourseLecture> _lectures = [];
  bool _isLoading = true;
  String? _error;

  late Razorpay _razorpay;
  CourseLecture? _pendingPaymentLecture;
  String? _pendingOrderId;
  bool _paymentLoading = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchLectures();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchLectures() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final lectures = await _courseService.getLecturesByTopic(widget.topic.id);
      setState(() { _lectures = lectures; });
    } catch (e) {
      setState(() { _error = 'Failed to load lectures: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  /// Called when user taps a paid locked lecture — shows payment bottom sheet
  Future<void> _purchaseLecture(CourseLecture lecture) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaidLecturePaymentSheet(lecture: lecture),
    );
    if (confirm != true) return;

    setState(() { _paymentLoading = true; });
    try {
      final orderRes = await _apiClient.post(ApiUrls.createOrder, {
        'itemType': 'lecture',
        'itemId': lecture.id,
      });

      if (orderRes == null || orderRes['orderId'] == null) {
        _showSnackBar('Failed to create order. Try again.', Colors.red);
        return;
      }

      _pendingPaymentLecture = lecture;
      _pendingOrderId = orderRes['orderId'];

      final options = {
        'key': orderRes['key'],
        'amount': orderRes['amount'],
        'currency': orderRes['currency'] ?? 'INR',
        'name': 'CodersAdda',
        'description': lecture.title,
        'order_id': orderRes['orderId'],
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#6C63FF'},
      };
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar('Payment error: $e', Colors.red);
    } finally {
      setState(() { _paymentLoading = false; });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _apiClient.post(ApiUrls.verifyPayment, {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });
      _showSnackBar('Payment successful! Lecture unlocked 🎉', Colors.green);
      _fetchLectures(); // Reload to get video URL
    } catch (e) {
      _showSnackBar('Verification failed: $e', Colors.orange);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.message}', Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External wallet selected: ${response.walletName}', Colors.blue);
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic.topic,
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: AppSizer.deviceHeight2),
            Text('Loading lectures...', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            SizedBox(height: AppSizer.deviceHeight2),
            ElevatedButton.icon(
              onPressed: _fetchLectures,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            ),
          ],
        ),
      );
    }
    if (_lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: AppColors.onSurfaceVariant),
            SizedBox(height: AppSizer.deviceHeight2),
            Text('No lectures available for this topic',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: AppSizer.deviceSp16)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header count
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4, vertical: AppSizer.deviceHeight1),
          color: AppColors.primaryColor.withOpacity(0.05),
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, color: AppColors.primaryColor, size: 20),
              SizedBox(width: AppSizer.deviceWidth2),
              Text(
                '${_lectures.length} Lecture${_lectures.length > 1 ? 's' : ''} in this topic',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizer.deviceSp14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            itemCount: _lectures.length,
            itemBuilder: (context, index) {
              final lec = _lectures[index];
              return _LectureCard(
                lecture: lec,
                index: index,
                onPlay: () async {
                  // 1. Paid lecture guard — check isPaidLecture OR (locked + price > 0 + no video)
                  //    This is defense-in-depth: even if backend didn't set isPaidLecture correctly
                  //    (e.g. old lectures before price field was added), we still block here.
                  final needsPayment = lec.isPaidLecture ||
                      (lec.isLocked && lec.lecturePrice > 0 && lec.video.url.isEmpty);
                  if (needsPayment) {
                    _purchaseLecture(lec);
                    return;
                  }
                  // 2. Locked lecture with no URL — needs course enrollment (free lecture in paid course)
                  if (lec.isLocked && lec.video.url.isEmpty && lec.resource.url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This lecture is locked. Please purchase the course to access it.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (lec.contentType == 'test' && lec.quizId != null && lec.quizId!.isNotEmpty) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      final response = await ApiClient().get('${ApiUrls.getQuizzes}/${lec.quizId}');
                      if (context.mounted) Navigator.pop(context);
                      if (response != null && response['success'] == true && response['data'] != null) {
                        final quiz = response['data'];
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayQuizPage(
                                quizId: quiz['_id'] ?? '',
                                quizTitle: quiz['title'] ?? 'Quiz',
                                totalDurationMinutes: quiz['duration'] ?? 10,
                              ),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to load quiz details')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading quiz: $e')),
                        );
                      }
                    }
                  } else if (lec.contentType == 'youtube_zoom' || lec.contentType == 'webinar') {
                    if (lec.liveUrl.isNotEmpty) {
                      final uri = Uri.parse(lec.liveUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open stream/meeting link')),
                          );
                        }
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link is not available')),
                        );
                      }
                    }
                  } else if (lec.contentType == 'pdf') {
                    // Guard: locked pdf with no resource URL
                    if (lec.resource.url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This resource is locked. Please purchase the course to access it.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    String url = lec.resource.url;
                    if (url.startsWith('/')) {
                      url = '${ApiUrls.baseUrl}$url';
                    } else if (!url.startsWith('http')) {
                      url = '${ApiUrls.baseUrl}/$url';
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InAppPdfViewerPage(
                          pdfUrl: url,
                          title: lec.title,
                        ),
                      ),
                    );
                  } else {
                    // Guard: locked video with no URL
                    if (lec.video.url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This lecture is locked. Please purchase to access it.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LectureVideoPlayerPage(
                          lecture: lec,
                          lectures: _lectures,
                          currentIndex: index,
                          courseId: widget.viewModel.course?.id?.isNotEmpty == true 
                              ? widget.viewModel.course!.id 
                              : widget.topic.course,
                          topicId: widget.topic.id,
                        ),
                      ),
                    ).then((_) {
                      _fetchLectures();
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LectureCard extends StatelessWidget {
  final CourseLecture lecture;
  final int index;
  final VoidCallback onPlay;

  const _LectureCard({
    Key? key,
    required this.lecture,
    required this.index,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lecture.contentType == 'video' || lecture.contentType == 'live') {
      return Container(
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  lecture.thumbnail.url.isNotEmpty
                      ? Image.network(
                          lecture.thumbnail.url,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _PlaceholderThumb(index: index),
                        )
                      : _PlaceholderThumb(index: index),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Lecture ${lecture.srNo}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: lecture.isLocked ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(lecture.isLocked ? Icons.lock : Icons.lock_open, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            lecture.isLocked ? 'Locked' : 'Free',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            lecture.contentType == 'live' ? Icons.live_tv : Icons.schedule,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lecture.contentType == 'live' ? 'Live Stream' : lecture.duration,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lecture.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      if (lecture.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  if (lecture.description.isNotEmpty) ...[
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      lecture.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: AppSizer.deviceHeight2),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onPlay,
                          icon: Icon(
                            lecture.contentType == 'live'
                                ? Icons.live_tv
                                : (lecture.isCompleted ? Icons.replay : Icons.play_circle_fill),
                            size: 20,
                          ),
                          label: Text(
                            lecture.contentType == 'live'
                                ? (lecture.liveStatus == 'live'
                                    ? 'Join Live Stream 🔴'
                                    : (lecture.liveStatus == 'ended'
                                        ? 'Live Stream Ended'
                                        : 'Scheduled Live'))
                                : (lecture.isCompleted ? 'Replay' : 'Play Lecture'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lecture.contentType == 'live'
                                ? (lecture.liveStatus == 'live' ? Colors.red : Colors.grey)
                                : (lecture.isCompleted ? Colors.blue : AppColors.primaryColor),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
      );
    } else {
      Color typeColor;
      IconData typeIcon;
      String actionLabel;
      Color btnColor;
      
      if (lecture.contentType == 'pdf') {
        typeColor = Colors.red;
        typeIcon = Icons.picture_as_pdf;
        actionLabel = 'Read PDF / Notes';
        btnColor = Colors.red;
      } else if (lecture.contentType == 'test' || lecture.contentType == 'subjective_test') {
        typeColor = Colors.orange;
        typeIcon = Icons.assignment;
        actionLabel = 'Attempt Test (Quiz)';
        btnColor = Colors.orange;
      } else {
        typeColor = Colors.blue;
        typeIcon = Icons.launch;
        actionLabel = 'Open Meeting / Live Link';
        btnColor = Colors.blue;
      }

      return Container(
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: typeColor, width: 5),
            top: BorderSide(color: AppColors.outline.withOpacity(0.3)),
            right: BorderSide(color: AppColors.outline.withOpacity(0.3)),
            bottom: BorderSide(color: AppColors.outline.withOpacity(0.3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lecture.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                lecture.contentType.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (lecture.description.isNotEmpty) ...[
                SizedBox(height: AppSizer.deviceHeight1),
                Text(
                  lecture.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: AppSizer.deviceHeight2),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPlay,
                      icon: Icon(typeIcon, size: 18),
                      label: Text(actionLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _PlaceholderThumb extends StatelessWidget {
  final int index;
  const _PlaceholderThumb({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
      [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
      [const Color(0xFF00695C), const Color(0xFF26A69A)],
      [const Color(0xFFC62828), const Color(0xFFEF5350)],
    ];
    final pair = colors[index % colors.length];
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: pair, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_outlined, size: 56, color: Colors.white54),
      ),
    );
  }
}

class _PaidLecturePaymentSheet extends StatelessWidget {
  final CourseLecture lecture;

  const _PaidLecturePaymentSheet({Key? key, required this.lecture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Unlock Lecture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lecture.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            lecture.description.isNotEmpty ? lecture.description : 'This premium video requires a separate one-time purchase to unlock.',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                '₹${lecture.lecturePrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'PROCEED TO PAY',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
