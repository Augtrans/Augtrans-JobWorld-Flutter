import 'package:flutter/material.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// "View hiring report" — reached from the Walk-in CV Pool candidate menu.
class TlHiringReportScreen extends StatelessWidget {
  final TlCandidateModel? candidate;

  const TlHiringReportScreen({super.key, this.candidate});

  @override
  Widget build(BuildContext context) {
    final name = candidate?.name ?? "Candidate";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const TlHeaderBar(title: "Hiring Report"),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.level3Margin(context) + 2,
            vertical: Dimensions.level3Margin(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TlCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: candidate?.avatarColor ?? AppColors.primaryBlue,
                      child: Text(candidate?.initial ?? "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          if (candidate?.score != null)
                            Text("Overall match score: ${candidate!.score!.toStringAsFixed(2)}%",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Dimensions.verticalSpace(context, 16),
              _reportRow(context, "Resume Screening", "Cleared", const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
              const SizedBox(height: 12),
              _reportRow(context, "Technical Round", "Cleared", const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
              const SizedBox(height: 12),
              _reportRow(context, "HR Round", "Awaiting Feedback", const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              Dimensions.verticalSpace(context, 20),
              const Text("Interviewer Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 10),
              TlCard(
                child: Text(
                  "Strong fundamentals and clear communication. Recommended for the next round with the reporting manager.",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportRow(BuildContext context, String title, String status, Color color, Color bg) {
    return TlCard(
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
          TlStatusChip(label: status, background: bg, foreground: color),
        ],
      ),
    );
  }
}
