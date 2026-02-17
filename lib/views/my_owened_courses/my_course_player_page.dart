// import 'package:coders_adda_app/models/my_cource_model.dart';
// import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
// import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class CoursePlayerPage extends StatefulWidget {
//   final MyCourse course;

//   const CoursePlayerPage({Key? key, required this.course}) : super(key: key);

//   @override
//   State<CoursePlayerPage> createState() => _CoursePlayerPageState();
// }

// class _CoursePlayerPageState extends State<CoursePlayerPage> {
//   VideoPlayerController? _videoController;
//   int _currentVideoIndex = 0;
//   bool _isVideoPlaying = false;

//   // Demo videos list - replace with your actual videos
//   final List<CourseVideo> _videos = [
//     CourseVideo(
//       id: '1',
//       title: 'Introduction to Flutter',
//       duration: '10:30',
//       videoUrl: 'https://example.com/video1.mp4',
//       isCompleted: true,
//     ),
//     CourseVideo(
//       id: '2',
//       title: 'Widgets and Layouts',
//       duration: '15:45',
//       videoUrl: 'https://example.com/video2.mp4',
//       isCompleted: false,
//     ),
//     CourseVideo(
//       id: '3',
//       title: 'State Management',
//       duration: '20:15',
//       videoUrl: 'https://example.com/video3.mp4',
//       isCompleted: false,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }

//   void _initializeVideoPlayer() {
//     if (_videos.isNotEmpty) {
//       _videoController = VideoPlayerController.network(
//         _videos[_currentVideoIndex].videoUrl,
//       )..initialize().then((_) {
//           setState(() {});
//         });
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }

//   void _playPauseVideo() {
//     if (_videoController != null) {
//       setState(() {
//         _isVideoPlaying = !_isVideoPlaying;
//         _isVideoPlaying 
//             ? _videoController!.play()
//             : _videoController!.pause();
//       });
//     }
//   }

//   void _playVideo(int index) {
//     setState(() {
//       _currentVideoIndex = index;
//       _isVideoPlaying = false;
//     });
    
//     _videoController?.dispose();
//     _videoController = VideoPlayerController.network(
//       _videos[index].videoUrl,
//     )..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   void _markVideoAsCompleted(int index) {
//     setState(() {
//       _videos[index].isCompleted = true;
//     });
//     // Here you would typically update this in your database/backend
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.course.title,
//           style: TextStyle(fontSize: AppSizer.deviceSp16),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.download),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Video Player Section
//           Container(
//             height: AppSizer.deviceHeight30,
//             color: Colors.black,
//             child: _videoController != null && _videoController!.value.isInitialized
//                 ? Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       VideoPlayer(_videoController!),
                      
//                       // Play/Pause Button
//                       if (!_isVideoPlaying)
//                         IconButton(
//                           icon: Icon(
//                             Icons.play_circle_filled,
//                             color: Colors.white,
//                             size: AppSizer.deviceSp40,
//                           ),
//                           onPressed: _playPauseVideo,
//                         ),
                      
//                       // Video Controls
//                       Positioned(
//                         bottom: 10,
//                         left: 10,
//                         right: 10,
//                         child: Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 _isVideoPlaying ? Icons.pause : Icons.play_arrow,
//                                 color: Colors.white,
//                               ),
//                               onPressed: _playPauseVideo,
//                             ),
//                             Expanded(
//                               child: VideoProgressIndicator(
//                                 _videoController!,
//                                 allowScrubbing: true,
//                                 colors: VideoProgressColors(
//                                   playedColor: AppColors.primaryColor,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               '${_videoController!.value.position.inMinutes}:${(_videoController!.value.position.inSeconds % 60).toString().padLeft(2, '0')} / ${_videoController!.value.duration.inMinutes}:${(_videoController!.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
//                               style: TextStyle(color: Colors.white, fontSize: AppSizer.deviceSp12),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//                 : Center(
//                     child: CircularProgressIndicator(
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//           ),
          
//           // Current Video Info
//           Container(
//             padding: EdgeInsets.all(AppSizer.deviceWidth4),
//             color: AppColors.surfaceVariant,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _videos[_currentVideoIndex].title,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: AppSizer.deviceSp16,
//                         ),
//                       ),
//                       SizedBox(height: AppSizer.deviceHeight0_5),
//                       Text(
//                         'Duration: ${_videos[_currentVideoIndex].duration}',
//                         style: TextStyle(
//                           color: AppColors.onSurfaceVariant,
//                           fontSize: AppSizer.deviceSp12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!_videos[_currentVideoIndex].isCompleted)
//                   ElevatedButton(
//                     onPressed: () => _markVideoAsCompleted(_currentVideoIndex),
//                     child: Text('Mark Complete'),
//                   )
//                 else
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: AppSizer.deviceWidth3,
//                       vertical: AppSizer.deviceHeight1,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.successColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle, 
//                           color: AppColors.successColor, 
//                           size: AppSizer.deviceSp16,
//                         ),
//                         SizedBox(width: AppSizer.deviceWidth1),
//                         Text(
//                           'COMPLETED',
//                           style: TextStyle(
//                             color: AppColors.successColor,
//                             fontSize: AppSizer.deviceSp12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
          
//           // Videos List
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(AppSizer.deviceWidth4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Course Content',
//                     style: TextStyle(
//                       fontSize: AppSizer.deviceSp18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: AppSizer.deviceHeight2),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: _videos.length,
//                       itemBuilder: (context, index) {
//                         final video = _videos[index];
//                         return Card(
//                           margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
//                           color: index == _currentVideoIndex 
//                               ? AppColors.primaryColor.withOpacity(0.1) 
//                               : Colors.white,
//                           child: ListTile(
//                             leading: Container(
//                               width: AppSizer.deviceWidth8,
//                               height: AppSizer.deviceWidth8,
//                               decoration: BoxDecoration(
//                                 color: video.isCompleted 
//                                     ? AppColors.successColor 
//                                     : AppColors.primaryColor,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 video.isCompleted ? Icons.check : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: AppSizer.deviceSp12,
//                               ),
//                             ),
//                             title: Text(
//                               video.title,
//                               style: TextStyle(
//                                 fontWeight: index == _currentVideoIndex 
//                                     ? FontWeight.bold 
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                             subtitle: Text(
//                               video.duration,
//                               style: TextStyle(fontSize: AppSizer.deviceSp12),
//                             ),
//                             trailing: video.isCompleted
//                                 ? Text(
//                                     'COMPLETED',
//                                     style: TextStyle(
//                                       color: AppColors.successColor,
//                                       fontSize: AppSizer.deviceSp10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   )
//                                 : null,
//                             onTap: () => _playVideo(index),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CourseVideo {
//   final String id;
//   final String title;
//   final String duration;
//   final String videoUrl;
//   bool isCompleted;

//   CourseVideo({
//     required this.id,
//     required this.title,
//     required this.duration,
//     required this.videoUrl,
//     this.isCompleted = false,
//   });
// }

import 'package:coders_adda_app/models/my_cource_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursePlayerPage extends StatefulWidget {
  final MyCourse course;

  const CoursePlayerPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CoursePlayerPage> createState() => _CoursePlayerPageState();
}

class _CoursePlayerPageState extends State<CoursePlayerPage> {
  VideoPlayerController? _videoController;
  int _currentVideoIndex = 0;
  bool _isVideoPlaying = false;
  bool _showFullDescription = false;

  // Demo videos list with GitHub links
  final List<CourseVideo> _videos = [
    CourseVideo(
      id: '1',
      title: 'Introduction to Flutter - Getting Started',
      duration: '10:30',
      videoUrl: 'https://example.com/video1.mp4',
      isCompleted: true,
      description: 'Learn the basics of Flutter framework and set up your development environment.',
      githubLink: 'https://github.com/codersadda/flutter-intro-code',
    ),
    CourseVideo(
      id: '2',
      title: 'Widgets and Layouts - Building UI',
      duration: '15:45',
      videoUrl: 'https://example.com/video2.mp4',
      isCompleted: false,
      description: 'Understand different widgets and how to create beautiful layouts in Flutter.',
      githubLink: 'https://github.com/codersadda/flutter-widgets-code',
    ),
    CourseVideo(
      id: '3',
      title: 'State Management with Provider',
      duration: '20:15',
      videoUrl: 'https://example.com/video3.mp4',
      isCompleted: false,
      description: 'Master state management using Provider pattern for scalable applications.',
      githubLink: 'https://github.com/codersadda/flutter-state-management',
    ),
    CourseVideo(
      id: '4',
      title: 'API Integration and HTTP Requests',
      duration: '18:30',
      videoUrl: 'https://example.com/video4.mp4',
      isCompleted: false,
      description: 'Learn how to integrate APIs and make HTTP requests in Flutter applications.',
      githubLink: 'https://github.com/codersadda/flutter-api-integration',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (_videos.isNotEmpty) {
      _videoController = VideoPlayerController.network(
        _videos[_currentVideoIndex].videoUrl,
      )..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _playPauseVideo() {
    if (_videoController != null) {
      setState(() {
        _isVideoPlaying = !_isVideoPlaying;
        _isVideoPlaying 
            ? _videoController!.play()
            : _videoController!.pause();
      });
    }
  }

  void _playVideo(int index) {
    setState(() {
      _currentVideoIndex = index;
      _isVideoPlaying = false;
      _showFullDescription = false;
    });
    
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(
      _videos[index].videoUrl,
    )..initialize().then((_) {
        setState(() {});
        if (_isVideoPlaying) {
          _videoController!.play();
        }
      });
  }

  void _markVideoAsCompleted(int index) {
    setState(() {
      _videos[index].isCompleted = true;
    });
  }

  void _launchGithubLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = _videos[_currentVideoIndex];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Video Player Section (Fixed at top)
          Container(
            height: AppSizer.deviceHeight30,
            color: Colors.black,
            child: _videoController != null && _videoController!.value.isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _playPauseVideo,
                        child: VideoPlayer(_videoController!),
                      ),
                      
                      // Play/Pause Overlay
                      if (!_isVideoPlaying)
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 200),
                          opacity: _isVideoPlaying ? 0 : 1,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      
                      // Video Controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          child: Column(
                            children: [
                              VideoProgressIndicator(
                                _videoController!,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.grey.shade700,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizer.deviceWidth3,
                                  vertical: AppSizer.deviceHeight1,
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      onPressed: _playPauseVideo,
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth2),
                                    Expanded(
                                      child: Text(
                                        '${_videoController!.value.position.inMinutes}:${(_videoController!.value.position.inSeconds % 60).toString().padLeft(2, '0')} / ${_videoController!.value.duration.inMinutes}:${(_videoController!.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.white, 
                                          fontSize: AppSizer.deviceSp12,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.fullscreen, color: Colors.white),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
          ),
          
          // Content Area (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Info Section (Like YouTube)
                  Container(
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Title
                        Text(
                          currentVideo.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        
                        // Video Stats and Actions
                        Row(
                          children: [
                            // Completion Status
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth3,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                color: currentVideo.isCompleted 
                                    ? AppColors.successColor.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    currentVideo.isCompleted 
                                        ? Icons.check_circle 
                                        : Icons.play_circle_filled,
                                    color: currentVideo.isCompleted 
                                        ? AppColors.successColor
                                        : Colors.orange,
                                    size: AppSizer.deviceSp14,
                                  ),
                                  SizedBox(width: AppSizer.deviceWidth1),
                                  Text(
                                    currentVideo.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp12,
                                      fontWeight: FontWeight.bold,
                                      color: currentVideo.isCompleted 
                                          ? AppColors.successColor
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            // Mark Complete Button
                            if (!currentVideo.isCompleted)
                              ElevatedButton(
                                onPressed: () => _markVideoAsCompleted(_currentVideoIndex),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Mark Complete',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: AppSizer.deviceHeight2),
                        
                        // Description Section
                        Container(
                          padding: EdgeInsets.all(AppSizer.deviceWidth3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight1),
                              Text(
                                _showFullDescription 
                                    ? currentVideo.description
                                    : currentVideo.description.length > 100
                                        ? '${currentVideo.description.substring(0, 100)}...'
                                        : currentVideo.description,
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                              if (currentVideo.description.length > 100)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showFullDescription = !_showFullDescription;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 30),
                                  ),
                                  child: Text(
                                    _showFullDescription ? 'Show less' : 'View more',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight2),
                        
                        // GitHub Link Section
                        Container(
                          padding: EdgeInsets.all(AppSizer.deviceWidth3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.code,
                                color: Colors.white,
                                size: AppSizer.deviceSp20,
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Source Code',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppSizer.deviceSp14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Get the complete code for this lesson',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: AppSizer.deviceSp12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              ElevatedButton(
                                onPressed: () => _launchGithubLink(currentVideo.githubLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/github.png',
                                      width: AppSizer.deviceSp16,
                                      height: AppSizer.deviceSp16,
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth1),
                                    Text(
                                      'GitHub',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: AppSizer.deviceSp12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Playlist Section (Like YouTube)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppSizer.deviceWidth4),
                          child: Text(
                            '${_videos.length} lessons • ${_calculateTotalDuration()}',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSizer.deviceWidth4,
                                  vertical: AppSizer.deviceHeight1,
                                ),
                                leading: Container(
                                  width: AppSizer.deviceWidth10,
                                  height: AppSizer.deviceWidth10,
                                  decoration: BoxDecoration(
                                    color: index == _currentVideoIndex 
                                        ? Colors.red 
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    index == _currentVideoIndex 
                                        ? Icons.play_arrow 
                                        : (video.isCompleted ? Icons.check : Icons.play_circle_outline),
                                    color: Colors.white,
                                    size: AppSizer.deviceSp16,
                                  ),
                                ),
                                title: Text(
                                  video.title,
                                  style: TextStyle(
                                    fontWeight: index == _currentVideoIndex 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                    color: index == _currentVideoIndex 
                                        ? Colors.black 
                                        : Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      video.duration,
                                      style: TextStyle(fontSize: AppSizer.deviceSp12),
                                    ),
                                    if (video.isCompleted) ...[
                                      SizedBox(width: AppSizer.deviceWidth2),
                                      Icon(Icons.check_circle, 
                                        color: AppColors.successColor, 
                                        size: AppSizer.deviceSp14,
                                      ),
                                    ]
                                  ],
                                ),
                                trailing: index == _currentVideoIndex 
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSizer.deviceWidth2,
                                          vertical: AppSizer.deviceHeight0_5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'PLAYING',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: AppSizer.deviceSp10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () => _playVideo(index),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalDuration() {
    // This would calculate total duration from all videos
    // For demo, returning a fixed value
    return '1h 5m';
  }
}

class CourseVideo {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final String description;
  final String githubLink;
  bool isCompleted;

  CourseVideo({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.description,
    required this.githubLink,
    this.isCompleted = false,
  });
}