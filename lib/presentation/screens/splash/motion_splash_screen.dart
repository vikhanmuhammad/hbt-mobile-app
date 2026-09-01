import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Video intro played once at cold start, before the existing init/splash
/// flow (`AppBootstrap`) — picks the portrait or landscape cut based on the
/// device's orientation at launch and always fills the screen edge-to-edge
/// (`BoxFit.cover`, cropping overflow rather than letterboxing) regardless
/// of the video's native aspect ratio vs. the device's.
///
/// Never blocks startup indefinitely: a fallback timer calls [onFinished]
/// even if the asset fails to load/decode, and playback reaching the end
/// does the same.
class MotionSplashScreen extends StatefulWidget {
  const MotionSplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  static const _portraitAsset = 'assets/motion_splash/v_motion_daily_habit.mov';
  static const _landscapeAsset = 'assets/motion_splash/h_motion_daily_habit.mov';

  @override
  State<MotionSplashScreen> createState() => _MotionSplashScreenState();
}

class _MotionSplashScreenState extends State<MotionSplashScreen> {
  VideoPlayerController? _controller;
  bool _finished = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // Safety net — a corrupt/unsupported asset or a platform decoder issue
    // must never strand the user on a black screen forever.
    _fallbackTimer = Timer(const Duration(seconds: 8), _finish);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final asset = isPortrait ? MotionSplashScreen._portraitAsset : MotionSplashScreen._landscapeAsset;
    final controller = VideoPlayerController.asset(asset);
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onTick);
      setState(() => _controller = controller);
      await controller.play();
    } catch (_) {
      await controller.dispose();
      _finish();
    }
  }

  void _onTick() {
    final value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    if (!value.isPlaying && value.position >= value.duration) _finish();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _fallbackTimer?.cancel();
    widget.onFinished();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      body: !ready
          ? const SizedBox.shrink()
          : SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
    );
  }
}
