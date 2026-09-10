import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/data/model/resume/JdFitmentModel.dart';
import 'package:job_world/data/model/profile/CvModel.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';

class JdFitmentResultScreen extends ConsumerStatefulWidget {
  final JdFitmentModel fitment;

  const JdFitmentResultScreen({super.key, required this.fitment});

  @override
  ConsumerState<JdFitmentResultScreen> createState() => _JdFitmentResultScreenState();
}

class _JdFitmentResultScreenState extends ConsumerState<JdFitmentResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchProfile();
      ref.read(profileViewModelProvider.notifier).fetchCvs();
    });
  }

  Future<void> _openUploadedResumePdf(BuildContext context, CvModel? activeCv) async {
    final pdfUrl = activeCv?.pdfFile;
    if (pdfUrl != null && pdfUrl.trim().isNotEmpty) {
      try {
        final uri = Uri.parse(pdfUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint("Error launching CV PDF URL: $e");
      }
    }
    CommonMethods.showSnackBar(
      context,
      "No uploaded resume PDF file found in your profile.",
      backgroundColor: Colors.orange.shade700,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: Dimensions.level2Margin(context) + 16),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "JD Match Score Results",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
        child: Column(
          children: [
            _buildScoreGaugeCard(context),
            Dimensions.verticalSpace(context, 20),
            _buildCandidateResumeCard(context, profileState),
            Dimensions.verticalSpace(context, 20),
            if (widget.fitment.strengths.isNotEmpty) ...[
              _buildStrengthsCard(context),
              Dimensions.verticalSpace(context, 20),
            ],
            if (widget.fitment.weaknesses.isNotEmpty) ...[
              _buildWeaknessesCard(context),
              Dimensions.verticalSpace(context, 20),
            ],
            _buildScoreBreakdownCard(context),
            Dimensions.verticalSpace(context, 20),
            _buildSkillsCard(context),
            if (widget.fitment.jdExtraction != null) ...[
              Dimensions.verticalSpace(context, 20),
              _buildJdExtractionCard(context),
            ],
            if (widget.fitment.matchingKeywords.isNotEmpty) ...[
              Dimensions.verticalSpace(context, 20),
              _buildKeywordsCard(context),
            ],
            Dimensions.verticalSpace(context, 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SCORE GAUGE CARD
  // ---------------------------------------------------------------------------
  Widget _buildScoreGaugeCard(BuildContext context) {
    final score = widget.fitment.fitmentScore;
    Color statusColor = Colors.green;
    String statusLabel = "High Match";

    if (score < 40) {
      statusColor = Colors.red;
      statusLabel = "Low Match";
    } else if (score < 70) {
      statusColor = Colors.orange;
      statusLabel = "Moderate Match";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Overall Fitment Match",
            style: TextStyle(
              fontSize: Dimensions.utilizationTextSize(context) + 2,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          Dimensions.verticalSpace(context, 20),
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: FitmentGaugePainter(percentage: (score / 100).clamp(0.0, 1.0), color: statusColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${score.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: Dimensions.xlargeTextSize(context) + 6,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: Dimensions.superSmallTextSize(context) + 1,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Dimensions.verticalSpace(context, 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.level2Margin(context) + 4,
                    vertical: Dimensions.level1Margin(context),
                  ),
                  decoration: BoxDecoration(
                    color: widget.fitment.meetsHardRequirements
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.fitment.meetsHardRequirements ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: Dimensions.utilizationTextSize(context) + 2,
                        color: widget.fitment.meetsHardRequirements ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                      Dimensions.horizontalSpace(context, 6),
                      Flexible(
                        child: Text(
                          widget.fitment.meetsHardRequirements
                              ? "Meets Hard Requirements"
                              : "Does Not Meet Hard Reqs",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Dimensions.superSmallTextSize(context) + 1,
                            fontWeight: FontWeight.bold,
                            color: widget.fitment.meetsHardRequirements ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CANDIDATE RESUME CARD
  // ---------------------------------------------------------------------------
  Widget _buildCandidateResumeCard(BuildContext context, ProfileState profileState) {
    final profile = profileState.profile.valueOrNull;
    final cvs = profileState.cvs.valueOrNull ?? [];
    final activeCv = cvs.where((c) => c.isActive).firstOrNull ?? cvs.firstOrNull;

    final String name = (profile != null && profile.firstName.isNotEmpty)
        ? "${profile.firstName} ${profile.lastName}".trim()
        : "Candidate Resume";
    final String candidateType = profile?.candidateType ?? "Professional";
    final String phone = profile?.phoneNumber ?? "N/A";
    final String location = (profile?.city.isNotEmpty == true && profile?.state.isNotEmpty == true)
        ? "${profile!.city}, ${profile.state}"
        : (profile?.city ?? "Not specified");

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Evaluated Candidate Resume",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.largeTextSize(context) - 1,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeCv != null ? "Uploaded CV (v${activeCv.version})" : "Profile Data Resume",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activeCv?.sourceType.isNotEmpty == true ? activeCv!.sourceType : "UPLOADED",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 14),
          // Profile Details Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDetailRow("Name", name),
                const SizedBox(height: 6),
                _buildDetailRow("Designation", candidateType),
                const SizedBox(height: 6),
                _buildDetailRow("Contact", phone),
                const SizedBox(height: 6),
                _buildDetailRow("Location", location),
              ],
            ),
          ),
          Dimensions.verticalSpace(context, 14),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openUploadedResumePdf(context, activeCv),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text(
                "View Uploaded Resume PDF",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. STRENGTHS CARD
  // ---------------------------------------------------------------------------
  Widget _buildStrengthsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_rounded, color: Color(0xFF16A34A), size: 20),
              Dimensions.horizontalSpace(context, 8),
              Text(
                "Profile Strengths",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.largeTextSize(context),
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 12),
          ...widget.fitment.strengths.map((str) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 16, color: Color(0xFF16A34A)),
                    Dimensions.horizontalSpace(context, 8),
                    Expanded(
                      child: Text(
                        str,
                        style: TextStyle(
                          fontSize: Dimensions.utilizationTextSize(context) + 1,
                          color: const Color(0xFF166534),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. WEAKNESSES CARD
  // ---------------------------------------------------------------------------
  Widget _buildWeaknessesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C), size: 20),
              Dimensions.horizontalSpace(context, 8),
              Text(
                "Areas to Improve & Gaps",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.largeTextSize(context),
                  color: const Color(0xFFC2410C),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 12),
          ...widget.fitment.weaknesses.map((weak) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.close, size: 16, color: Color(0xFFEA580C)),
                    Dimensions.horizontalSpace(context, 8),
                    Expanded(
                      child: Text(
                        weak,
                        style: TextStyle(
                          fontSize: Dimensions.utilizationTextSize(context) + 1,
                          color: const Color(0xFF9A3412),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SCORE BREAKDOWN CARD
  // ---------------------------------------------------------------------------
  Widget _buildScoreBreakdownCard(BuildContext context) {
    final bd = widget.fitment.scoreBreakdown;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            "Score Breakdown",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.largeTextSize(context) + 1,
              color: const Color(0xFF0F172A),
            ),
          ),
          Dimensions.verticalSpace(context, 16),
          _buildBreakdownRow(context, "Skill Score", bd.skillScore, 30.0),
          Dimensions.verticalSpace(context, 12),
          _buildBreakdownRow(context, "Experience Score", bd.experienceScore, 25.0),
          Dimensions.verticalSpace(context, 12),
          _buildBreakdownRow(context, "JD Match Score", bd.jdMatchScore, 20.0),
          Dimensions.verticalSpace(context, 12),
          _buildBreakdownRow(context, "Education Score", bd.educationScore, 10.0),
          Dimensions.verticalSpace(context, 12),
          _buildBreakdownRow(context, "Location Score", bd.locationScore, 5.0),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, String label, double value, double maxVal) {
    final double pct = maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
            Text("${value.toStringAsFixed(1)} pt", style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ],
        ),
        Dimensions.verticalSpace(context, 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. SKILLS COMPARISON CARD
  // ---------------------------------------------------------------------------
  Widget _buildSkillsCard(BuildContext context) {
    final matched = widget.fitment.skills.matched;
    final missing = widget.fitment.skills.missing;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            "Skills Analysis",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.largeTextSize(context) + 1,
              color: const Color(0xFF0F172A),
            ),
          ),
          Dimensions.verticalSpace(context, 16),
          Text("Matched Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.green.shade700)),
          Dimensions.verticalSpace(context, 8),
          if (matched.isEmpty)
            Text("No matched skills found", style: TextStyle(color: Colors.grey.shade400, fontSize: Dimensions.utilizationTextSize(context)))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matched.map((sk) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Text(
                    "${sk.name} (${sk.proficiency})",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534), fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          Dimensions.verticalSpace(context, 20),
          Text("Missing Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1, color: Colors.red.shade700)),
          Dimensions.verticalSpace(context, 8),
          if (missing.isEmpty)
            Text("No missing skills!", style: TextStyle(color: Colors.green.shade600, fontSize: Dimensions.utilizationTextSize(context)))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: missing.map((sk) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    sk,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 12),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. JD EXTRACTION CARD
  // ---------------------------------------------------------------------------
  Widget _buildJdExtractionCard(BuildContext context) {
    final ext = widget.fitment.jdExtraction!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            "Target JD Requirements Extracted",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.largeTextSize(context) + 1,
              color: const Color(0xFF0F172A),
            ),
          ),
          Dimensions.verticalSpace(context, 16),
          _buildInfoRow("Required Experience", "${ext.minYoe} Years Minimum"),
          Dimensions.verticalSpace(context, 10),
          _buildInfoRow("Target Location", ext.location ?? "Not Specified"),
          Dimensions.verticalSpace(context, 10),
          _buildInfoRow("Allow Relocation", ext.allowRelocation ? "Yes" : "No"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. KEYWORDS CARD
  // ---------------------------------------------------------------------------
  Widget _buildKeywordsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            "Matching Keywords (${widget.fitment.matchingWordCount})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.largeTextSize(context) + 1,
              color: const Color(0xFF0F172A),
            ),
          ),
          Dimensions.verticalSpace(context, 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.fitment.matchingKeywords.map((kw) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  kw,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GAUGE PAINTER
// ---------------------------------------------------------------------------
class FitmentGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  FitmentGaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
