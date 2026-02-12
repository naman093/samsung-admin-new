import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final ValueChanged<bool>? onLoadStateChanged;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.onLoadStateChanged,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _shouldLoad = false;

  @override
  bool get wantKeepAlive => _isInitialized && !_hasError;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.isEmpty) {
      _hasError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLoadStateChanged?.call(true);
      });
    }
    // Delay initialization to allow scrolling to be smooth
    // Only load when widget is actually built and visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_hasError && !_isInitialized) {
          setState(() {
            _shouldLoad = true;
          });
          _initializeVideo();
        }
      });
    });
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.isEmpty || !_shouldLoad || _isInitialized) return;

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        await _controller!.seekTo(Duration.zero);
        _controller!.pause();
        widget.onLoadStateChanged?.call(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        widget.onLoadStateChanged?.call(true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_hasError || widget.videoUrl.isEmpty) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Image.asset(
          AppAssets.imageNotFound,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: widget.borderRadius,
          ),
          child: Stack(
            children: [
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.black.withOpacity(0.5),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(
                      color: AppColors.white,
                      radius: 12,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading video...',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}
