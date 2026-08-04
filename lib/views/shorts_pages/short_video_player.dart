import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:coders_adda_app/models/shorts_model.dart';

class ShortVideoPlayer extends StatefulWidget {
  final ShortVideo short;
  final bool isCurrent;

  const ShortVideoPlayer({
    Key? key,
    required this.short,
    required this.isCurrent,
  }) : super(key: key);

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isPaused = false;
  bool _showPlayAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.9, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          if (widget.isCurrent) {
            _controller.play();
            _controller.setLooping(true);
          }
        }
      });
  }

  @override
  void didUpdateWidget(ShortVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isCurrent) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {
          _isPaused = false;
        });
      } else {
        _controller.pause();
        setState(() {
          _isPaused = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isInitialized) return;

    if (state == AppLifecycleState.paused) {
      _controller.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isCurrent) {
        _controller.play();
        setState(() {
          _isPaused = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onVideoTap() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() {
        _isPaused = true;
        _showPlayAnimation = false;
      });
    } else {
      _controller.play();
      setState(() {
        _isPaused = false;
        _showPlayAnimation = true;
      });
      _animationController.reset();
      _animationController.forward().then((_) {
        if (mounted) {
          setState(() {
            _showPlayAnimation = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _isInitialized
          ? GestureDetector(
              onTap: _onVideoTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                  
                  // Pause Icon (remains visible when paused)
                  if (_isPaused)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pause_rounded,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),

                  // Play Animation (pops and fades out when played)
                  if (_showPlayAnimation)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 55,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}
