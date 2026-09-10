import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

class AlgorithmChallengeScreen extends StatelessWidget {
  const AlgorithmChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: Dimensions.level2Margin(context) + 12),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          "Algorithm Challenge",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainChallengeCard(context),
            Dimensions.verticalSpace(context, 30),
            Text(
              "Session Statics",
              style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 15),
            _buildStatCard(context, Icons.local_fire_department_rounded, "Current Streak", "0", "(4/5)", Colors.orange),
            Dimensions.verticalSpace(context, 12),
            _buildStatCard(context, Icons.stars_rounded, "Gold Unlocked", "0.00", "CREDITS", Colors.yellow.shade700),
            Dimensions.verticalSpace(context, 12),
            _buildStatCard(context, Icons.verified_user_rounded, "Skill Points", "1,240", "XP", Colors.blue),
            Dimensions.verticalSpace(context, 30),
            _buildPreviousChallengesPlaceholder(context),
            Dimensions.verticalSpace(context, 30),
            _buildSystemObjective(context),
            Dimensions.verticalSpace(context, 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChallengeCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(context, "ALGORITHM", const Color(0xFFEEF2FF), AppColors.primaryBlue),
              Dimensions.horizontalSpace(context, 8),
              _buildBadge(context, "HARD", const Color(0xFFFEF2F2), Colors.red),
              const Spacer(),
              Text(
                "Attempt 1/3",
                style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 20),
          Text(
            "Minimum Spanning Tree\nusing Kruskal's Algorithm",
            style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), height: 1.3),
          ),
          Dimensions.verticalSpace(context, 16),
          Text(
            "Master the greedy strategy of Kruskal's algorithm to find the minimum spanning tree of a connected, undirected graph. Solve this to unlock elite credentials.",
            style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.grey.shade500, height: 1.5),
          ),
          Dimensions.verticalSpace(context, 24),
          Row(
            children: [
              _buildInfoRow(context, Icons.monetization_on_rounded, "REWARD POOL", "500 Gold Coins", Colors.orange),
              Dimensions.horizontalSpace(context, 20),
              _buildInfoRow(context, Icons.access_time_filled_rounded, "TIME LIMIT", "45 Minutes", Colors.blue),
            ],
          ),
          Dimensions.verticalSpace(context, 20),
          _buildInfoRow(context, Icons.calendar_month_rounded, "EXPIRES ON", "25 Aug 2026", Colors.purple, isExpanded: false),
          Dimensions.verticalSpace(context, 32),
          SizedBox(
            width: double.infinity,
            height: Dimensions.level1Size(context) + 6,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.questReady),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text("Solve Quest", style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold)),
            ),
          ),
          Dimensions.verticalSpace(context, 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded, size: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade400),
                Dimensions.horizontalSpace(context, 6),
                Text(
                  "You have used 0 challenges today",
                  style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) - 1, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.level2Margin(context) + 2,
        vertical: Dimensions.level1Margin(context) / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: Dimensions.superSmallTextSize(context), fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color iconColor, {bool isExpanded = true}) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.level2Margin(context)),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: Dimensions.level3Margin(context) + 2),
        ),
        Dimensions.horizontalSpace(context, 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) - 1, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 0.5)),
              Dimensions.verticalSpace(context, 2),
              Text(value, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
        ),
      ],
    );

    return isExpanded ? Expanded(child: content) : content;
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value, String unit, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context)),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: Dimensions.level3Margin(context) + 4),
          ),
          Dimensions.horizontalSpace(context, 16),
          Text(label, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$value ",
                  style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) - 2, fontWeight: FontWeight.bold, color: unit == "XP" ? Colors.blue : (unit == "CREDITS" ? Colors.yellow.shade800 : Colors.grey.shade400)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousChallengesPlaceholder(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.folder_open_rounded, size: Dimensions.level1Size(context) - 2, color: Colors.grey.shade200),
        Dimensions.verticalSpace(context, 16),
        Text(
          "No previous challenges found",
          style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        Dimensions.verticalSpace(context, 8),
        Text(
          "Your history log is currently clear. Complete the live quest above to populate this grid with your achievements.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade500, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSystemObjective(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_suggest_rounded, color: const Color(0xFF1E293B), size: Dimensions.level3Margin(context) + 4),
              Dimensions.horizontalSpace(context, 10),
              Text(
                "SYSTEM OBJECTIVE",
                style: TextStyle(fontSize: Dimensions.navigationTitleSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), letterSpacing: 0.5),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 16),
          Text(
            "Review input formats and sample test cases carefully before compiling code. Every failed code submission costs attempts! Precision is rewarded over speed.",
            style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.grey.shade700, height: 1.5),
          ),
          Dimensions.verticalSpace(context, 24),
          Container(
            padding: EdgeInsets.all(Dimensions.level3Margin(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: Dimensions.smallSize(context),
                      width: Dimensions.smallSize(context),
                      child: CircularProgressIndicator(
                        value: 0.92,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                    Text("92%", style: TextStyle(fontSize: Dimensions.smallerTextSize(context) + 3, fontWeight: FontWeight.bold)),
                  ],
                ),
                Dimensions.horizontalSpace(context, 16),
                Expanded(
                  child: Text(
                    "User success rate for Kruskal's algorithm tasks this week.",
                    style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) - 1, color: Colors.grey.shade600, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
