import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchAllProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Dimensions.level3Margin(context),
            Dimensions.level3Margin(context),
            Dimensions.level3Margin(context),
            Dimensions.level3Size(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Dimensions.verticalSpace(context, 25),
              _buildProfileCompletionCard(context),
              Dimensions.verticalSpace(context, 30),
              _buildArcadeZone(context),
              Dimensions.verticalSpace(context, 25),
              _buildAIResumeCard(context),
              Dimensions.verticalSpace(context, 30),
              _buildShortlistedJobs(context),
              Dimensions.verticalSpace(context, 25),
              _buildChallengePackCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: Dimensions.level2Padding(context) * 3,
          child: Icon(Icons.person, size: Dimensions.level4Margin(context)),
        ),
        Dimensions.horizontalSpace(context, 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WELCOME, BACK!",
              style: TextStyle(
                fontSize: Dimensions.superSmallTextSize(context),
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              "Abc User",
              style: TextStyle(
                fontSize: Dimensions.largeTextSize(context) + 3,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.push(AppRoutes.credit),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.level2Margin(context) + 4,
              vertical: Dimensions.level2Margin(context),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.orange, size: Dimensions.level2Margin(context) + 12),
                Dimensions.horizontalSpace(context, 5),
                Text(
                  "2,675",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.largeTextSize(context) - 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Dimensions.horizontalSpace(context, 12),
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Icon(Icons.notifications_none_rounded, size: Dimensions.level2Margin(context) + 16),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final double completionScore = profileState.completionPercentage;
    final int displayPct = completionScore.toInt();

    return Container(
      padding: EdgeInsets.all(Dimensions.level4Margin(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Completion",
                    style: TextStyle(fontSize: Dimensions.mediumTextSize(context), fontWeight: FontWeight.bold),
                  ),
                  Dimensions.verticalSpace(context, 4),
                  Text(
                    "Boost your visibility",
                    style: TextStyle(fontSize: Dimensions.smallTextSize(context), color: Colors.grey.shade500),
                  ),
                ],
              ),
              Text(
                "$displayPct%",
                style: TextStyle(
                  fontSize: Dimensions.xlargeTextSize(context) + 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (completionScore / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          Dimensions.verticalSpace(context, 15),
          Row(
            children: [
              Icon(Icons.info_outline, size: Dimensions.level3Margin(context), color: AppColors.primaryBlue),
              Dimensions.horizontalSpace(context, 8),
              Expanded(
                child: Text(
                  displayPct == 100
                      ? "Great job! Your profile is 100% complete."
                      : "Complete your skills and profile to boost job visibility.",
                  style: TextStyle(fontSize: Dimensions.superSmallTextSize(context), color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.profileDetails),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context), vertical: 0),
                  minimumSize: const Size(0, 35),
                ),
                child: Text(displayPct == 100 ? "View" : "Edit", style: TextStyle(color: Colors.white, fontSize: Dimensions.smallTextSize(context))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArcadeZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Arcade Zone",
                  style: TextStyle(
                    fontSize: Dimensions.largeTextSize(context) + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Dimensions.verticalSpace(context, 4),
                Text(
                  "Play games, win real coins",
                  style: TextStyle(
                    fontSize: Dimensions.smallTextSize(context),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FDF0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "LIVE NOW",
                style: TextStyle(
                  color: const Color(0xFF34C759),
                  fontSize: Dimensions.superSmallTextSize(context) - 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Dimensions.verticalSpace(context, 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildJobHuntRunnerCard(context),
              const SizedBox(width: 14),
              _buildDailyTriviaQuizCard(context),
              const SizedBox(width: 14),
              _buildCrackInterviewCard(context),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ARCADE CARD 1: JOB HUNT RUNNER
  // ---------------------------------------------------------------------------
  Widget _buildJobHuntRunnerCard(BuildContext context) {
    final cardWidth = (Dimensions.screenWidth(context) * 0.82).clamp(300.0, 360.0);

    return Container(
      width: cardWidth,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Right Graphic: Tilted rounded card with dotted question mark
          Positioned(
            right: -10,
            top: 5,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 90,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Left Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Job Hunt Runner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "ManRope",
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dodge rejections, collect offers!",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.arenaContests),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4F46E5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text(
                      "Play Now",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGoldCoinIcon(),
                      const SizedBox(width: 6),
                      const Text(
                        "Win up to 500",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ARCADE CARD 2: DAILY TRIVIA QUIZ
  // ---------------------------------------------------------------------------
  Widget _buildDailyTriviaQuizCard(BuildContext context) {
    final cardWidth = (Dimensions.screenWidth(context) * 0.82).clamp(300.0, 360.0);

    return Container(
      width: cardWidth,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Right Graphic: Dark circle with brain icon
          Positioned(
            right: 0,
            top: 10,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF334155), width: 1.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF818CF8),
                  size: 42,
                ),
              ),
            ),
          ),
          // Left Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Trivia Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "ManRope",
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "10 Questions • 60 Seconds",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.mcqChallenges),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text(
                      "Start Quiz",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGoldCoinIcon(),
                      const SizedBox(width: 6),
                      const Text(
                        "Earn 100/day",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ARCADE CARD 3: CRACK YOUR NEXT TECH INTERVIEW
  // ---------------------------------------------------------------------------
  Widget _buildCrackInterviewCard(BuildContext context) {
    final cardWidth = (Dimensions.screenWidth(context) * 0.82).clamp(300.0, 360.0);

    return Container(
      width: cardWidth,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCBA28),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFCBA28).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Right Watermark Graphic: Graduation Mortarboard Hat
          Positioned(
            right: -25,
            bottom: -35,
            child: Opacity(
              opacity: 0.12,
              child: const Icon(
                Icons.school_rounded,
                size: 170,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          // Left Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Crack Your Next Tech Interview",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: "ManRope",
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "3,000+ real interview questions\nfrom top companies.",
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.practice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text(
                  "Practice Now",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GOLD COIN ICON HELPER
  // ---------------------------------------------------------------------------
  Widget _buildGoldCoinIcon() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Color(0xFFF59E0B),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.monetization_on_rounded,
        color: Color(0xFFFEF08A),
        size: 16,
      ),
    );
  }

  Widget _buildAIResumeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.resumeBuilder),
      child: Container(
        padding: EdgeInsets.all(Dimensions.level3Margin(context)),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.level2Margin(context)),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: Dimensions.level4Margin(context)),
            ),
            Dimensions.horizontalSpace(context, 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Create Resume with AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.smallTextSize(context) + 2)),
                  Dimensions.verticalSpace(context, 2),
                  Text("Generate a professional ATS-friendly resume in minutes", style: TextStyle(color: Colors.grey.shade600, fontSize: Dimensions.superSmallTextSize(context))),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(Dimensions.level2Margin(context)),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.arrow_forward_rounded, size: Dimensions.level4Margin(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortlistedJobs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Shortlisted Jobs", style: TextStyle(fontSize: Dimensions.largeTextSize(context), fontWeight: FontWeight.bold)),
        Dimensions.verticalSpace(context, 15),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.level4Margin(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.level4Margin(context), vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Complete Practices & Get Shortlisted",
                  style: TextStyle(
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.superSmallTextSize(context) + 1,
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 30),
              // Illustration placeholder
              Image.asset(
                'assets/png/shortlist_illustration.png',
                height: Dimensions.screenHeight(context) * 0.18,
              ),
              Dimensions.verticalSpace(context, 30),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.practice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.level4Margin(context), vertical: 10),
                ),
                child: Text(
                  "Explore Practices",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.smallTextSize(context) + 3,
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengePackCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: Dimensions.level3Margin(context) + 2),
                  Dimensions.horizontalSpace(context, 6),
                  Text(
                    "Challenge Pack",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.largeTextSize(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level2Margin(context),
                  vertical: Dimensions.level1Margin(context) - 1,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "2/5",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.superSmallTextSize(context) + 1,
                  ),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 8),
          Text(
            "Complete 5 tasks to earn 200 coins",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: Dimensions.utilizationTextSize(context),
            ),
          ),
          Dimensions.verticalSpace(context, 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.4,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Dimensions.verticalSpace(context, 14),
          Center(
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.challengePacks),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFF97316),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level3Margin(context) + 4,
                  vertical: Dimensions.level2Margin(context) - 2,
                ),
                minimumSize: const Size(0, 36),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Explore",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.utilizationTextSize(context) + 1,
                    ),
                  ),
                  Dimensions.horizontalSpace(context, 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: Dimensions.utilizationTextSize(context) + 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}