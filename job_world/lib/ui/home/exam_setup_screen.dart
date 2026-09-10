import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/exam/McqExamModel.dart';

class ExamSetupScreen extends StatelessWidget {
  final McqExamModel? exam;

  const ExamSetupScreen({super.key, this.exam});

  @override
  Widget build(BuildContext context) {
    final title = exam?.titleName ?? "Practice Examination";
    final isAttempted = exam?.isAttempted ?? false;

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
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 8),
            Text(
              "Please verify system hardware and review rules before beginning. This is a proctored, timed assessment (${exam?.totalDurationMinutes ?? 15} mins, ${exam?.noOfQuestions ?? 10} questions).",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600, height: 1.4),
            ),
            if (isAttempted && exam != null) ...[
              Dimensions.verticalSpace(context, 24),
              _buildPreviousResultCard(context, exam!),
            ],
            Dimensions.verticalSpace(context, 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "System Diagnostics",
                    style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 8),
                    Dimensions.horizontalSpace(context, 6),
                    Text("Ready", style: TextStyle(color: Colors.grey.shade500, fontSize: Dimensions.utilizationTextSize(context))),
                  ],
                ),
              ],
            ),
            Dimensions.verticalSpace(context, 20),
            _buildDiagnosticCard(
              context: context,
              icon: Icons.videocam_outlined,
              title: "System Camera",
              status: "System Ready",
              message: "Camera permissions granted for session verification.",
              isError: false,
            ),
            Dimensions.verticalSpace(context, 16),
            _buildDiagnosticCard(
              context: context,
              icon: Icons.mic_none_outlined,
              title: "System Microphone",
              status: "System Ready",
              message: "Audio stream verified and responsive.",
              isError: false,
            ),
            Dimensions.verticalSpace(context, 24),
            SizedBox(
              width: double.infinity,
              height: Dimensions.level1Size(context) + 2,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.refresh, size: Dimensions.level2Margin(context) + 12),
                label: Text("Re-verify Hardware", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Dimensions.verticalSpace(context, 32),
            _buildRulesCard(context),
            Dimensions.verticalSpace(context, 32),
            SizedBox(
              width: double.infinity,
              height: Dimensions.level1Size(context) + 6,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.examination, extra: exam),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isAttempted ? "Re-take Examination" : "Start Examination",
                  style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Dimensions.verticalSpace(context, 16),
            Center(
              child: Text(
                "By clicking, you consent to the Job World Integrity Agreement and proctoring terms.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, color: Colors.grey, height: 1.5),
              ),
            ),
            Dimensions.verticalSpace(context, 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousResultCard(BuildContext context, McqExamModel exam) {
    bool isPassed = exam.score >= exam.passPercentage;
    Color statusColor = isPassed ? Colors.green : Colors.orange;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: isPassed ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPassed ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isPassed ? Icons.workspace_premium_rounded : Icons.history_rounded,
                      color: statusColor,
                      size: Dimensions.level2Margin(context) + 14,
                    ),
                    Dimensions.horizontalSpace(context, 8),
                    Flexible(
                      child: Text(
                        "Previous Attempt Result",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.largeTextSize(context) - 1,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level2Margin(context) + 2,
                  vertical: Dimensions.level1Margin(context),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPassed ? "PASSED" : "ATTEMPTED",
                  style: TextStyle(
                    fontSize: Dimensions.superSmallTextSize(context) + 1,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Score",
                    style: TextStyle(
                      fontSize: Dimensions.utilizationTextSize(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    "${exam.score.toInt()}%",
                    style: TextStyle(
                      fontSize: Dimensions.xlargeTextSize(context) + 4,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Pass Criteria",
                    style: TextStyle(
                      fontSize: Dimensions.utilizationTextSize(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    "${exam.passPercentage}% Required",
                    style: TextStyle(
                      fontSize: Dimensions.utilizationTextSize(context) + 2,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String status,
    required String message,
    bool isError = false,
  }) {
    Color statusColor = isError ? Colors.red : Colors.green;

    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: Dimensions.level2Margin(context) + 16),
          ),
          Dimensions.horizontalSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context))),
                Dimensions.verticalSpace(context, 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.level2Margin(context) + 2,
                    vertical: Dimensions.level1Margin(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isError ? Icons.error_outline : Icons.check_circle_outline, size: Dimensions.utilizationTextSize(context), color: statusColor),
                      Dimensions.horizontalSpace(context, 6),
                      Text(status, style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
                Dimensions.verticalSpace(context, 12),
                Text(
                  message,
                  style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Dimensions.stepperMargin(context),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 16),
                    Dimensions.horizontalSpace(context, 12),
                    Expanded(
                      child: Text(
                        "Rules & Regulations",
                        style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
                Dimensions.verticalSpace(context, 24),
                _buildRuleItem(context, "Mandatory Camera/Mic", "Active proctoring feed required throughout."),
                _buildRuleItem(context, "All questions mandatory", "Unanswered items count as zero."),
                _buildRuleItem(context, "Single attempt limit", "No pausing or restarting once begun."),
                _buildRuleItem(context, "Navigation lockdown", "Tab-switching triggers immediate flags."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.level3Margin(context) + 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Dimensions.level1Margin(context) + 2),
            child: Icon(Icons.circle, size: Dimensions.level1Margin(context) + 2, color: AppColors.primaryBlue),
          ),
          Dimensions.horizontalSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2)),
                Dimensions.verticalSpace(context, 4),
                Text(subtitle, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade600, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
