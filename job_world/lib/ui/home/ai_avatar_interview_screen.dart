import 'dart:async';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:job_world/data/model/interview/BotInterviewConfigModel.dart';
import 'package:job_world/data/model/interview/InterviewSessionModel.dart';
import 'package:job_world/util/colors.dart';

const String _aiIconAsset = "assets/png/ic_ai_icon.png";

enum _MicPermissionPhase {
  checking,
  denied,
  permanentlyDenied,
  granted,
}

/// Live AI Avatar interview: joins the LiveKit room returned by
/// `/interview/start-session/` and renders the realtime conversation with
/// the AI interviewer agent running in that room (audio, optional avatar
/// video, and the agent's transcription stream).
class AiAvatarInterviewScreen extends StatefulWidget {
  final InterviewSessionModel session;
  final BotInterviewConfigModel? config;

  const AiAvatarInterviewScreen({
    super.key,
    required this.session,
    this.config,
  });

  @override
  State<AiAvatarInterviewScreen> createState() => _AiAvatarInterviewScreenState();
}

class _AiAvatarInterviewScreenState extends State<AiAvatarInterviewScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();

  _MicPermissionPhase _micPermissionPhase = _MicPermissionPhase.checking;
  Session? _session;

  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  bool _micMuted = false;
  bool _videoEnabled = false;
  bool _videoActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _requestMicAndConnect();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    final session = _session;
    if (session != null) {
      session.removeListener(_onSessionChanged);
      unawaited(session.end());
      unawaited(session.dispose());
    }
    super.dispose();
  }

  // ----------------------------------------------------------
  // CONNECTION / PERMISSION LIFECYCLE
  // ----------------------------------------------------------

  Future<void> _requestMicAndConnect() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;

    if (status.isGranted) {
      setState(() => _micPermissionPhase = _MicPermissionPhase.granted);
      await _startSession();
    } else if (status.isPermanentlyDenied) {
      setState(() => _micPermissionPhase = _MicPermissionPhase.permanentlyDenied);
    } else {
      setState(() => _micPermissionPhase = _MicPermissionPhase.denied);
    }
  }

  Future<void> _startSession() async {
    final tokenSource = LiteralTokenSource(
      serverUrl: widget.session.livekitUrl,
      participantToken: widget.session.token,
      roomName: widget.session.roomName,
    );

    final session = Session.fromFixedTokenSource(
      tokenSource,
      options: SessionOptions(preConnectAudio: false),
    );
    session.addListener(_onSessionChanged);

    setState(() => _session = session);
    _startTimer();

    await session.start();
  }

  void _onSessionChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleAutoScroll();
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _scheduleAutoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String get _formattedElapsed {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // ----------------------------------------------------------
  // CONTROLS
  // ----------------------------------------------------------

  Future<void> _toggleMute() async {
    final session = _session;
    if (session == null) return;
    final nextMuted = !_micMuted;
    await session.room.localParticipant?.setMicrophoneEnabled(!nextMuted);
    if (mounted) setState(() => _micMuted = nextMuted);
  }

  Future<void> _toggleVideo() async {
    final session = _session;
    if (session == null || _videoActionInProgress) return;

    setState(() => _videoActionInProgress = true);

    if (_videoEnabled) {
      await session.room.localParticipant?.setCameraEnabled(false);
      if (mounted) setState(() => _videoEnabled = false);
      if (mounted) setState(() => _videoActionInProgress = false);
      return;
    }

    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      await session.room.localParticipant?.setCameraEnabled(true);
      if (mounted) setState(() => _videoEnabled = true);
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog("Camera");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
    }
    if (mounted) setState(() => _videoActionInProgress = false);
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
      await _session?.end();
      if (mounted) context.pop();
    }
  }

  void _showOpenSettingsDialog(String feature) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("$feature access needed", style: const TextStyle(color: Colors.white)),
        content: Text(
          "$feature permission is permanently denied. Please enable it from app settings to continue.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              openAppSettings();
            },
            child: const Text("Open Settings", style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasSession = _session != null;

    return PopScope(
      canPop: !hasSession,
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
                _buildTopBar(context, hasSession),
                Expanded(child: _buildBody(context)),
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

  Widget _buildTopBar(BuildContext context, bool hasSession) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          if (!hasSession)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            )
          else ...[
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
          ],
          const Spacer(),
          if (hasSession)
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
  // BODY (permission gate -> live interview)
  // ----------------------------------------------------------

  Widget _buildBody(BuildContext context) {
    switch (_micPermissionPhase) {
      case _MicPermissionPhase.checking:
        return _buildCenteredMessage(
          icon: Icons.mic_none_rounded,
          title: "Requesting microphone access…",
          message: "We need your microphone so you can speak your answers to the AI interviewer.",
        );
      case _MicPermissionPhase.denied:
        return _buildCenteredMessage(
          icon: Icons.mic_off_rounded,
          title: "Microphone permission needed",
          message: "The AI interviewer can't hear you without microphone access.",
          actionLabel: "Grant Access",
          onAction: _requestMicAndConnect,
        );
      case _MicPermissionPhase.permanentlyDenied:
        return _buildCenteredMessage(
          icon: Icons.mic_off_rounded,
          title: "Microphone permission blocked",
          message: "Please enable microphone access for Job World from your device settings to continue.",
          actionLabel: "Open Settings",
          onAction: () => openAppSettings(),
        );
      case _MicPermissionPhase.granted:
        final session = _session;
        if (session == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }
        return ListenableBuilder(
          listenable: session,
          builder: (context, _) => _buildLiveInterview(context, session),
        );
    }
  }

  Widget _buildCenteredMessage({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 56),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // LIVE INTERVIEW
  // ----------------------------------------------------------

  Widget _buildLiveInterview(BuildContext context, Session session) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildAvatar(session),
              if (_videoEnabled)
                Positioned(
                  right: 16,
                  top: 8,
                  child: _buildCameraPreview(session),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusText(session),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTranscript(session),
          ),
        ),
        _buildControls(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAvatar(Session session) {
    final agent = session.agent;
    final avatarVideoTrack = agent.avatarVideoTrack;

    if (avatarVideoTrack != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 200,
          height: 200,
          child: VideoTrackRenderer(avatarVideoTrack, fit: VideoViewFit.cover),
        ),
      );
    }

    final bool isSpeaking = agent.agentState == AgentState.speaking;
    final double maxRingScale = isSpeaking ? 1.35 : 1.12;

    return SizedBox(
      width: 200,
      height: 200,
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
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: ringOpacity * 0.6),
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
    );
  }

  Widget _buildCameraPreview(Session session) {
    final publications = session.room.localParticipant?.videoTrackPublications ?? const [];
    final track = publications.isEmpty ? null : publications.first.track;
    if (track == null) return const SizedBox.shrink();

    return Container(
      width: 84,
      height: 112,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: VideoTrackRenderer(track, fit: VideoViewFit.cover),
    );
  }

  Widget _buildStatusText(Session session) {
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
          _statusLabel(session),
          style: TextStyle(
            color: session.agent.agentState == AgentState.speaking ? AppColors.primaryBlue : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ],
    );
  }

  String _statusLabel(Session session) {
    if (session.connectionState == ConnectionState.connecting) {
      return "Connecting…";
    }
    if (session.connectionState == ConnectionState.reconnecting) {
      return "Reconnecting…";
    }
    if (session.connectionState == ConnectionState.disconnected) {
      return "Disconnected";
    }

    final agent = session.agent;
    if (agent.error != null) return agent.error!.message;
    if (session.error != null) return session.error!.message;
    if (agent.isPending) return "Getting ready…";

    switch (agent.agentState) {
      case AgentState.listening:
        return "Listening…";
      case AgentState.thinking:
        return "Thinking…";
      case AgentState.speaking:
        return "Speaking…";
      default:
        return "Connecting to interviewer…";
    }
  }

  // ----------------------------------------------------------
  // TRANSCRIPT
  // ----------------------------------------------------------

  Widget _buildTranscript(Session session) {
    final messages = session.messages;

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          "Your conversation will appear here once the interview begins.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(context, messages[index]),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ReceivedMessage message) {
    final content = message.content;
    final text = content.text.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final bool isAgent = content is AgentTranscript;

    return Align(
      alignment: isAgent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        decoration: BoxDecoration(
          color: isAgent ? Colors.white.withValues(alpha: 0.08) : AppColors.primaryBlue.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAgent ? "AI Interviewer" : "You",
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4),
            ),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3)),
          ],
        ),
      ),
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
          icon: _micMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          background: Colors.white.withValues(alpha: 0.1),
          iconColor: Colors.white,
          onTap: _toggleMute,
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
          icon: _videoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
          background: Colors.white.withValues(alpha: 0.1),
          iconColor: Colors.white,
          onTap: _toggleVideo,
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
