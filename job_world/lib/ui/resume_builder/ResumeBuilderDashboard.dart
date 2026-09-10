import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/ui/resume_builder/TemplateViewModel.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';

class ResumeBuilderDashboard extends ConsumerStatefulWidget {
  const ResumeBuilderDashboard({super.key});

  @override
  ConsumerState<ResumeBuilderDashboard> createState() => _ResumeBuilderDashboardState();
}

class _ResumeBuilderDashboardState extends ConsumerState<ResumeBuilderDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchAllProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final templateState = ref.watch(templateViewModelProvider);
    final templateCount = templateState.templates.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: Dimensions.level2Margin(context) + 16),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          "Resume Builder",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Dimensions.verticalSpace(context, 20),
            _buildStepper(context),
            Dimensions.verticalSpace(context, 25),
            _buildHeroCard(context),
            Dimensions.verticalSpace(context, 20),
            _buildStatsRow(context, templateCount),
            Dimensions.verticalSpace(context, 20),
            _buildProfileCompletionCard(context),
            Dimensions.verticalSpace(context, 20),
            _buildAiOptimizationBanner(context),
            Dimensions.verticalSpace(context, 30),
            _buildTrendingTemplatesHeader(context),
            Dimensions.verticalSpace(context, 15),
            _buildTrendingTemplatesList(context, ref),
            Dimensions.verticalSpace(context, 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.level4Margin(context) + 8),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepCircle(context, "1", "Select", true),
              _buildStepLine(context, false),
              _buildStepCircle(context, "2", "Edit", false),
              _buildStepLine(context, false),
              _buildStepCircle(context, "3", "Download", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(BuildContext context, String step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: Dimensions.level4Margin(context) - 2,
          height: Dimensions.level4Margin(context) - 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primaryBlue : Colors.grey.shade300),
            boxShadow: isActive ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
          ),
          child: Text(
            step,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.utilizationTextSize(context),
            ),
          ),
        ),
        Dimensions.verticalSpace(context, 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryBlue : Colors.grey,
            fontSize: Dimensions.superSmallTextSize(context) + 1,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isCompleted) {
    return Expanded(
      child: Container(
        height: 1,
        margin: EdgeInsets.only(bottom: Dimensions.level3Margin(context) + 2),
        color: isCompleted ? AppColors.primaryBlue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 7),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level2Margin(context) + 2,
                  vertical: Dimensions.level1Margin(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "AI-POWERED BUILDER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.superSmallTextSize(context) + 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 15),
              Text(
                "Land Your Dream Job\nFaster",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Dimensions.xlargeTextSize(context) + 2,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              Dimensions.verticalSpace(context, 10),
              Text(
                "Create a high-impact, recruiter-ready resume in minutes with our expert templates.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: Dimensions.utilizationTextSize(context),
                ),
              ),
              Dimensions.verticalSpace(context, 25),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.templateList),
                icon: Icon(Icons.auto_fix_high, size: Dimensions.level3Margin(context)),
                label: Text(
                  "Start Building",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.utilizationTextSize(context) + 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.level4Margin(context) - 7,
                    vertical: Dimensions.level2Margin(context) + 4,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.description, size: Dimensions.level3Size(context) + 20, color: Colors.white.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int templateCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(context, "1", "Saved Resume", Icons.file_copy_outlined)),
          Dimensions.horizontalSpace(context, 15),
          Expanded(child: _buildStatCard(context, templateCount.toString(), "Available Templates", Icons.auto_awesome_outlined)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context)),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
          ),
          Dimensions.verticalSpace(context, 15),
          Text(value, style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final double completionScore = profileState.completionPercentage;
    final int displayPct = completionScore.toInt();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profile Completion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) - 1)),
                  Text("Boost your visibility", style: TextStyle(color: Colors.grey, fontSize: Dimensions.smallTextSize(context))),
                ],
              ),
              Text("$displayPct%", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3)),
            ],
          ),
          Dimensions.verticalSpace(context, 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (completionScore / 100.0).clamp(0.0, 1.0),
              minHeight: Dimensions.level1Margin(context) + 2,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          Dimensions.verticalSpace(context, 15),
          Row(
            children: [
              Icon(Icons.info_outline, size: Dimensions.largeTextSize(context) - 1, color: AppColors.primaryBlue),
              Dimensions.horizontalSpace(context, 8),
              Expanded(
                child: Text(
                  displayPct == 100
                      ? "Great job! Your profile is 100% complete."
                      : "Complete your skills and profile to boost job visibility.",
                  style: TextStyle(fontSize: Dimensions.navigationTitleSize(context), color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.profileDetails),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: Size(Dimensions.level2Size(context) + 5, Dimensions.level3Margin(context) + 19),
                ),
                child: Text(displayPct == 100 ? "View" : "Edit", style: TextStyle(color: Colors.white, fontSize: Dimensions.utilizationTextSize(context))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiOptimizationBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFEEF2FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NEW FEATURE", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Dimensions.superSmallTextSize(context) + 1)),
          Dimensions.verticalSpace(context, 10),
          Text("Tailor Your Resume with AI Optimization", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1)),
          Dimensions.verticalSpace(context, 10),
          Text(
            "Have a specific target job description? Analyze your real-time alignment score and instantly generate a structurally optimized resume.",
            style: TextStyle(color: Colors.grey, fontSize: Dimensions.utilizationTextSize(context), height: 1.4),
          ),
          Dimensions.verticalSpace(context, 20),
          Row(
            children: [
              _buildFeatureIcon(context, Icons.bar_chart, "Fitment Scoring"),
              Dimensions.horizontalSpace(context, 20),
              _buildFeatureIcon(context, Icons.auto_fix_normal, "Smart Keyword"),
            ],
          ),
          Dimensions.verticalSpace(context, 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.aiWorkspace),
              icon: Icon(Icons.arrow_forward, size: Dimensions.level3Margin(context)),
              label: Text("Open AI Workspace", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.symmetric(vertical: Dimensions.level3Margin(context) - 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: Dimensions.level3Margin(context), color: AppColors.primaryBlue),
        Dimensions.horizontalSpace(context, 8),
        Text(label, style: TextStyle(fontSize: Dimensions.navigationTitleSize(context), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTrendingTemplatesHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Trending Templates", style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => context.push(AppRoutes.templateList),
            child: Text("SEE ALL", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTemplatesList(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateViewModelProvider);

    return templateState.templates.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text("No templates found"));
        }
        return SizedBox(
          height: Dimensions.level3Size(context) + 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: Dimensions.level3Margin(context) + 4),
            itemCount: templates.length > 5 ? 5 : templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(
                context,
                template.templateName,
                "Ready to use dynamic template",
                true,
                'dynamic',
                extra: template,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("Error loading templates")),
    );
  }

  Widget _buildTemplateCard(BuildContext context, String title, String desc, bool isPro, String type, {dynamic extra}) {
    return Container(
      width: Dimensions.level6Size(context),
      margin: EdgeInsets.only(right: Dimensions.verticalSpace(context, 15).height!),
      padding: EdgeInsets.all(Dimensions.verticalSpace(context, 15).height!),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: Dimensions.level3Size(context) + 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.insert_drive_file, size: Dimensions.level1Size(context) + 10, color: Colors.grey),
              ),
              if (isPro)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.level2Margin(context),
                      vertical: Dimensions.level1Margin(context),
                    ),
                    decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
                    child: Text("FREE", style: TextStyle(color: Colors.white, fontSize: Dimensions.smallerTextSize(context) + 1, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Dimensions.verticalSpace(context, 15),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2)),
          Dimensions.verticalSpace(context, 5),
          Text(desc, style: TextStyle(color: Colors.grey, fontSize: Dimensions.superSmallTextSize(context) + 1), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(AppRoutes.resumePreview, extra: extra ?? type),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFEEF2FF)),
                backgroundColor: const Color(0xFFF9FAFB),
              ),
              child: Text("Preview", style: TextStyle(color: AppColors.primaryBlue, fontSize: Dimensions.utilizationTextSize(context), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
