import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/data/model/interview/BotInterviewConfigModel.dart';
import 'package:job_world/data/model/interview/InterviewSessionModel.dart';
import 'package:job_world/util/colors.dart';

const String _aiIconAsset = "assets/png/ic_ai_icon.png";

/// Full-screen "live" interview experience shown after an AI interview
/// session has been started. Displays the AI interviewer as an animated
/// avatar, session info, and basic call controls.
class AiInterviewSessionScreen extends StatefulWidget {
  final InterviewSessionModel session;
  final BotInterviewConfigModel? config;

  const AiInterviewSessionScreen({
    super.key,
    required this.session,
    this.config,
  });

  @override
  State<AiInterviewSessionScreen> createState() => _AiInterviewSessionScreenState();
}

class _AiInterviewSessionScreenState extends State<AiInterviewSessionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final FlutterTts _tts = FlutterTts();

  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isAiSpeaking = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _tts.setStartHandler(() {
      if (mounted) setState(() => _isAiSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isAiSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isAiSpeaking = false);
    });
    _tts.setErrorHandler((message) {
      if (mounted) setState(() => _isAiSpeaking = false);
    });

    _startTimer();
    _speakGreeting();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _speakGreeting() async {
    final title = widget.config?.examTitle;
    final greeting = (title != null && title.isNotEmpty)
        ? "Hello! I'm your AI interviewer for the $title round. Whenever you're ready, let's begin."
        : "Hello! I'm your AI interviewer. Whenever you're ready, let's begin.";

    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.speak(greeting);
  }

  String get _formattedElapsed {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _confirmEndInterview() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("End interview?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to end this AI interview session?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text("End Interview", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (shouldEnd == true && mounted) {
      await _tts.stop();
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmEndInterview();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B1220), Color(0xFF1E1B4B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(child: Center(child: _buildAvatar())),
                _buildStatusText(),
                const SizedBox(height: 36),
                _buildControls(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TOP BAR
  // ----------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text(
            "LIVE",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(_formattedElapsed, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // AI AVATAR
  // ----------------------------------------------------------

  Widget _buildAvatar() {
    // The avatar pulses gently at rest and more strongly while the AI is speaking.
    final double maxRingScale = _isAiSpeaking ? 1.35 : 1.12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final t = _pulseController.value;
              final ringScale = 1.0 + (maxRingScale - 1.0) * t;
              final ringOpacity = (1.0 - t).clamp(0.0, 1.0);

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: ringScale,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: ringOpacity * 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.0 + (ringScale - 1.0) * 0.5,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: ringOpacity * 0.8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.45),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Image.asset(
                _aiIconAsset,
                fit: BoxFit.contain,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // STATUS TEXT
  // ----------------------------------------------------------

  Widget _buildStatusText() {
    final subtitle = widget.config?.label;

    return Column(
      children: [
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: "AI", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 20)),
              TextSpan(text: "-HR Interviewer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isAiSpeaking ? "Speaking..." : "Listening...",
          style: TextStyle(
            color: _isAiSpeaking ? AppColors.primaryBlue : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ],
    );
  }

  // ----------------------------------------------------------
  // CALL CONTROLS
  // ----------------------------------------------------------

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          background: Colors.white.withValues(alpha: 0.1),
          iconColor: Colors.white,
          onTap: () => setState(() => _isMuted = !_isMuted),
        ),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: Icons.call_end_rounded,
          background: Colors.redAccent,
          iconColor: Colors.white,
          size: 66,
          iconSize: 30,
          onTap: _confirmEndInterview,
        ),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
          background: Colors.white.withValues(alpha: 0.1),
          iconColor: Colors.white,
          onTap: () => setState(() => _isCameraOn = !_isCameraOn),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
