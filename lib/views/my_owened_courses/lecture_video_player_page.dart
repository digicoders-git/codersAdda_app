import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pod_player/pod_player.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class LectureVideoPlayerPage extends StatefulWidget {
  final CourseLecture lecture;
  final String courseId;
  final String topicId;

  const LectureVideoPlayerPage({Key? key, required this.lecture, required this.courseId, required this.topicId}) : super(key: key);

  @override
  State<LectureVideoPlayerPage> createState() => _LectureVideoPlayerPageState();
}

class _LectureVideoPlayerPageState extends State<LectureVideoPlayerPage> {
  PodPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _openPdf(String url) {
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InAppPdfViewerPage(
          pdfUrl: url,
          title: widget.lecture.title,
        ),
      ),
    );
  }

  void _initPlayer() {
    final url = widget.lecture.video.url.trim();
    if (url.isEmpty) {
      setState(() { _error = 'No video URL available'; _isLoading = false; });
      return;
    }

    PlayVideoFrom source;
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      source = PlayVideoFrom.youtube(url);
    } else if (url.contains('vimeo.com')) {
      source = PlayVideoFrom.vimeo(url);
    } else {
      source = PlayVideoFrom.network(url);
    }

    _controller = PodPlayerController(
      playVideoFrom: source,
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        isLooping: false,
        videoQualityPriority: [1080, 720, 360],
      ),
    )..initialise().then((_) {
        _controller?.play();
        _controller?.addListener(_onVideoStateChanged);
        _startProgressTimer();
        if (mounted) setState(() { _isLoading = false; });
      }).catchError((e) {
        if (mounted) setState(() { _error = 'Failed to load video: $e'; _isLoading = false; });
      });
  }

  bool _hasSentFinalProgress = false;

  void _onVideoStateChanged() {
    if (_controller == null || !_controller!.isInitialised) return;
    final position = _controller!.currentVideoPosition;
    final duration = _controller!.videoPlayerValue?.duration ?? Duration.zero;

    // Check if video is at the end or almost at the end (within 1 second)
    if (duration > Duration.zero && position >= duration - const Duration(seconds: 1)) {
      if (!_hasSentFinalProgress) {
        _hasSentFinalProgress = true;
        _sendProgressUpdate();
      }
    } else {
      _hasSentFinalProgress = false; // Reset if they scrub backwards
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_controller != null && _controller!.isVideoPlaying) {
        _sendProgressUpdate();
      }
    });
  }

  Future<void> _sendProgressUpdate() async {
    if (_controller == null || !_controller!.isInitialised) return;
    try {
      final position = _controller!.currentVideoPosition;
      final duration = _controller!.videoPlayerValue?.duration ?? Duration.zero;
      
      final data = {
        'courseId': widget.courseId,
        'topicId': widget.topicId,
        'lectureId': widget.lecture.id,
        'watchedSeconds': position.inSeconds,
        'durationSeconds': duration.inSeconds,
      };

      final apiClient = ApiClient();
      debugPrint('Sending progress update: $data');
      final response = await apiClient.post(ApiUrls.updateProgress, data);
      debugPrint('Progress update response: $response');
      
      if (response['success'] == true && response['certificateIssued'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Congratulations! Certificate Generated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Progress update error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoStateChanged);
    _progressTimer?.cancel();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        foregroundColor: AppColors.textColor,
        elevation: 0,
        title: Text(
          widget.lecture.title,
          style: TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Lecture number chip
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Lec ${widget.lecture.srNo}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Video Player Section ─────────────────────────────
          Container(
            width: double.infinity,
            color: Colors.black,
            child: _isLoading
                ? SizedBox(
                    height: 240,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text('Loading video...', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  )
                : _error != null
                    ? SizedBox(
                        height: 240,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style: TextStyle(color: AppColors.onSurfaceVariant),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () { setState(() { _isLoading = true; _error = null; }); _initPlayer(); },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    : PodVideoPlayer(controller: _controller!),
          ),

          // ── Lecture Info ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Duration row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.lecture.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: AppColors.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              widget.lecture.duration,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp13,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizer.deviceHeight1),

                  // Topic + Course row
                  Row(
                    children: [
                      Icon(Icons.bookmark, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${widget.lecture.topicName} • ${widget.lecture.courseName}',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (widget.lecture.description.isNotEmpty) ...[
                    SizedBox(height: AppSizer.deviceHeight2),
                    const Divider(),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      'About this Lecture',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      widget.lecture.description,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        color: AppColors.textColor.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                  ],

                  // PDF Resource section
                  if (widget.lecture.resource.url.isNotEmpty) ...[
                    SizedBox(height: AppSizer.deviceHeight2),
                    const Divider(),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      'Resources',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openPdf(widget.lecture.resource.url),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.picture_as_pdf, color: Colors.deepOrange, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Lecture Resource PDF',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('Tap to open',
                                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new, color: Colors.deepOrange, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
