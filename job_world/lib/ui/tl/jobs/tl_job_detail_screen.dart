import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// Job detail screen reached from Job Listings "View".
/// Entry point into both "Applied Candidates" and "Walk-in CV Pool".
class TlJobDetailScreen extends StatelessWidget {
  final TlJobModel job;

  const TlJobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.level3Margin(context) + 2,
            vertical: Dimensions.level3Margin(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("WELCOME, BACK!",
                          style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const Text("Akshay Khandekar", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF334155), size: 20),
                      ),
                      Positioned(
                        right: 9,
                        top: 9,
                        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                      ),
                    ],
                  ),
                ],
              ),
              Dimensions.verticalSpace(context, 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  ),
                  TlStatusChip.forTag(job.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.work_outline_rounded, size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(job.experience, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 14),
                  Icon(Icons.people_outline_rounded, size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text("${job.openings} Openings", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 14),
                  Icon(Icons.location_on_outlined, size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(job.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              Dimensions.verticalSpace(context, 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showTlSnack(context, "Job link copied to clipboard"),
                      icon: const Icon(Icons.ios_share_rounded, size: 16),
                      label: const Text("Copy Link", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        backgroundColor: const Color(0xFFEEF2FF),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showTlSnack(context, "Ranking CVs for ${job.title}...");
                        context.push(AppRoutes.tlAppliedCandidates, extra: job);
                      },
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: const Text("Rank CV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              Dimensions.verticalSpace(context, 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _labelledCard("EMPLOYMENT TYPE", job.employmentType)),
                  const SizedBox(width: 12),
                  Expanded(child: _labelledCard("BUDGET", job.salary)),
                ],
              ),
              const SizedBox(height: 12),
              _labelledCard("COMPANY", job.company),
              const SizedBox(height: 12),
              _labelledCard("LOCATION", job.locations.join(", ")),
              Dimensions.verticalSpace(context, 22),
              const Text("Job Description", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text(job.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
              Dimensions.verticalSpace(context, 22),
              const Text("Required Skills", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final skill in job.skills)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                    ),
                ],
              ),
              Dimensions.verticalSpace(context, 22),
              _navCard(
                context,
                title: "Applied Candidates",
                subtitleWidget: Text("${job.appliedCount} New Applicants",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                trailing: _avatarStack(job.appliedCount),
                badgeCount: null,
                onTap: () => context.push(AppRoutes.tlAppliedCandidates, extra: job),
              ),
              const SizedBox(height: 14),
              _navCard(
                context,
                title: "Walk-in CV Pool",
                subtitleWidget: Text("${job.walkInCount}+ Candidates available in the talent pool.",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                trailing: null,
                badgeCount: 1,
                onTap: () => context.push(AppRoutes.tlWalkinCvPool, extra: job),
              ),
              Dimensions.verticalSpace(context, 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelledCard(String label, String value) {
    return TlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _avatarStack(int total) {
    final shown = total < 3 ? total : 3;
    return SizedBox(
      width: 30.0 * shown + 40,
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < shown; i++)
            Positioned(
              left: i * 20.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Icon(Icons.person_rounded, size: 16, color: AppColors.primaryBlue.withValues(alpha: 0.7)),
                ),
              ),
            ),
          if (total > shown)
            Positioned(
              left: shown * 20.0 + 4,
              top: 4,
              child: Text("+${total - shown} more", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _navCard(
    BuildContext context, {
    required String title,
    required Widget subtitleWidget,
    Widget? trailing,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TlCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      if (badgeCount != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(20)),
                          child: Text("$badgeCount", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            subtitleWidget,
            if (trailing != null) ...[const SizedBox(height: 10), trailing],
          ],
        ),
      ),
    );
  }
}
