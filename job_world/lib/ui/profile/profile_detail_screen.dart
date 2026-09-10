import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_world/data/model/profile/CertificationModel.dart';
import 'package:job_world/data/model/profile/EducationModel.dart';
import 'package:job_world/data/model/profile/EducationMasterModel.dart';
import 'package:job_world/data/model/profile/EmploymentModel.dart';
import 'package:job_world/data/model/profile/JobPreferenceModel.dart';
import 'package:job_world/data/model/profile/ProjectModel.dart';
import 'package:job_world/data/model/profile/SkillModel.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import '../../routes/AppRoute.dart';
import 'ProfileViewModel.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _educationKey = GlobalKey();
  final GlobalKey _jobPreferencesKey = GlobalKey();

  bool _isSkillsExpanded = false;
  PlatformFile? _pendingResumeFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchAllProfileData();
    });
  }

  Future<void> _scrollToSection(int index) async {
    if (_scrollController.hasClients && _scrollController.offset < _scrollController.position.maxScrollExtent) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    GlobalKey targetKey;
    switch (index) {
      case 0: targetKey = _summaryKey; break;
      case 1: targetKey = _experienceKey; break;
      case 2: targetKey = _skillsKey; break;
      case 3: targetKey = _educationKey; break;
      case 4: targetKey = _jobPreferencesKey; break;
      default: return;
    }

    if (targetKey.currentContext != null && mounted) {
      await Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    ref.listen(profileViewModelProvider.select((s) => s.uploadStatus), (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is AsyncLoading) {
            if (_pendingResumeFile != null) setState(() => _pendingResumeFile = null);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resume uploaded successfully!")));
            });
          }
        },
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $error")));
          });
        },
      );
    });

    ref.listen(profileViewModelProvider.select((s) => s.updateStatus), (p, n) => _handleActionStatus(p, n, "Profile"));
    ref.listen(profileViewModelProvider.select((s) => s.employmentActionStatus), (p, n) => _handleActionStatus(p, n, "Work Experience"));
    ref.listen(profileViewModelProvider.select((s) => s.educationActionStatus), (p, n) => _handleActionStatus(p, n, "Education"));
    ref.listen(profileViewModelProvider.select((s) => s.skillActionStatus), (p, n) => _handleActionStatus(p, n, "Skill"));
    ref.listen(profileViewModelProvider.select((s) => s.projectActionStatus), (p, n) => _handleActionStatus(p, n, "Project"));
    ref.listen(profileViewModelProvider.select((s) => s.certificationActionStatus), (p, n) => _handleActionStatus(p, n, "Certification"));
    ref.listen(profileViewModelProvider.select((s) => s.jobPreferenceActionStatus), (p, n) => _handleActionStatus(p, n, "Job Preference"));

    ref.listen(profileViewModelProvider.select((s) => s.profile), (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not load profile details. Showing offline/empty view.")));
          });
        },
      );
    });

    final profile = profileState.profile.valueOrNull;
    final isInitialLoading = profileState.profile.isLoading && profile == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildHeader(profile?.firstName, profile?.lastName, profile?.candidateType, profile?.city, profile?.state, profile?.profilePicture),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
                          child: Column(
                            children: [
                              Dimensions.verticalSpace(context, 10),
                              _buildStatsSection(profile?.yearsOfExperience, profile?.currentCtc, profile?.noticePeriod),
                              Dimensions.verticalSpace(context, 10),
                              _buildProfileStrength(profileState),
                              Dimensions.verticalSpace(context, 10),
                              _buildMainResumeSection(profileState),
                              Dimensions.verticalSpace(context, 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        onTap: _scrollToSection,
                        isScrollable: true,
                        indicatorColor: AppColors.primaryBlue,
                        indicatorWeight: 3,
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "ManRope"),
                        tabs: const [
                          Tab(text: "Profile summary"),
                          Tab(text: "Work experience"),
                          Tab(text: "Skills"),
                          Tab(text: "Education"),
                          Tab(text: "Job Preferences"),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
                child: Column(
                  children: [
                    Dimensions.verticalSpace(context, 10),
                    _buildProfileCompletionBanner(context, profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildSummarySection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildResumeSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildExperienceSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildSkillsSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildProjectsSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildCertificationsSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildEducationSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildJobPreferencesSection(profileState),
                    Dimensions.verticalSpace(context, 10),
                    _buildSocialLinks(profile?.phoneNumber, profile?.linkedinUrl, profile?.githubUrl),
                    Dimensions.verticalSpace(context, 100),
                  ],
                ),
              ),
            ),
    );
  }

  void _handleActionStatus(AsyncValue<void>? previous, AsyncValue<void> next, String section) {
    next.whenOrNull(
      data: (_) {
        if (previous is AsyncLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$section updated successfully!")));
          });
        }
      },
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating $section: $error")));
        });
      },
    );
  }

  Widget _buildHeader(String? firstName, String? lastName, String? jobTitle, String? city, String? state, String? imageUrl) {
    String name = (firstName != null || lastName != null) ? "${firstName ?? ""} ${lastName ?? ""}".trim() : "Your Name";
    String location = (city != null || state != null) ? "${city ?? ""}, ${state ?? ""}".trim() : "Location";
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0E7FF), Colors.white])),
      child: Stack(
        children: [
          Positioned(top: 40, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF444655)), onPressed: () => context.pop())),
          Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                      : Container(width: 100, height: 100, color: Colors.grey.shade200, child: const Icon(Icons.person, size: 50, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 15),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "ManRope")),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_center_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(jobTitle ?? "Job Title", style: TextStyle(color: Colors.grey.shade600, fontFamily: "ManRope")),
                  const SizedBox(width: 15),
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(location, style: TextStyle(color: Colors.grey.shade600, fontFamily: "ManRope")),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.editProfile),
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                label: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionBanner(BuildContext context, ProfileState profileState) {
    final double score = profileState.completionPercentage;
    final int pct = score.toInt();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                    "Profile Score",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context), color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pct == 100 ? "Your profile is 100% complete!" : "Complete remaining sections to reach 100%",
                    style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Text(
                "$pct%",
                style: TextStyle(
                  fontSize: Dimensions.xlargeTextSize(context) + 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (score / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double? exp, double? salary, String? notice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("EXP", exp != null ? "${exp.toInt()}+ yrs" : "N/A"),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              _buildStatItem("SALARY", salary != null && salary > 0 ? "₹${salary.toInt()} LPA" : "Not Disclosed"),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              _buildStatItem("NOTICE", notice ?? "N/A"),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.refresh, size: 14, color: Colors.grey.shade400), const SizedBox(width: 4), Text("Updated Recently", style: TextStyle(fontSize: 12, color: Colors.grey.shade400))]),
              const Text("Update now", style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]);
  }

  Widget _buildProfileStrength(ProfileState state) {
    int strength = 0;
    state.profile.whenData((p) {
      if (p != null) {
        if (p.profilePicture != null) strength += 10;
        if (p.firstName.isNotEmpty && p.lastName.isNotEmpty) strength += 10;
        if (p.phoneNumber.isNotEmpty) strength += 5;
        if (p.city.isNotEmpty) strength += 5;
      }
    });
    state.cvs.whenData((cvs) => strength += cvs.isNotEmpty ? 20 : 0);
    state.employments.whenData((e) => strength += e.isNotEmpty ? 10 : 0);
    state.skills.whenData((s) => strength += s.isNotEmpty ? 10 : 0);
    state.educations.whenData((ed) => strength += ed.isNotEmpty ? 10 : 0);
    state.projects.whenData((pr) => strength += pr.isNotEmpty ? 5 : 0);
    state.certifications.whenData((c) => strength += c.isNotEmpty ? 5 : 0);
    state.jobPreferences.whenData((p) => strength += p.isNotEmpty ? 5 : 0);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: strength / 100, strokeWidth: 4, backgroundColor: Colors.grey.shade100, color: AppColors.primaryBlue)),
              Text("$strength%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(width: 15),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Profile Strength", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 2), Text("Complete your profile to get 2x more interviews.", style: TextStyle(color: Colors.grey, fontSize: 11))])),
        ],
      ),
    );
  }

  Widget _buildMainResumeSection(ProfileState state) {
    final isUploading = state.uploadStatus is AsyncLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 20)), const SizedBox(width: 12), const Text("Resume", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)), child: const Text("REQUIRED", style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 20),
          if (_pendingResumeFile == null)
            InkWell(
              onTap: _pickResumeFile,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(15)),
                child: const Center(child: Column(children: [Icon(Icons.cloud_upload, color: AppColors.primaryBlue, size: 24), SizedBox(height: 10), Text("Upload Resume", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text("pdf, doc, docx", style: TextStyle(fontSize: 11, color: Colors.grey))])),
              ),
            )
          else
            _buildPendingResumeCard(isUploading),
        ],
      ),
    );
  }

  Widget _buildPendingResumeCard(bool isUploading) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _pendingResumeFile!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              if (!isUploading)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => setState(() => _pendingResumeFile = null),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: isUploading ? null : _uploadPendingResume,
            icon: isUploading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload_outlined, size: 18),
            label: Text(isUploading ? "Uploading..." : "Upload Resume", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(ProfileState state) {
    final profile = state.profile.valueOrNull;
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    String summary = (profile?.profileSummary != null && profile!.profileSummary!.isNotEmpty && profile.profileSummary != "null") ? profile.profileSummary! : (cv?.cvData.personalInfo?.profileSummary ?? "Add a summary to highlight your achievements.");
    return _buildContentCard(title: "Profile Summary", description: summary, buttonText: "Update Summary", key: _summaryKey, onTap: () => _showProfileSummaryDialog(context, initialSummary: profile?.profileSummary));
  }

  Future<void> _viewResume(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) CommonMethods.showSnackBar(context, "Could not open resume");
    }
  }

  Widget _buildResumeSection(ProfileState state) {
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    final fileName = cv?.pdfFile?.split('/').last ?? "No resume uploaded";
    final isUploading = state.uploadStatus is AsyncLoading;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Resume", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (cv?.pdfFile != null) TextButton.icon(onPressed: () => _viewResume(cv!.pdfFile!), icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primaryBlue), label: const Text("View", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 15),
          if (_pendingResumeFile == null)
            InkWell(
              onTap: _pickResumeFile,
              child: CustomPaint(
                painter: DashedRectPainter(color: Colors.grey.shade300),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  child: Column(children: [Icon(cv != null ? Icons.description_outlined : Icons.file_present_outlined, size: 40, color: cv != null ? AppColors.primaryBlue : Colors.grey.shade300), const SizedBox(height: 15), Text(fileName, style: TextStyle(fontSize: 13, color: cv != null ? Colors.black87 : Colors.black54, fontWeight: cv != null ? FontWeight.w600 : FontWeight.normal)), const SizedBox(height: 5), const Text("supports PDF, DOCX up to 5MB", style: TextStyle(fontSize: 11, color: Colors.grey))]),
                ),
              ),
            )
          else
            _buildPendingResumeCard(isUploading),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(ProfileState state) {
    final manualExp = state.employments.valueOrNull ?? [];
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    final cvExp = cv?.cvData.experience ?? [];

    return Container(
      key: _experienceKey,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Work Experience", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => _showExperienceDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue))]),
          const SizedBox(height: 15),
          if (manualExp.isEmpty && cvExp.isEmpty) const Text("No experience added yet.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else ...[
            if (manualExp.isNotEmpty) ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: manualExp.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
              final e = manualExp[i];
              return _buildExperienceItem(title: e.designation, org: e.organizationName, dates: "${e.joinedDate} - ${e.isCurrent ? 'Present' : e.workedTill ?? ''}", desc: e.jobProfile, onEdit: () => _showExperienceDialog(context, employment: e), onDelete: e.id != null ? () => _showDeleteConfirmation(e.id!, "Experience") : null);
            }),
            if (manualExp.isNotEmpty && cvExp.isNotEmpty) const Divider(height: 30),
            if (cvExp.isNotEmpty) ...[
              const Text("From Resume", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: cvExp.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
                final e = cvExp[i];
                return _buildExperienceItem(title: e.designation, org: e.organizationName, dates: "${e.joinedDate} - ${e.workedTill}", desc: e.jobProfile);
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceItem({required String title, required String org, required String dates, required String desc, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          if (onEdit != null || onDelete != null) Row(children: [
            if (onEdit != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: onEdit),
            if (onDelete != null) Padding(padding: const EdgeInsets.only(left: 12), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: onDelete)),
          ]),
        ]),
        Text(org, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(dates, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5)),
      ],
    );
  }

  Widget _buildSkillsSection(ProfileState state) {
    final manualSkills = state.skills.valueOrNull ?? [];
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    final cvSkills = cv?.cvData.skills ?? [];
    final Set<String> seen = {};
    final List<Map<String, dynamic>> all = [];
    for (var s in manualSkills) { if (!seen.contains(s.skillName.toLowerCase())) { seen.add(s.skillName.toLowerCase()); all.add({'name': s.skillName, 'id': s.id, 'src': 'manual'}); } }
    for (var s in cvSkills) { if (!seen.contains(s.name.toLowerCase())) { seen.add(s.name.toLowerCase()); all.add({'name': s.name, 'src': 'cv'}); } }
    final bool showMore = all.length > 6 && !_isSkillsExpanded;
    final int count = showMore ? 6 : all.length;
    return Container(
      key: _skillsKey,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Skills", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => _showSkillDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue))]),
          const SizedBox(height: 15),
          if (all.isEmpty) const Text("No skills added yet.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else GridView.builder(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: count, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 38), itemBuilder: (context, i) {
            if (showMore && i == 5) return GestureDetector(onTap: () => setState(() => _isSkillsExpanded = true), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3))), child: Text("+${all.length - 5} more", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12))));
            final s = all[i]; final isM = s['src'] == 'manual';
            return Container(padding: const EdgeInsets.only(left: 12, right: 6), decoration: BoxDecoration(color: isM ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(25), border: Border.all(color: isM ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE))), child: Row(children: [Expanded(child: Text(s['name'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isM ? const Color(0xFF334155) : AppColors.primaryBlue, fontFamily: "ManRope"), maxLines: 1, overflow: TextOverflow.ellipsis)), if (isM) ...[const SizedBox(width: 4), InkWell(onTap: () => _showDeleteConfirmation(s['id'], "Skill"), child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Color(0xFF64748B))))]]));
          }),
          if (_isSkillsExpanded) Padding(padding: const EdgeInsets.only(top: 15), child: Center(child: TextButton(onPressed: () => setState(() => _isSkillsExpanded = false), child: const Text("Show Less", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))))),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(ProfileState state) {
    final manualP = state.projects.valueOrNull ?? [];
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    final cvP = cv?.cvData.projects ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Projects", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => _showProjectDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue))]),
          const SizedBox(height: 15),
          if (manualP.isEmpty && cvP.isEmpty) const Text("No projects added yet.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else ...[
            if (manualP.isNotEmpty) ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: manualP.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
              final p = manualP[i];
              return _buildProjectItem(title: p.title, client: p.client, dates: "${p.projectStatus} | ${p.startDate} - ${p.endDate ?? 'Present'}", desc: p.description, skills: p.skillsUsedNames, onEdit: () => _showProjectDialog(context, project: p), onDelete: p.id != null ? () => _showDeleteConfirmation(p.id!, "Project") : null);
            }),
            if (manualP.isNotEmpty && cvP.isNotEmpty) const Divider(height: 30),
            if (cvP.isNotEmpty) ...[
              const Text("From Resume", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: cvP.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
                final p = cvP[i];
                return _buildProjectItem(title: p.title, client: "Various", dates: p.projectStatus, desc: p.description, skills: p.skillsUsed);
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProjectItem({required String title, required String client, required String dates, required String desc, List<String>? skills, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        if (onEdit != null || onDelete != null) Row(children: [
          if (onEdit != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: onEdit),
          if (onDelete != null) Padding(padding: const EdgeInsets.only(left: 12), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: onDelete)),
        ]),
      ]),
      Text(client, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(dates, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 8),
      Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5)),
      if (skills?.isNotEmpty == true) ...[const SizedBox(height: 8), Text("Skills: ${skills!.join(', ')}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue))],
    ]);
  }

  Widget _buildCertificationsSection(ProfileState state) {
    final manualC = state.certifications.valueOrNull ?? [];
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    final cvC = cv?.cvData.certifications ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Certifications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => _showCertificationDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue))]),
          const SizedBox(height: 15),
          if (manualC.isEmpty && cvC.isEmpty) const Text("No certifications added yet.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else ...[
            if (manualC.isNotEmpty) ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: manualC.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
              final c = manualC[i];
              return _buildCertificationItem(name: c.name, org: c.issuingOrganization, dates: "Issued: ${c.issueDate}${c.expiryDate != null ? ' • Expires: ${c.expiryDate!}' : ''}", id: c.credentialId, onEdit: () => _showCertificationDialog(context, cert: c), onDelete: c.id != null ? () => _showDeleteConfirmation(c.id!, "Certification") : null);
            }),
            if (manualC.isNotEmpty && cvC.isNotEmpty) const Divider(height: 30),
            if (cvC.isNotEmpty) ...[
              const Text("From Resume", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: cvC.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
                final c = cvC[i];
                return _buildCertificationItem(name: c.name, org: c.issuingOrganization ?? "", dates: "Issued: ${c.issueDate ?? ''}${c.expiryDate != null ? ' • Expires: ${c.expiryDate!}' : ''}", id: c.credentialId ?? "");
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCertificationItem({required String name, required String org, required String dates, required String id, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        if (onEdit != null || onDelete != null) Row(children: [
          if (onEdit != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: onEdit),
          if (onDelete != null) Padding(padding: const EdgeInsets.only(left: 12), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: onDelete)),
        ]),
      ]),
      Text(org, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
      Text(dates, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      if (id.isNotEmpty) Text("ID: $id", style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }

  Widget _buildEducationSection(ProfileState state) {
    final manualEd = state.educations.valueOrNull ?? [];
    final cvs = state.cvs.valueOrNull;
    final cv = (cvs != null && cvs.isNotEmpty) ? cvs.first : null;
    final cvEd = cv?.cvData.education ?? [];
    return Container(
      key: _educationKey,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Education", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => _showEducationDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue))]),
          const SizedBox(height: 15),
          if (manualEd.isEmpty && cvEd.isEmpty) const Text("No education added yet.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else ...[
            if (manualEd.isNotEmpty) ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: manualEd.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
              final e = manualEd[i];
              return _buildEducationItem(course: "${e.courseName ?? 'Course'} / ${e.specializationName ?? 'Specialization'}", inst: e.institutionName ?? "Institution", univ: e.universityName, type: "${e.educationTypeName ?? ''} | ${e.courseTypeName ?? ''}", years: "${e.startYear} - ${e.endYear ?? ''}", grading: "Marks: ${e.marks}", onEdit: () => _showEducationDialog(context, education: e), onDelete: e.id != null ? () => _showDeleteConfirmation(e.id!, "Education") : null);
            }),
            if (manualEd.isNotEmpty && cvEd.isNotEmpty) const Divider(height: 30),
            if (cvEd.isNotEmpty) ...[
              const Text("From Resume", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: cvEd.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
                final e = cvEd[i];
                return _buildEducationItem(course: e.course, inst: e.institution, univ: e.university, type: "", years: "${e.startYear ?? ''} - ${e.endYear ?? ''}", grading: "Marks: ${e.marks}");
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEducationItem({required String course, required String inst, String? univ, required String type, required String years, required String grading, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        if (onEdit != null || onDelete != null) Row(children: [
          if (onEdit != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: onEdit),
          if (onDelete != null) Padding(padding: const EdgeInsets.only(left: 12), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: onDelete)),
        ]),
      ]),
      Text(inst, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
      if (univ != null && univ.isNotEmpty) Text(univ, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      if (type.isNotEmpty) Text(type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(years, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(grading, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }

  Widget _buildJobPreferencesSection(ProfileState state) {
    final prefs = state.jobPreferences.valueOrNull ?? [];
    return Container(
      key: _jobPreferencesKey,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Job Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => _showJobPreferencesDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue))]),
        const SizedBox(height: 15),
        if (prefs.isEmpty) Center(child: OutlinedButton.icon(onPressed: () => _showJobPreferencesDialog(context), icon: const Icon(Icons.add, size: 18), label: const Text("Add Preferences"), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue, side: const BorderSide(color: AppColors.primaryBlue), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))
        else ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: prefs.length, separatorBuilder: (_, __) => const Divider(height: 20), itemBuilder: (context, i) {
          final p = prefs[i];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(p.jobRole, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))), IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _showJobPreferencesDialog(context, preference: p), icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey))]),
            Text("${p.jobType} | ${p.preferredShift} Shift", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text("Expected: ₹${p.expectedSalary.toInt()} / year", style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text("Locations: ${p.preferredWorkLocations}", style: const TextStyle(color: Colors.black87, fontSize: 12)),
          ]);
        }),
      ]),
    );
  }

  void _showEducationDialog(BuildContext context, {EducationModel? education}) {
    ref.read(profileViewModelProvider.notifier).fetchEducationMasters();
    final startYearController = TextEditingController(text: education?.startYear.toString());
    final endYearController = TextEditingController(text: education?.endYear?.toString());
    final marksController = TextEditingController(text: education?.marks.toString());
    int? selType = education?.educationType; int? selInst = education?.institution; int? selUniv = education?.university; int? selCourse = education?.course; int? selSpec = education?.specialization; int? selCType = education?.courseType; int? selGrad = education?.gradingSystem;
    showDialog(context: context, barrierDismissible: false, builder: (context) => StatefulBuilder(builder: (context, setState) {
      final s = ref.watch(profileViewModelProvider);
      return Dialog(backgroundColor: Colors.white, insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildDialogHeader(education == null ? "Add Education" : "Edit Education"),
        Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
          Row(children: [Expanded(child: _buildDialogYearField("Start Year", startYearController, context, isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogYearField("End Year", endYearController, context))]),
          const SizedBox(height: 10),
          _buildMasterDropdown("Education Type", "Select Education Type", selType, s.eduTypes, (v) => setState(() => selType = v), isRequired: true),
          const SizedBox(height: 10),
          _buildMasterDropdown("Institution", "Select Institution", selInst, s.institutions, (v) => setState(() => selInst = v), isRequired: true),
          const SizedBox(height: 10),
          _buildMasterDropdown("University", "Select University", selUniv, s.universities, (v) => setState(() => selUniv = v)),
          const SizedBox(height: 10),
          _buildMasterDropdown("Course", "Select Course", selCourse, s.courses, (v) => setState(() => selCourse = v)),
          const SizedBox(height: 10),
          _buildMasterDropdown("Specialization", "Select specialization", selSpec, s.specializations, (v) => setState(() => selSpec = v)),
          const SizedBox(height: 10),
          _buildMasterDropdown("Course Type", "Select Course Type", selCType, s.courseTypes, (v) => setState(() => selCType = v)),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _buildMasterDropdown("Grading System", "Select System", selGrad, s.gradingSystems, (v) => setState(() => selGrad = v), isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogTextField("Marks", "Enter marks", marksController, keyboardType: TextInputType.number))]),
        ]))),
        _buildDialogActions(onCancel: () => Navigator.pop(context), onSave: () {
          if (selType == null || selInst == null || startYearController.text.isEmpty || selGrad == null) { CommonMethods.showSnackBar(context, "Please fill required fields"); return; }
          final model = EducationModel(id: education?.id, educationType: selType!, institution: selInst!, university: selUniv, course: selCourse, specialization: selSpec, courseType: selCType, gradingSystem: selGrad!, startYear: int.parse(startYearController.text), endYear: int.tryParse(endYearController.text), marks: double.tryParse(marksController.text) ?? 0.0);
          if (education == null) ref.read(profileViewModelProvider.notifier).addEducation(model);
          else ref.read(profileViewModelProvider.notifier).updateEducation(education.id!, model);
          Navigator.pop(context);
        }),
      ]));
    }));
  }

  void _showJobPreferencesDialog(BuildContext context, {JobPreferenceReqModel? preference}) {
    ref.read(profileViewModelProvider.notifier).fetchJobPreferenceMasters();
    final rC = TextEditingController(text: preference?.jobRole); final tC = TextEditingController(text: preference?.jobType); final sC = TextEditingController(text: preference?.expectedSalary.toString()); final lC = TextEditingController(text: preference?.preferredWorkLocations);
    int? selEType = preference?.desiredEmploymentType; String? selShift = preference?.preferredShift ?? "Day"; int? selSUnit = preference?.salaryUnit; int? selInd = preference?.industry; int? selDept = preference?.department;
    showDialog(context: context, barrierDismissible: false, builder: (context) => StatefulBuilder(builder: (context, setState) {
      final s = ref.watch(profileViewModelProvider);
      return Dialog(backgroundColor: Colors.white, insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildDialogHeader(preference == null ? "Add Job Preference" : "Edit Job Preference"),
        Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
          Row(children: [Expanded(child: _buildDialogTextField("Job Role", "Enter preferred role", rC, isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogTextField("Job Type", "e.g. Remote, On-site", tC))]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildMasterDropdown("Employment Type", "Select Type", selEType, s.employmentTypes, (v) => setState(() => selEType = v), isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogDropdown("Preferred Shift", "Select Shift", selShift, const ["Day", "Night", "Flexible"], (v) => setState(() => selShift = v), isRequired: true))]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildDialogTextField("Expected Salary", "Enter salary", sC, keyboardType: TextInputType.number, isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildMasterDropdown("Salary Unit", "Select Unit", selSUnit, s.salaryUnits, (v) => setState(() => selSUnit = v), isRequired: true))]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildMasterDropdown("Industry", "Select industry", selInd, s.industries, (v) => setState(() => selInd = v), isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildMasterDropdown("Department", "Select department", selDept, s.departments, (v) => setState(() => selDept = v), isRequired: true))]),
          const SizedBox(height: 10),
          _buildDialogTextField("Preferred Locations", "e.g. Pune, Mumbai, Remote", lC, isRequired: true),
        ]))),
        _buildDialogActions(onCancel: () => Navigator.pop(context), onSave: () {
          if (selInd == null || selDept == null || selEType == null || rC.text.isEmpty) { CommonMethods.showSnackBar(context, "Please fill required fields"); return; }
          final u = ref.read(profileViewModelProvider).profile.valueOrNull?.id ?? 0;
          final model = JobPreferenceReqModel(user: u, industry: selInd!, department: selDept!, jobRole: rC.text, jobType: tC.text, desiredEmploymentType: selEType!, preferredShift: selShift!, preferredWorkLocations: lC.text, salaryUnit: selSUnit ?? 0, expectedSalary: double.tryParse(sC.text) ?? 0);
          ref.read(profileViewModelProvider.notifier).addJobPreference(model);
          Navigator.pop(context);
        }),
      ]));
    }));
  }

  void _showExperienceDialog(BuildContext context, {EmploymentModel? employment}) {
    final oC = TextEditingController(text: employment?.organizationName); final dC = TextEditingController(text: employment?.designation); final lC = TextEditingController(text: employment?.location); final jC = TextEditingController(text: _formatDateForDisplay(employment?.joinedDate)); final wC = TextEditingController(text: employment?.isCurrent == true ? "Present" : _formatDateForDisplay(employment?.workedTill)); final nC = TextEditingController(text: (employment?.noticePeriodDays ?? 0).toString()); final descC = TextEditingController(text: employment?.jobProfile); bool isC = employment?.isCurrent ?? false;
    showDialog(context: context, barrierDismissible: false, builder: (context) => StatefulBuilder(builder: (context, setState) => Dialog(backgroundColor: Colors.white, insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
      _buildDialogHeader(employment == null ? "Add Experience" : "Edit Experience"),
      Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        _buildDialogTextField("Organization", "e.g. Acme Corp", oC, isRequired: true),
        const SizedBox(height: 10),
        _buildDialogTextField("Designation", "e.g. Software Engineer", dC, isRequired: true),
        const SizedBox(height: 10),
        _buildDialogTextField("Location", "e.g. New York, NY", lC),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _buildDialogDateField("Joined Date", jC, context, isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogDateField("Worked Till", wC, context, enabled: !isC))]),
        const SizedBox(height: 15),
        Row(children: [Checkbox(value: isC, activeColor: AppColors.primaryBlue, onChanged: (v) => setState(() { isC = v ?? false; wC.text = isC ? "Present" : ""; })), const Text("Currently Working", style: TextStyle(fontSize: 14))]),
        const SizedBox(height: 10),
        _buildDialogTextField("Notice Period (Days)", "0", nC, keyboardType: TextInputType.number),
        const SizedBox(height: 10),
        _buildDialogTextField("Description", "Describe your responsibilities...", descC, isRequired: true, maxLines: 4),
      ]))),
      _buildDialogActions(onCancel: () => Navigator.pop(context), onSave: () {
        if (oC.text.isEmpty || dC.text.isEmpty || jC.text.isEmpty) return;
        final model = EmploymentModel(id: employment?.id, isCurrent: isC, organizationName: oC.text, designation: dC.text, joinedDate: _formatDateForApi(jC.text), workedTill: isC ? null : _formatDateForApi(wC.text), jobProfile: descC.text, noticePeriodDays: int.tryParse(nC.text) ?? 0, location: lC.text.isEmpty ? "Not Specified" : lC.text);
        if (employment == null) ref.read(profileViewModelProvider.notifier).addEmployment(model);
        else ref.read(profileViewModelProvider.notifier).updateEmployment(employment.id!, model);
        Navigator.pop(context);
      }),
    ]))));
  }

  void _showSkillDialog(BuildContext context) {
    ref.read(profileViewModelProvider.notifier).fetchMasterSkills();
    int? selId; String? selProf; final eC = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (context) => StatefulBuilder(builder: (context, setState) {
      final s = ref.watch(profileViewModelProvider);
      return Dialog(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildDialogHeader("Add Skill"),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          _buildMasterDropdown("Skill", "Select Skill", selId, s.masterSkills.whenData((l) => l.map((e) => EducationMasterModel(id: e.id, name: e.name)).toList()), (v) => setState(() => selId = v), isRequired: true),
          const SizedBox(height: 10),
          _buildDialogDropdown("Proficiency", "Select Proficiency", selProf, const ["Beginner", "Intermediate", "Expert"], (v) => setState(() => selProf = v), isRequired: true),
          const SizedBox(height: 10),
          _buildDialogTextField("Experience (Years)", "e.g. 2", eC, isRequired: true, keyboardType: TextInputType.number),
        ])),
        _buildDialogActions(onCancel: () => Navigator.pop(context), onSave: () {
          if (selId == null || selProf == null || eC.text.isEmpty) return;
          ref.read(profileViewModelProvider.notifier).addUserSkill(UserSkillModel(user: 0, skill: selId!, proficiency: selProf!, experienceInYears: double.parse(eC.text), skillName: ''));
          Navigator.pop(context);
        }),
      ]));
    }));
  }

  void _showProjectDialog(BuildContext context, {ProjectModel? project}) {
    final tC = TextEditingController(text: project?.title); final cC = TextEditingController(text: project?.client); final dC = TextEditingController(text: project?.description); final sC = TextEditingController(text: _formatDateForDisplay(project?.startDate)); final eC = TextEditingController(text: project?.endDate != null ? _formatDateForDisplay(project?.endDate) : "Present"); String? selStatus = project?.projectStatus; int? selEmp = project?.employment;
    showDialog(context: context, barrierDismissible: false, builder: (context) => StatefulBuilder(builder: (context, setState) {
      final s = ref.watch(profileViewModelProvider);
      return Dialog(backgroundColor: Colors.white, insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildDialogHeader(project == null ? "Add Project" : "Edit Project"),
        Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
          _buildDialogTextField("Title", "e.g. E-commerce Platform", tC, isRequired: true),
          const SizedBox(height: 10),
          _buildDialogTextField("Client", "e.g. Acme Corp", cC, isRequired: true),
          const SizedBox(height: 10),
          _buildDialogDropdown("Status", "Select Status", selStatus, const ["Started", "In-Progress", "Completed"], (v) => setState(() => selStatus = v), isRequired: true),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildDialogDateField("Start Date", sC, context, isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogDateField("End Date", eC, context))]),
          const SizedBox(height: 10),
          _buildDialogTextField("Description", "Describe your project...", dC, isRequired: true, maxLines: 4),
          const SizedBox(height: 10),
          _buildMasterDropdown("Associated Employment", "Select Employment", selEmp, s.employments.whenData((l) => l.map((e) => EducationMasterModel(id: e.id!, name: "${e.organizationName} - ${e.designation}")).toList()), (v) => setState(() => selEmp = v)),
        ]))),
        _buildDialogActions(onCancel: () => Navigator.pop(context), onSave: () {
          if (tC.text.isEmpty || cC.text.isEmpty || sC.text.isEmpty) return;
          final model = ProjectModel(id: project?.id, title: tC.text, client: cC.text, projectStatus: selStatus ?? '', startDate: _formatDateForApi(sC.text), endDate: eC.text == "Present" ? null : _formatDateForApi(eC.text), description: dC.text, siteUrl: project?.siteUrl, skillsUsed: project?.skillsUsed ?? [], employment: selEmp);
          if (project == null) ref.read(profileViewModelProvider.notifier).addProject(model);
          else ref.read(profileViewModelProvider.notifier).updateProject(project.id!, model);
          Navigator.pop(context);
        }),
      ]));
    }));
  }

  void _showCertificationDialog(BuildContext context, {CertificationModel? cert}) {
    final nC = TextEditingController(text: cert?.name); final oC = TextEditingController(text: cert?.issuingOrganization); final iC = TextEditingController(text: _formatDateForDisplay(cert?.issueDate)); final eC = TextEditingController(text: _formatDateForDisplay(cert?.expiryDate)); final crId = TextEditingController(text: cert?.credentialId); final crUrl = TextEditingController(text: cert?.credentialUrl);
    showDialog(context: context, barrierDismissible: false, builder: (context) => Dialog(backgroundColor: Colors.white, insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
      _buildDialogHeader(cert == null ? "Add Certification" : "Edit Certification"),
      Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        _buildDialogTextField("Name", "e.g. AWS Certified", nC, isRequired: true),
        const SizedBox(height: 10),
        _buildDialogTextField("Issuing Organization", "e.g. Amazon", oC, isRequired: true),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _buildDialogDateField("Issue Date", iC, context, isRequired: true)), const SizedBox(width: 15), Expanded(child: _buildDialogDateField("Expiry Date", eC, context))]),
        const SizedBox(height: 10),
        _buildDialogTextField("Credential ID", "ABC123XYZ", crId),
        const SizedBox(height: 10),
        _buildDialogTextField("Credential URL", "https://...", crUrl),
      ]))),
      _buildDialogActions(onCancel: () => Navigator.pop(context), onSave: () {
        if (nC.text.isEmpty || oC.text.isEmpty || iC.text.isEmpty) return;
        final model = CertificationModel(id: cert?.id, name: nC.text, issuingOrganization: oC.text, issueDate: _formatDateForApi(iC.text), expiryDate: eC.text.isEmpty ? null : _formatDateForApi(eC.text), credentialId: crId.text, credentialUrl: crUrl.text);
        if (cert == null) ref.read(profileViewModelProvider.notifier).addCertification(model);
        else ref.read(profileViewModelProvider.notifier).updateCertification(cert.id!, model);
        Navigator.pop(context);
      }),
    ])));
  }

  void _showDeleteConfirmation(int id, String type) {
    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Delete $type"), content: Text("Are you sure you want to delete this $type?"), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
      TextButton(onPressed: () {
        final n = ref.read(profileViewModelProvider.notifier);
        if (type == "Experience") {
          n.deleteEmployment(id);
        } else if (type == "Education") {
          n.deleteEducation(id);
        } else if (type == "Skill") {
          n.deleteUserSkill(id);
        } else if (type == "Project") {
          n.deleteProject(id);
        } else if (type == "Certification") {
          n.deleteCertification(id);
        }
        Navigator.pop(context);
      }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
    ]));
  }

  Widget _buildDialogHeader(String title) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F1F5)))), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF444655)), onPressed: () => Navigator.pop(context)), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF444655)))]));
  }

  Widget _buildDialogActions({required VoidCallback onCancel, required VoidCallback onSave}) {
    return Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F1F5)))), child: Row(children: [
      Expanded(child: OutlinedButton(onPressed: onCancel, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF6366F1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text("Cancel", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)))),
      const SizedBox(width: 15),
      Expanded(child: ElevatedButton(onPressed: onSave, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
    ]));
  }

  Widget _buildMasterDropdown(String label, String hint, int? value, AsyncValue<List<EducationMasterModel>> itemsAsync, ValueChanged<int?> onChanged, {bool isRequired = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(text: label, style: const TextStyle(color: Color(0xFF444655), fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"), children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [])),
      const SizedBox(height: 8),
      itemsAsync.when(
        data: (items) => DropdownButtonFormField<int>(initialValue: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)), items: items.map((item) => DropdownMenuItem<int>(value: item.id, child: Text(item.name, style: const TextStyle(fontSize: 12, color: Color(0xFF444655)), overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged),
        loading: () => const SizedBox(height: 40, child: Center(child: LinearProgressIndicator())),
        error: (_, __) => Text("Error loading $label", style: const TextStyle(color: Colors.red, fontSize: 11)),
      ),
    ]);
  }

  Widget _buildDialogDropdown(String label, String hint, String? value, List<String> items, ValueChanged<String?> onChanged, {bool isRequired = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(text: label, style: const TextStyle(color: Color(0xFF444655), fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"), children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [])),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(initialValue: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)), items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF444655)), overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged),
    ]);
  }

  Widget _buildDialogTextField(String label, String hint, TextEditingController controller, {bool isRequired = false, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(text: label, style: const TextStyle(color: Color(0xFF444655), fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"), children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [])),
      const SizedBox(height: 8),
      TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, style: const TextStyle(fontSize: 12, color: Color(0xFF444655)), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
    ]);
  }

  Widget _buildDialogDateField(String label, TextEditingController controller, BuildContext context, {bool isRequired = false, bool enabled = true}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(text: label, style: TextStyle(color: enabled ? const Color(0xFF444655) : Colors.grey, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"), children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [])),
      const SizedBox(height: 8),
      TextField(controller: controller, readOnly: true, enabled: enabled, onTap: () async {
        DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100), builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1), onPrimary: Colors.white, onSurface: Color(0xFF444655))), child: child!));
        if (p != null) controller.text = DateFormat('MM/dd/yyyy').format(p);
      }, style: const TextStyle(fontSize: 14, color: Color(0xFF444655)), decoration: InputDecoration(hintText: "mm/dd/yyyy", hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14), suffixIcon: Icon(Icons.calendar_month_outlined, color: enabled ? const Color(0xFF6366F1) : Colors.grey, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade100)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
    ]);
  }

  Widget _buildDialogYearField(String label, TextEditingController controller, BuildContext context, {bool isRequired = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(text: label, style: const TextStyle(color: Color(0xFF444655), fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"), children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [])),
      const SizedBox(height: 8),
      TextField(controller: controller, readOnly: true, onTap: () async {
        showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text("Select Year"), content: SizedBox(width: 300, height: 300, child: YearPicker(firstDate: DateTime(DateTime.now().year - 100), lastDate: DateTime(DateTime.now().year + 10), selectedDate: controller.text.isNotEmpty ? DateTime(int.parse(controller.text)) : DateTime.now(), onChanged: (DateTime dateTime) { controller.text = dateTime.year.toString(); Navigator.pop(context); }))));
      }, style: const TextStyle(fontSize: 14, color: Color(0xFF444655)), decoration: InputDecoration(hintText: "YYYY", hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14), suffixIcon: Container(margin: const EdgeInsets.all(1), decoration: const BoxDecoration(color: Color(0xFF6366F1), borderRadius: BorderRadius.only(topRight: Radius.circular(9), bottomRight: Radius.circular(9))), child: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
    ]);
  }

  Widget _buildContentCard({required String title, required String description, required String buttonText, GlobalKey? key, VoidCallback? onTap}) {
    return Container(key: key, width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 15),
      Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.5), textAlign: TextAlign.start),
      const SizedBox(height: 20),
      Center(child: OutlinedButton.icon(onPressed: onTap, icon: const Icon(Icons.add, size: 18), label: Text(buttonText), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue, side: const BorderSide(color: AppColors.primaryBlue), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
    ]));
  }

  Widget _buildSocialLinks(String? phone, String? linkedin, String? github) {
    return Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("SOCIAL LINKS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 15),
      _buildSocialItem(Icons.phone_outlined, phone ?? "Phone not added"),
      const SizedBox(height: 12),
      _buildSocialItem(Icons.link_outlined, linkedin ?? "LinkedIn not added", isLink: linkedin != null),
      const SizedBox(height: 12),
      _buildSocialItem(Icons.code_outlined, github ?? "GitHub not added", isLink: github != null),
    ]));
  }

  Widget _buildSocialItem(IconData icon, String text, {bool isLink = false}) {
    return Row(children: [Icon(icon, size: 18, color: Colors.grey.shade400), const SizedBox(width: 12), Text(text, style: TextStyle(fontSize: 13, color: isLink ? AppColors.primaryBlue : Colors.black87))]);
  }

  /// Picks a resume file and stages it for upload. The actual upload API call
  /// only fires when the user taps the explicit "Upload Resume" button
  /// (see [_uploadPendingResume]).
  Future<void> _pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
      if (result != null && result.files.single.path != null) {
        setState(() => _pendingResumeFile = result.files.single);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _uploadPendingResume() {
    final path = _pendingResumeFile?.path;
    if (path == null) return;
    ref.read(profileViewModelProvider.notifier).uploadResume(path);
  }

  String _formatDateForApi(String dateStr) {
    if (dateStr.isEmpty || dateStr == "Present") return "";
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) return "${parts[2]}-${parts[0]}-${parts[1]}";
    } catch (e) { debugPrint("Error formatting date: $e"); }
    return dateStr;
  }

  String _formatDateForDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) return "${parts[1]}/${parts[2]}/${parts[0]}";
    } catch (e) { debugPrint("Error formatting date: $e"); }
    return dateStr;
  }

  void _showProfileSummaryDialog(BuildContext context, {String? initialSummary}) {
    final controller = TextEditingController(text: initialSummary);
    showDialog(context: context, builder: (context) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(20.0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Profile Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey))]),
      const SizedBox(height: 20),
      const Text("YOUR SUMMARY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
      const SizedBox(height: 10),
      TextField(controller: controller, maxLines: 5, style: const TextStyle(fontSize: 14), decoration: InputDecoration(hintText: "e.g. Dynamic professional...", hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryBlue)), contentPadding: const EdgeInsets.all(15))),
      const SizedBox(height: 25),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
        final p = ref.read(profileViewModelProvider).profile.valueOrNull;
        if (p != null) ref.read(profileViewModelProvider.notifier).updateProfile(p.id, {'profile_summary': controller.text.trim()});
        Navigator.pop(context);
      }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Save Summary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
    ]))));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar); final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: const Color(0xFFF7F9FC), child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class DashedRectPainter extends CustomPainter {
  final Color color; final double strokeWidth; final double gap;
  DashedRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});
  @override void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    Path path = Path(); path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(15)));
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        double length = gap; if (distance + length > measurePath.length) length = measurePath.length - distance;
        canvas.drawPath(measurePath.extractPath(distance, distance + length), paint); distance += length * 2;
      }
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}
