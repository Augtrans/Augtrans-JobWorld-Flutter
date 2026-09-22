import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'AiInterviewViewModel.dart';

const String _aiIconAsset = "assets/png/ic_ai_icon.png";

const String _interviewRulesText = 'Welcome to your AI-powered Practice Interview. First, select the interview title you want to practice from the available interview options. Once you have selected the interview, click the "Get Started" button to proceed to the interview screen. On the interview screen, click the "Start Interview" button to begin your practice interview. After each question, answer naturally and confidently. Please make sure your camera is allowed and always kept on during the interview. When you have completed the interview, simply say "Thank you" to end and submit your interview. Good luck, and all the best with your practice interview!';

class AiInterviewScreen extends ConsumerStatefulWidget {
  const AiInterviewScreen({super.key});

  @override
  ConsumerState<AiInterviewScreen> createState() => _AiInterviewScreenState();
}

class _AiInterviewScreenState extends ConsumerState<AiInterviewScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isRulesAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isRulesAudioPlaying = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isRulesAudioPlaying = false);
    });
    _tts.setErrorHandler((message) {
      if (mounted) setState(() => _isRulesAudioPlaying = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleRulesAudio() async {
    if (_isRulesAudioPlaying) {
      await _tts.stop();
      if (mounted) setState(() => _isRulesAudioPlaying = false);
      return;
    }

    setState(() => _isRulesAudioPlaying = true);
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.speak(_interviewRulesText);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiInterviewViewModelProvider);

    ref.listen(aiInterviewViewModelProvider.select((s) => s.sessionStatus), (previous, next) {
      next.whenOrNull(
        data: (session) {
          if (previous is AsyncLoading && session != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Interview session started (Room: ${session.roomName})")),
              );
            });
          }
        },
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Could not start interview: $error")),
            );
          });
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: Dimensions.level2Margin(context) + 12,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildMenuButton(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _horizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AI Interview",
                style: TextStyle(
                  fontSize: Dimensions.xlargeTextSize(context) + 2,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),

              Dimensions.verticalSpace(context, 8),

              Text(
                "Master the logic and syntax of modern development through curated challenges across 15+ specializations.",
                style: TextStyle(
                  fontSize: Dimensions.utilizationTextSize(context) + 2,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              Dimensions.verticalSpace(context, 30),

              _buildMainCard(context, state),

              Dimensions.verticalSpace(context, 24),

              _buildInstructionsCard(context),

              Dimensions.verticalSpace(context, 40),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // RESPONSIVE HORIZONTAL PADDING
  // ----------------------------------------------------------

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) {
      return 12;
    }

    if (width < 600) {
      return 16;
    }

    return Dimensions.level4Margin(context) - 8;
  }

  // ----------------------------------------------------------
  // MENU BUTTON
  // ----------------------------------------------------------

  Widget _buildMenuButton(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.menu,
        color: Colors.white,
        size: Dimensions.level2Margin(context) + 12,
      ),
    );
  }

  // ----------------------------------------------------------
  // MAIN CARD
  // ----------------------------------------------------------

  Widget _buildMainCard(BuildContext context, AiInterviewState state) {
    final isStarting = state.sessionStatus is AsyncLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        _cardPadding(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // AI icon
          Image.asset(
            _aiIconAsset,
            height: _globeSize(context) * 1.5,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.language_rounded,
              size: Dimensions.level3Size(context) + 40,
              color: AppColors.primaryBlue,
            ),
          ),

          Dimensions.verticalSpace(context, 24),

          // AI-HR
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "AI",
                  style: TextStyle(
                    fontSize: Dimensions.xlargeTextSize(context) - 2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                TextSpan(
                  text: "-HR",
                  style: TextStyle(
                    fontSize: Dimensions.xlargeTextSize(context) - 2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          Dimensions.verticalSpace(context, 12),

          Text(
            "Step into the Future with Smart, AI-Driven Interviewing.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimensions.utilizationTextSize(context) + 2,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),

          Dimensions.verticalSpace(context, 32),

          // Configure Interview
          _buildConfigureInterview(context),

          Dimensions.verticalSpace(context, 24),

          // Focus Area
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    "FOCUS AREA",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimensions.utilizationTextSize(context) - 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: Dimensions.level2Margin(context),
                ),
              ],
            ),
          ),

          Dimensions.verticalSpace(context, 12),

          // Focus area dropdown, populated from /interview/bot-interview-configs/
          _buildFocusAreaDropdown(context, state),

          Dimensions.verticalSpace(context, 32),

          // Start Interview
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (isStarting || state.selectedConfig == null)
                  ? null
                  : () => ref.read(aiInterviewViewModelProvider.notifier).startInterviewSession(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
              ),
              child: isStarting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            "Start Interview",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.level3Margin(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: Dimensions.level2Padding(context) * 2 + 4,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- //
  // FOCUS AREA DROPDOWN(from/interview/bot-interview-configs/) //
  // ---------------------------------------------------------- //

  Widget _buildFocusAreaDropdown(BuildContext context, AiInterviewState state) {
    return state.configs.when(
      loading: () => _buildFocusAreaBox(
        context,
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Text(
              "Loading interview options...",
              style: TextStyle(
                fontSize: Dimensions.utilizationTextSize(context) + 2,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => _buildFocusAreaBox(
        context,
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Could not load interview options",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(aiInterviewViewModelProvider.notifier).fetchBotInterviewConfigs(force: true),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
      data: (configs) {
        if (configs.isEmpty) {
          return _buildFocusAreaBox(
            context,
            child: Text(
              "No interview configurations available",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade500),
            ),
          );
        }

        final selected = state.selectedConfig ?? configs.first;

        return _buildFocusAreaBox(
          context,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: configs.any((c) => c.configId == selected.configId) ? selected.configId : configs.first.configId,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
              style: TextStyle(
                fontSize: Dimensions.utilizationTextSize(context) + 2,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
              items: configs
                  .map(
                    (config) => DropdownMenuItem<int>(
                      value: config.configId,
                      child: Text(config.label, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (configId) {
                final chosen = configs.firstWhere(
                  (c) => c.configId == configId,
                  orElse: () => configs.first,
                );
                ref.read(aiInterviewViewModelProvider.notifier).selectConfig(chosen);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFocusAreaBox(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.level3Margin(context) + 4,
        vertical: Dimensions.level2Margin(context),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: child,
    );
  }

  // ----------------------------------------------------------
  // CONFIGURE INTERVIEW
  // ----------------------------------------------------------

  Widget _buildConfigureInterview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        Dimensions.level3Margin(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              Dimensions.level2Margin(context),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: AppColors.primaryBlue,
              size: Dimensions.level2Margin(context) + 12,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Text(
              "Configure Interview",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // INSTRUCTIONS CARD
  // ----------------------------------------------------------

  Widget _buildInstructionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        _cardPadding(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Feedback
          Align(
            alignment: Alignment.topRight,
            child: _buildFeedbackButton(context),
          ),

          Dimensions.verticalSpace(context, 20),

          // Audio Wave
          Container(
            width: double.infinity,
            height: _audioHeight(context),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(
                Icons.graphic_eq_rounded,
                size: Dimensions.level1Size(context) + 10,
                color: AppColors.primaryBlue,
              ),
            ),
          ),

          Dimensions.verticalSpace(context, 32),

          // Instruction bar
          _buildInstructionBar(context),

          Dimensions.verticalSpace(context, 32),

          // Play button
          _buildPlayButton(context),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // FEEDBACK BUTTON
  // ----------------------------------------------------------

  Widget _buildFeedbackButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.level3Margin(context),
        vertical: Dimensions.level2Margin(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.feedback_outlined,
            color: Colors.white,
            size: Dimensions.utilizationTextSize(context) + 2,
          ),
          const SizedBox(width: 6),
          Text(
            "Feedback",
            style: TextStyle(
              color: Colors.white,
              fontSize: Dimensions.utilizationTextSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // INSTRUCTION BAR
  // ----------------------------------------------------------

  Widget _buildInstructionBar(BuildContext context) {
    return GestureDetector(
      onTap: _toggleRulesAudio,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: _isRulesAudioPlaying ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isRulesAudioPlaying ? AppColors.primaryBlue : Colors.grey.shade100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _isRulesAudioPlaying ? Icons.volume_up_rounded : Icons.headphones_outlined,
              color: AppColors.primaryBlue,
              size: Dimensions.largeTextSize(context) + 3,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                _isRulesAudioPlaying
                    ? "Playing Interview Rules Audio... Tap to Stop"
                    : "Tap Play to Hear AI Interview Rules Audio",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: _isRulesAudioPlaying ? AppColors.primaryBlue : Colors.grey,
                  fontWeight: _isRulesAudioPlaying ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // PLAY BUTTON
  // ----------------------------------------------------------

  Widget _buildPlayButton(BuildContext context) {
    final double size = Dimensions.level2Size(context) - 3;

    return GestureDetector(
      onTap: _toggleRulesAudio,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(
                alpha: 0.3,
              ),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          _isRulesAudioPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: Dimensions.smallSize(context),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // RESPONSIVE SIZES
  // ----------------------------------------------------------

  double _cardPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) {
      return 16;
    }

    if (width < 600) {
      return 20;
    }

    return Dimensions.level4Margin(context) - 8;
  }

  double _globeSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) {
      return 120;
    }

    if (width < 600) {
      return 140;
    }

    return Dimensions.level6Size(context) - 20;
  }

  double _audioHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) {
      return 100;
    }

    if (width < 600) {
      return 120;
    }

    return Dimensions.level3Size(context);
  }
}