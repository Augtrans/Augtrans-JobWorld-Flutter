import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/dimensions.dart';

class ArenaContestsScreen extends StatelessWidget {
  const ArenaContestsScreen({super.key});

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
          "Feedback",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimensions.verticalSpace(context, 20),
            Text(
              "Arena Contests",
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 8),
            Text(
              "Compete against top talent, climb the ranks, and earn exclusive rewards in high-stakes recruitment battles.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600, height: 1.4),
            ),
            Dimensions.verticalSpace(context, 30),
            
            // LIVE CONTESTS Section
            _buildSectionHeader(context, "LIVE CONTESTS", Colors.green),
            Dimensions.verticalSpace(context, 15),
            _buildEmptyStateCard(
              context: context,
              icon: Icons.local_fire_department_rounded,
              iconColor: Colors.green,
              title: "The Arena is Quiet",
              subtitle: "No active contests running right now. Keep your skills sharp and get ready for the upcoming battles.",
              buttonText: "ENTER PRACTICE MODE",
              onButtonPressed: () => context.push(AppRoutes.practice),
            ),
            
            Dimensions.verticalSpace(context, 30),
            
            // UPCOMING BATTLES Section
            _buildSectionHeader(context, "UPCOMING BATTLES", Colors.brown),
            Dimensions.verticalSpace(context, 15),
            _buildEmptyStateCard(
              context: context,
              icon: Icons.mail_outline_rounded,
              iconColor: Colors.orange,
              title: "TRANSMISSION EMPTY",
              subtitle: "No upcoming battles scheduled on the radar. Check back later as new challenges emerge.",
              isUpcoming: true,
            ),

            Dimensions.verticalSpace(context, 30),

            // TOP RANKERS Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOP RANKERS",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1), letterSpacing: 1),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("View All", style: TextStyle(color: const Color(0xFF6366F1), fontSize: Dimensions.utilizationTextSize(context), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Text(
              "See who's currently dominating the arena.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey),
            ),
            Dimensions.verticalSpace(context, 20),
            _buildRankersList(context),
            Dimensions.verticalSpace(context, 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: Dimensions.level2Margin(context)),
        Dimensions.horizontalSpace(context, 8),
        Text(
          title,
          style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), fontWeight: FontWeight.bold, color: color, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool isUpcoming = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level3Margin(context)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: Dimensions.level4Margin(context) - 2),
          ),
          Dimensions.verticalSpace(context, 24),
          Text(
            title,
            style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) - 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          Dimensions.verticalSpace(context, 12),
          Text(
            subtitle,
            style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.grey.shade600, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null) ...[
            Dimensions.verticalSpace(context, 30),
            SizedBox(
              width: double.infinity,
              height: Dimensions.level1Size(context),
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankersList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildRankerItem(context, 1, "Ravi Dube", "FULL STACK", "2,450", Colors.orange),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildRankerItem(context, 2, "Shri Rahi", "FRONTEND", "2,120", Colors.grey.shade400),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildRankerItem(context, 3, "Nutan Rane", "BACKEND", "1,980", Colors.brown.shade400),
        ],
      ),
    );
  }

  Widget _buildRankerItem(BuildContext context, int rank, String name, String role, String score, Color rankColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4, vertical: Dimensions.level3Margin(context)),
      child: Row(
        children: [
          Container(
            width: Dimensions.smallSize(context),
            height: Dimensions.smallSize(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              rank.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Dimensions.horizontalSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Text(
                  role,
                  style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }
}