import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/lecture_video_player_page.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'package:flutter/material.dart';

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
  List<CourseLecture> _lectures = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLectures();
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
                onPlay: () {
                  // Open dedicated video player page for this lecture
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LectureVideoPlayerPage(
                        lecture: lec,
                        courseId: widget.viewModel.course?.id?.isNotEmpty == true 
                            ? widget.viewModel.course!.id 
                            : widget.topic.course,
                        topicId: widget.topic.id,
                      ),
                    ),
                  );
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
    final bool hasVideo = lecture.video.url.isNotEmpty;
    final bool hasPdf = lecture.resource.url.isNotEmpty;

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
          // Thumbnail or placeholder header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                // Thumbnail
                lecture.thumbnail.url.isNotEmpty
                    ? Image.network(
                        lecture.thumbnail.url,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PlaceholderThumb(index: index),
                      )
                    : _PlaceholderThumb(index: index),
                // Gradient overlay
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
                // Lecture number badge
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
                // Lock/free badge
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
                // Duration badge at bottom right
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
                        const Icon(Icons.schedule, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(lecture.duration, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
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
                // Action Row
                Row(
                  children: [
                    // Play button
                    if (hasVideo)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onPlay,
                          icon: const Icon(Icons.play_circle_fill, size: 20),
                          label: const Text('Play Lecture'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (hasVideo && hasPdf) SizedBox(width: AppSizer.deviceWidth2),
                    // PDF button
                    if (hasPdf)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InAppPdfViewerPage(
                                  pdfUrl: lecture.resource.url,
                                  title: lecture.title,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('Resources'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            side: const BorderSide(color: Colors.deepOrange),
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
