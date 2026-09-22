import 'package:flutter/material.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

class _TimelineStep {
  final String title;
  final String actor;
  final String role;
  final String time;
  final List<String> tags;
  final String? comment;
  final bool isFinal;

  const _TimelineStep({
    required this.title,
    required this.actor,
    required this.role,
    required this.time,
    this.tags = const [],
    this.comment,
    this.isFinal = false,
  });
}

/// "Timeline" — the candidate's approval workflow / email log history.
/// Reached from "View Details" and "View Email Logs & Timeline".
class TlTimelineScreen extends StatelessWidget {
  final TlCandidateModel? candidate;

  const TlTimelineScreen({super.key, this.candidate});

  static const List<_TimelineStep> _steps = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const TlHeaderBar(title: "Timeline"),
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
              if (_steps.isEmpty)
                const TlNoDataFound()
              else ...[
                for (int i = 0; i < _steps.length; i++) _buildStep(context, i),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int index) {
    final step = _steps[index];
    final isLast = index == _steps.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.isFinal ? const Color(0xFF16A34A) : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ),
              if (!isLast) const Expanded(child: VerticalDivider(width: 1, thickness: 2, color: Color(0xFFE0E7FF))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: step.isFinal ? Border.all(color: const Color(0xFF86EFAC)) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFEEF2FF),
                          child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: step.actor, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                    const TextSpan(text: " · ", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    TextSpan(
                                      text: step.role,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: step.isFinal ? const Color(0xFF16A34A) : AppColors.primaryBlue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(step.time, style: TextStyle(fontSize: 11, color: step.isFinal ? const Color(0xFF16A34A) : Colors.grey.shade500)),
                      ],
                    ),
                    if (step.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in step.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: tag == "PRIORITY: HIGH" ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(tag,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: tag == "PRIORITY: HIGH" ? AppColors.primaryBlue : Colors.grey.shade600)),
                            ),
                        ],
                      ),
                    ],
                    if (step.comment != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"${step.comment}"',
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primaryBlue, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
