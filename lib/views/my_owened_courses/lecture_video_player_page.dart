import 'package:coders_adda_app/models/course_model.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pod_player/pod_player.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LectureVideoPlayerPage extends StatefulWidget {
  final CourseLecture lecture;
  final List<CourseLecture>? lectures;
  final int? currentIndex;
  final String courseId;
  final String topicId;

  const LectureVideoPlayerPage({
    Key? key,
    required this.lecture,
    this.lectures,
    this.currentIndex,
    required this.courseId,
    required this.topicId,
  }) : super(key: key);

  @override
  State<LectureVideoPlayerPage> createState() => _LectureVideoPlayerPageState();
}

class _LectureVideoPlayerPageState extends State<LectureVideoPlayerPage> {
  PodPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  Timer? _progressTimer;
  String? _certificateUrl;
  
  late CourseLecture _currentLecture;
  int _currentIndex = -1;
  bool _isFinished = false;
  bool _hasSentFinalProgress = false;
  
  bool _showCustomControls = false;
  Timer? _hideControlsTimer;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _currentLecture = widget.lecture;
    _currentIndex = widget.currentIndex ?? -1;
    _initPlayer();
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are offline. Please turn on mobile data or Wi-Fi.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }
  
  void _playNextLecture() {
    if (widget.lectures != null && _currentIndex < widget.lectures!.length - 1) {
      setState(() {
        _currentIndex++;
        _currentLecture = widget.lectures![_currentIndex];
        _isLoading = true;
        _error = null;
        _hasSentFinalProgress = false;
        _isFinished = false;
      });
      _controller?.dispose();
      _controller = null;
      _initPlayer();
    }
  }

  void _playPreviousLecture() {
    if (widget.lectures != null && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentLecture = widget.lectures![_currentIndex];
        _isLoading = true;
        _error = null;
        _hasSentFinalProgress = false;
        _isFinished = false;
      });
      _controller?.dispose();
      _controller = null;
      _initPlayer();
    }
  }

  void _openPdf(String url) {
    if (url.isEmpty) return;
    
    // Prefix relative URL with baseUrl
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
          title: _currentLecture.title,
        ),
      ),
    );
  }

  Future<void> _initPlayer() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() { _error = 'No internet connection. Cannot load video.'; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Cannot load video.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final url = (_currentLecture.contentType == 'live' && _currentLecture.liveUrl.isNotEmpty)
        ? _currentLecture.liveUrl.trim()
        : _currentLecture.video.url.trim();
        
    if (url.isEmpty) {
      setState(() { _error = 'No video/stream URL available'; _isLoading = false; });
      return;
    }

    PlayVideoFrom source;
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      source = PlayVideoFrom.youtube(url);
    } else if (url.contains('vimeo.com')) {
      source = PlayVideoFrom.vimeo(url);
    } else {
      source = PlayVideoFrom.networkQualityUrls(
        videoUrls: [
          VideoQalityUrls(quality: 1080, url: url),
          VideoQalityUrls(quality: 720, url: url),
          VideoQalityUrls(quality: 480, url: url),
          VideoQalityUrls(quality: 360, url: url),
        ],
      );
    }

    _controller = PodPlayerController(
      playVideoFrom: source,
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        isLooping: false,
        videoQualityPriority: [1080, 720, 360],
        forcedVideoFocus: true,
      ),
    )..initialise().then((_) {
        _controller?.play();
        _controller?.addListener(_onVideoStateChanged);
        _startProgressTimer();
        if (mounted) setState(() { _isLoading = false; });
      }).catchError((e) {
        if (mounted) {
          setState(() { _error = 'Failed to load video: Check your connection.'; _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video playback failed. Check your connection.'), backgroundColor: Colors.red),
          );
        }
      });
  }

  void _onVideoStateChanged() {
    if (_controller == null || !_controller!.isInitialised) return;

    final isPlaying = _controller!.isVideoPlaying;
    
    // When video pauses, keep controls visible
    if (!isPlaying) {
      setState(() {
        _showCustomControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      // When video plays, start timer to hide controls
      _hideControlsTimer?.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showCustomControls = false);
      });
    }

    final position = _controller!.currentVideoPosition;
    final duration = _controller!.videoPlayerValue?.duration ?? Duration.zero;

    // Check if video is at the end
    final isEnded = duration > Duration.zero && (position >= duration || position.inMilliseconds >= duration.inMilliseconds - 200);
    
    if (isEnded) {
      if (!_hasSentFinalProgress) {
        _hasSentFinalProgress = true;
        _sendProgressUpdate();
      }
      if (!_isFinished) {
        setState(() { _isFinished = true; });
      }
    } else {
      // Removed resetting of _hasSentFinalProgress so it only fires once per video load
      if (_isFinished && !isEnded) {
        setState(() { _isFinished = false; });
      }
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

      // Prevent duplicate certificate generation by not sending completion if already completed
      if (_currentLecture.isCompleted && position.inMilliseconds >= duration.inMilliseconds - 1000) {
        return; 
      }
      
      final data = {
        'courseId': widget.courseId,
        'topicId': widget.topicId,
        'lectureId': _currentLecture.id,
        'watchedSeconds': position.inSeconds,
        'durationSeconds': duration.inSeconds,
      };

      final apiClient = ApiClient();
      debugPrint('Sending progress update: $data');
      final response = await apiClient.post(ApiUrls.updateProgress, data);
      
      // Removed debug popup as per user request

      if (response['success'] == true && response['certificateIssued'] == true) {
        if (mounted) {
          setState(() {
            _certificateUrl = response['certificateUrl'];
          });
          // Removed SnackBar popup as per user request
        }
      } else if (response['success'] == false) {
        debugPrint('Progress update failed: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Progress update error: $e');
      if (mounted && _hasSentFinalProgress) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('API Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _controller?.removeListener(_onVideoStateChanged);
    _progressTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _showControlsTemporarily() {
    if (_showCustomControls) {
      // Tap when visible -> Hide instantly
      setState(() {
        _showCustomControls = false;
      });
      _hideControlsTimer?.cancel();
    } else {
      // Tap when hidden -> Show temporarily
      setState(() {
        _showCustomControls = true;
      });
      _hideControlsTimer?.cancel();
      
      // Only hide if video is playing
      if (_controller?.isVideoPlaying == true) {
        _hideControlsTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showCustomControls = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        foregroundColor: AppColors.logoNavy,
        elevation: 0,
        title: Text(
          _currentLecture.title,
          style: TextStyle(color: AppColors.logoNavy, fontSize: 16, fontWeight: FontWeight.bold),
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
              'Lec ${_currentLecture.srNo}',
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
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: PodVideoPlayer(
                          controller: _controller!,
                          videoTitle: const SizedBox.shrink(),
                        ),
                      ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_currentLecture.contentType == 'live') ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('LIVE 🔴', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    _currentLecture.title,
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.logoNavy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizer.deviceSp8),
                            
                            // DEBUG BUTTON - Commented out as per request
                            /*
                            ElevatedButton(
                              onPressed: () {
                                final data = {
                                  'courseId': widget.courseId,
                                  'topicId': widget.topicId,
                                  'lectureId': _currentLecture.id,
                                  'watchedSeconds': 200,
                                  'durationSeconds': 200,
                                };
                                
                                final apiClient = ApiClient();
                                apiClient.post(ApiUrls.updateProgress, data).then((response) {
                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('API Response (Take Screenshot)'),
                                        content: Text(response.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }).catchError((e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text("Test Complete Video (Click Me)", style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(height: AppSizer.deviceSp8),
                            */
                          ],
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
                              _currentLecture.duration,
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
                          '${_currentLecture.topicName} • ${_currentLecture.courseName}',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_currentLecture.description.isNotEmpty) ...[
                    SizedBox(height: AppSizer.deviceHeight2),
                    const Divider(),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      'About this Lecture',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logoNavy,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      _currentLecture.description,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        color: AppColors.logoNavy.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                  ],

                  // PDF Resource section
                  if (_currentLecture.resource.url.isNotEmpty) ...[
                    SizedBox(height: AppSizer.deviceHeight2),
                    const Divider(),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Text(
                      'Resources',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logoNavy,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openPdf(_currentLecture.resource.url),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
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
                            Icon(Icons.open_in_new, color: AppColors.primaryColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Certificate section
                  if (_certificateUrl != null && _certificateUrl!.isNotEmpty) ...[
                    SizedBox(height: AppSizer.deviceHeight2),
                    const Divider(),
                    SizedBox(height: AppSizer.deviceHeight1),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            if (_certificateUrl == null || _certificateUrl!.isEmpty) return;
                            try {
                              if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Downloading certificate...")),
                                  );
                                }
                                
                                var response = await Dio().get(
                                  _certificateUrl!, 
                                  options: Options(responseType: ResponseType.bytes)
                                );
                                final result = await ImageGallerySaverPlus.saveImage(
                                  Uint8List.fromList(response.data),
                                  quality: 100,
                                  name: "CodersAdda_Certificate_${DateTime.now().millisecondsSinceEpoch}",
                                );

                                if (result['isSuccess'] == true) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Certificate saved to gallery!")),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Failed to save certificate.")),
                                    );
                                  }
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Storage permission required.")),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Course Completed!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Download your Certificate',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.download_rounded, color: Colors.white),
                              ],
                            ),
                          ),
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
