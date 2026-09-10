import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';
import 'package:job_world/ui/resume_builder/TemplateViewModel.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/data/model/profile/EmploymentModel.dart';
import 'package:job_world/data/model/profile/EducationModel.dart';
import 'package:job_world/data/model/profile/SkillModel.dart';
import 'package:job_world/data/model/profile/EducationMasterModel.dart';
import 'package:job_world/data/model/profile/ResumeTemplateModel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/util/dimensions.dart';

class ResumePreviewScreen extends ConsumerStatefulWidget {
  final String templateType;
  final ResumeTemplateModel? template;
  const ResumePreviewScreen({super.key, this.templateType = "Classic Professional", this.template});

  @override
  ConsumerState<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends ConsumerState<ResumePreviewScreen> {
  bool _isSkillsExpanded = false;
  Uint8List? _cachedPdfBytes;
  String? _lastHtml;
  int? _selectedOverrideTemplateId;
  String? _selectedOverrideTemplateName;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _selectedOverrideTemplateId = widget.template!.id;
      _selectedOverrideTemplateName = widget.template!.templateName;
    }
  }

  @override
  void didUpdateWidget(covariant ResumePreviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template?.id != widget.template?.id || oldWidget.templateType != widget.templateType) {
      if (widget.template != null) {
        _selectedOverrideTemplateId = widget.template!.id;
        _selectedOverrideTemplateName = widget.template!.templateName;
      } else {
        _selectedOverrideTemplateId = null;
        _selectedOverrideTemplateName = null;
      }
      _cachedPdfBytes = null;
      _lastHtml = null;
    }
  }

  ResumeTemplateModel? _getActiveTemplate(TemplateState templateState) {
    final templates = templateState.templates.valueOrNull ?? [];

    // An in-screen override (set when the user taps a template chip, or
    // seeded from widget.template in initState) always wins so switching
    // templates on this screen actually changes what's rendered.
    if (_selectedOverrideTemplateId != null && templates.isNotEmpty) {
      final found = templates.where((t) => t.id == _selectedOverrideTemplateId).firstOrNull;
      if (found != null) return found;
    }

    if (_selectedOverrideTemplateName != null && templates.isNotEmpty) {
      final found = templates.where((t) => t.templateName.toLowerCase() == _selectedOverrideTemplateName!.toLowerCase()).firstOrNull;
      if (found != null) return found;
    }

    // Fall back to the template passed via navigation only if the override
    // couldn't be resolved against the fetched list yet (e.g. still loading).
    if (widget.template != null) {
      return widget.template;
    }

    if (templates.isNotEmpty) {
      if (templateState.selectedTemplateId != null) {
        final found = templates.where((t) => t.id == templateState.selectedTemplateId).firstOrNull;
        if (found != null) return found;
      }

      final foundName = templates.where((t) => 
        t.templateName.toLowerCase() == widget.templateType.toLowerCase() ||
        t.templateName.toLowerCase().contains(widget.templateType.toLowerCase())
      ).firstOrNull;
      if (foundName != null) return foundName;

      return templates.first;
    }

    return null;
  }

  Future<Uint8List> _renderPdfBytes(PdfPageFormat format, ProfileState profileState, ResumeTemplateModel? activeTemplate) async {
    final html = _getProcessedHtml(profileState, activeTemplate);
    if (_cachedPdfBytes != null && _lastHtml == html) {
      return _cachedPdfBytes!;
    }

    if (html.isNotEmpty) {
      try {
        final bytes = await Printing.convertHtml(
          format: format,
          html: html,
        ).timeout(const Duration(seconds: 12));
        _cachedPdfBytes = bytes;
        _lastHtml = html;
        return bytes;
      } catch (e) {
        debugPrint("HTML conversion timed out or failed ($e). Falling back to native PDF layout.");
      }
    }

    final bytes = await _generateNativePdfBytes(profileState, activeTemplate);
    _cachedPdfBytes = bytes;
    _lastHtml = html;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final templateState = ref.watch(templateViewModelProvider);
    final activeTemplate = _getActiveTemplate(templateState);
    final displayTitle = activeTemplate?.templateName ?? widget.templateType;

    ref.listen(profileViewModelProvider.select((s) => s.profile), (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not load full profile data. Showing preview with available/default info.")),
            );
          });
        },
      );
    });

    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Start on Preview
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                )
              : null,
          title: Text(
            "Resume - ${displayTitle.toUpperCase()}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.download, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 16),
              onPressed: () {
                if (profileState.profile.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loading profile data... Please wait.")));
                } else {
                  _generateAndDownloadPdf(profileState, activeTemplate);
                }
              },
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Edit Details", icon: Icon(Icons.edit_note, size: Dimensions.level2Margin(context) + 12)),
              Tab(text: "Preview", icon: Icon(Icons.description_outlined, size: Dimensions.level2Margin(context) + 12)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEditForm(context, profileState),
            _buildPreview(context, profileState, templateState, activeTemplate),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, ProfileState profileState, TemplateState templateState, ResumeTemplateModel? activeTemplate) {
    return Column(
      children: [
        _buildTemplateSelectorBar(templateState, activeTemplate),
        Expanded(
          child: _buildHtmlPreview(profileState, activeTemplate),
        ),
      ],
    );
  }

  Widget _buildTemplateSelectorBar(TemplateState templateState, ResumeTemplateModel? activeTemplate) {
    final templates = templateState.templates.valueOrNull ?? [];
    if (templates.isEmpty) return const SizedBox.shrink();

    final currentId = activeTemplate?.id;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: templates.map((tmpl) {
            final isSelected = (currentId != null && currentId == tmpl.id) ||
                (activeTemplate?.templateName.toLowerCase() == tmpl.templateName.toLowerCase());
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  tmpl.templateName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                selectedColor: AppColors.primaryBlue,
                backgroundColor: const Color(0xFFF1F5F9),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedOverrideTemplateId = tmpl.id;
                      _selectedOverrideTemplateName = tmpl.templateName;
                      _cachedPdfBytes = null;
                      _lastHtml = null;
                    });
                    ref.read(templateViewModelProvider.notifier).selectTemplate(tmpl.id);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, ProfileState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      child: Column(
        children: [
          _buildSummarySection(context, state),
          Dimensions.verticalSpace(context, 15),
          _buildExperienceSection(context, state),
          Dimensions.verticalSpace(context, 15),
          _buildSkillsSection(context, state),
          Dimensions.verticalSpace(context, 15),
          _buildEducationSection(context, state),
          Dimensions.verticalSpace(context, 100),
        ],
      ),
    );
  }

  // --- Edit Form Section Builders ---
  Widget _buildSummarySection(BuildContext context, ProfileState state) {
    final profile = state.profile.valueOrNull;
    String summary = (profile?.profileSummary != null && profile!.profileSummary!.isNotEmpty && profile.profileSummary != "null")
        ? profile.profileSummary!
        : "Add a summary to highlight your achievements.";
    return _buildContentCard(
      context: context,
      title: "Profile Summary",
      description: summary,
      buttonText: "Update Summary",
      onTap: () => _showProfileSummaryDialog(context, initialSummary: profile?.profileSummary),
    );
  }

  Widget _buildExperienceSection(BuildContext context, ProfileState state) {
    final manualExp = state.employments.valueOrNull ?? [];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Work Experience", style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _showExperienceDialog(context), icon: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 16))
          ]),
          Dimensions.verticalSpace(context, 15),
          if (manualExp.isEmpty) Text("No experience added yet.", style: TextStyle(color: Colors.grey, fontSize: Dimensions.utilizationTextSize(context)))
          else ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: manualExp.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, i) {
              final e = manualExp[i];
              return _buildExperienceItem(
                context: context,
                title: e.designation,
                org: e.organizationName,
                dates: "${e.joinedDate} - ${e.isCurrent ? 'Present' : e.workedTill ?? ''}",
                desc: e.jobProfile,
                onEdit: () => _showExperienceDialog(context, employment: e),
                onDelete: e.id != null ? () => _showDeleteConfirmation(e.id!, "Experience") : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem({required BuildContext context, required String title, required String org, required String dates, required String desc, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2))),
          Row(children: [
            if (onEdit != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(Icons.edit_outlined, size: Dimensions.level2Margin(context) + 12, color: Colors.grey), onPressed: onEdit),
            if (onDelete != null) Padding(padding: const EdgeInsets.only(left: 12), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(Icons.delete_outline, size: Dimensions.level2Margin(context) + 12, color: Colors.redAccent), onPressed: onDelete)),
          ]),
        ]),
        Text(org, style: TextStyle(color: AppColors.primaryBlue, fontSize: Dimensions.utilizationTextSize(context) + 1, fontWeight: FontWeight.w600)),
        Text(dates, style: TextStyle(color: Colors.grey, fontSize: Dimensions.utilizationTextSize(context))),
        Dimensions.verticalSpace(context, 8),
        Text(desc, style: TextStyle(color: Colors.black87, fontSize: Dimensions.utilizationTextSize(context), height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context, ProfileState state) {
    final manualSkills = state.skills.valueOrNull ?? [];
    final bool showMore = manualSkills.length > 6 && !_isSkillsExpanded;
    final int count = showMore ? 6 : manualSkills.length;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Skills", style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _showSkillDialog(context), icon: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 16))
          ]),
          Dimensions.verticalSpace(context, 15),
          if (manualSkills.isEmpty) Text("No skills added yet.", style: TextStyle(color: Colors.grey, fontSize: Dimensions.utilizationTextSize(context)))
          else GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: Dimensions.smallSize(context) - 2),
            itemBuilder: (context, i) {
              if (showMore && i == 5) {
                return GestureDetector(
                  onTap: () => setState(() => _isSkillsExpanded = true),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3))),
                    child: Text("+${manualSkills.length - 5} more", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context))),
                  ),
                );
              }
              final s = manualSkills[i];
              return Container(
                padding: const EdgeInsets.only(left: 12, right: 6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(children: [
                  Expanded(child: Text(s.skillName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: Dimensions.utilizationTextSize(context), color: const Color(0xFF334155)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 4),
                  InkWell(onTap: s.id != null ? () => _showDeleteConfirmation(s.id!, "Skill") : null, child: Icon(Icons.close, size: Dimensions.utilizationTextSize(context) + 2, color: const Color(0xFF64748B))),
                ]),
              );
            },
          ),
          if (_isSkillsExpanded) Padding(padding: const EdgeInsets.only(top: 15), child: Center(child: TextButton(onPressed: () => setState(() => _isSkillsExpanded = false), child: Text("Show Less", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1))))),
        ],
      ),
    );
  }

  Widget _buildEducationSection(BuildContext context, ProfileState state) {
    final manualEd = state.educations.valueOrNull ?? [];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Education", style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _showEducationDialog(context), icon: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 16))
          ]),
          Dimensions.verticalSpace(context, 15),
          if (manualEd.isEmpty) Text("No education added yet.", style: TextStyle(color: Colors.grey, fontSize: Dimensions.utilizationTextSize(context)))
          else ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: manualEd.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, i) {
              final e = manualEd[i];
              return _buildEducationItem(
                context: context,
                course: "${e.courseName ?? 'Course'} / ${e.specializationName ?? 'Specialization'}",
                inst: e.institutionName ?? "Institution",
                years: "${e.startYear} - ${e.endYear ?? ''}",
                onEdit: () => _showEducationDialog(context, education: e),
                onDelete: e.id != null ? () => _showDeleteConfirmation(e.id!, "Education") : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem({required BuildContext context, required String course, required String inst, required String years, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(course, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2))),
        Row(children: [
          if (onEdit != null) IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(Icons.edit_outlined, size: Dimensions.level2Margin(context) + 12, color: Colors.grey), onPressed: onEdit),
          if (onDelete != null) Padding(padding: const EdgeInsets.only(left: 12), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(Icons.delete_outline, size: Dimensions.level2Margin(context) + 12, color: Colors.redAccent), onPressed: onDelete)),
        ]),
      ]),
      Text(inst, style: TextStyle(color: AppColors.primaryBlue, fontSize: Dimensions.utilizationTextSize(context) + 1, fontWeight: FontWeight.w600)),
      Text(years, style: TextStyle(color: Colors.grey, fontSize: Dimensions.utilizationTextSize(context))),
    ]);
  }

  Widget _buildContentCard({required BuildContext context, required String title, required String description, required String buttonText, VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(2))), Dimensions.horizontalSpace(context, 10), Text(title, style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold))]),
        Dimensions.verticalSpace(context, 15),
        Text(description, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade500, height: 1.5), textAlign: TextAlign.start),
        Dimensions.verticalSpace(context, 20),
        Center(child: OutlinedButton.icon(onPressed: onTap, icon: Icon(Icons.add, size: Dimensions.utilizationTextSize(context) + 6), label: Text(buttonText, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2)), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue, side: const BorderSide(color: AppColors.primaryBlue), padding: EdgeInsets.symmetric(horizontal: Dimensions.level4Margin(context) + 8, vertical: Dimensions.level3Margin(context) - 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }

  // --- Dialog Methods ---
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
        if (employment == null) {
          ref.read(profileViewModelProvider.notifier).addEmployment(model);
        } else {
          ref.read(profileViewModelProvider.notifier).updateEmployment(employment.id!, model);
        }
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
          if (education == null) {
            ref.read(profileViewModelProvider.notifier).addEducation(model);
          } else {
            ref.read(profileViewModelProvider.notifier).updateEducation(education.id!, model);
          }
          Navigator.pop(context);
        }),
      ]));
    }));
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
        }
        Navigator.pop(context);
      }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
    ]));
  }

  // --- UI Component Helpers ---
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

  Widget _buildHtmlPreview(ProfileState profileState, ResumeTemplateModel? activeTemplate) {
    final profile = profileState.profile.valueOrNull;
    
    if (profileState.profile.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Loading your profile data..."),
          ],
        ),
      );
    }

    if (profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            const Text("Profile data not found."),
            TextButton(
              onPressed: () => ref.read(profileViewModelProvider.notifier).fetchProfile(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final html = _getProcessedHtml(profileState, activeTemplate);
    if (html.isEmpty) {
      return const Center(child: Text("Template content is empty."));
    }

    return Container(
      color: const Color(0xFF525659),
      child: PdfPreview(
        // PdfPreview caches its rendered document internally and does not
        // reliably detect that `build` should be re-invoked just because the
        // closure instance changed. Keying it on the actual processed HTML
        // forces Flutter to create a fresh PdfPreview (and thus re-render)
        // whenever the selected template's content actually changes.
        key: ValueKey('${activeTemplate?.id}_${html.hashCode}'),
        build: (format) => _renderPdfBytes(format, profileState, activeTemplate),
        useActions: false,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        previewPageMargin: EdgeInsets.zero,
        loadingWidget: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 15),
              Text("Rendering Template...", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  String _getProcessedHtml(ProfileState state, ResumeTemplateModel? template) {
    final profile = state.profile.valueOrNull;
    if (profile == null) return "";

    final templateData = _getHtmlAndCssForTemplate(template, widget.templateType);
    String html = templateData.html;
    String css = templateData.css;

    if (html.isEmpty) return "";

    // Helper to replace variations of keys
    void smartReplace(String key, String value) {
      final variations = [
        key,
        key.replaceAll('_', ''),
        _toCamelCase(key),
        'personal_info.$key',
        'personal_info.${key.replaceAll('_', '')}',
        'personal_info.${_toCamelCase(key)}',
      ];

      for (var v in variations) {
        final escapedV = RegExp.escape(v);
        html = html.replaceAll(RegExp('\\{\\{\\s*$escapedV\\s*\\}\\}'), value);
      }
    }

    // Bind Personal Profile Fields
    final fullName = '${profile.firstName} ${profile.lastName}'.trim();
    final loc = profile.city.isNotEmpty && profile.state.isNotEmpty
        ? '${profile.city}, ${profile.state}'
        : '${profile.city}${profile.state}';

    smartReplace('first_name', profile.firstName);
    smartReplace('last_name', profile.lastName);
    smartReplace('full_name', fullName);
    smartReplace('name', fullName);
    smartReplace('candidate_type', profile.candidateType ?? 'Professional');
    smartReplace('designation', profile.candidateType ?? 'Professional');
    smartReplace('title', profile.candidateType ?? 'Professional');
    smartReplace('job_title', profile.candidateType ?? 'Professional');
    smartReplace('phone', profile.phoneNumber);
    smartReplace('phone_number', profile.phoneNumber);
    smartReplace('mobile', profile.phoneNumber);
    smartReplace('email', 'abc@gmail.com');
    smartReplace('city', profile.city);
    smartReplace('state', profile.state);
    smartReplace('location', loc);
    smartReplace('address', loc);
    smartReplace('summary', profile.profileSummary ?? '');
    smartReplace('profile_summary', profile.profileSummary ?? '');
    smartReplace('about', profile.profileSummary ?? '');
    smartReplace('about_me', profile.profileSummary ?? '');
    smartReplace('linkedin', profile.linkedinUrl ?? '');
    smartReplace('linkedin_url', profile.linkedinUrl ?? '');
    smartReplace('github', profile.githubUrl ?? '');
    smartReplace('github_url', profile.githubUrl ?? '');

    // Bind Experience List
    final employments = state.employments.valueOrNull ?? [];
    String expHtml = "";
    for (var exp in employments) {
      expHtml += """
        <div class="experience-item item" style="margin-bottom: 15px;">
          <div style="display: flex; justify-content: space-between; font-weight: bold;">
            <span style="font-size: 1.05em; color: #0F172A;">${exp.designation}</span>
            <span style="font-size: 0.9em; color: #64748B;">${exp.joinedDate} - ${exp.isCurrent ? 'Present' : exp.workedTill}</span>
          </div>
          <div style="color: #2563EB; font-weight: 600; font-size: 0.95em; margin-top: 2px;">${exp.organizationName}</div>
          <div style="font-size: 0.9em; color: #334155; margin-top: 5px; line-height: 1.5;">${exp.jobProfile}</div>
        </div>
      """;
    }
    html = html.replaceAll(RegExp('\\{\\{\\s*experience_list\\s*\\}\\}'), expHtml);
    html = html.replaceAll(RegExp('\\{\\{\\s*experience\\s*\\}\\}'), expHtml);

    // Bind Education List
    final educations = state.educations.valueOrNull ?? [];
    String eduHtml = "";
    for (var edu in educations) {
      eduHtml += """
        <div class="education-item item" style="margin-bottom: 15px;">
          <div style="display: flex; justify-content: space-between; font-weight: bold;">
            <span style="font-size: 1.05em; color: #0F172A;">${edu.courseName ?? "Degree"}</span>
            <span style="font-size: 0.9em; color: #64748B;">${edu.startYear} - ${edu.endYear ?? 'Present'}</span>
          </div>
          <div style="color: #475569; font-weight: 500; font-size: 0.95em;">${edu.institutionName ?? "University"}</div>
          <div style="font-size: 0.9em; color: #2563EB;">Score: ${edu.marks}</div>
        </div>
      """;
    }
    html = html.replaceAll(RegExp('\\{\\{\\s*education_list\\s*\\}\\}'), eduHtml);
    html = html.replaceAll(RegExp('\\{\\{\\s*education\\s*\\}\\}'), eduHtml);

    // Bind Skills List
    final skills = state.skills.valueOrNull ?? [];
    String skillsHtml = '<div style="display: flex; flex-wrap: wrap; gap: 8px;">';
    for (var skill in skills) {
      skillsHtml += '<span class="skill-tag skill-badge skill-pill tech-tag">${skill.skillName}</span>';
    }
    skillsHtml += '</div>';
    html = html.replaceAll(RegExp('\\{\\{\\s*skills_list\\s*\\}\\}'), skillsHtml);
    html = html.replaceAll(RegExp('\\{\\{\\s*skills\\s*\\}\\}'), skillsHtml);

    // Check if HTML is already a complete HTML document
    final bool isFullDocument = html.toLowerCase().contains('<html') || html.toLowerCase().contains('<!doctype');

    if (isFullDocument) {
      if (css.isNotEmpty && !html.contains(css)) {
        if (html.contains('</head>')) {
          return html.replaceFirst('</head>', '<style>$css</style></head>');
        } else {
          return '<style>$css</style>$html';
        }
      }
      return html;
    }

    return """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        @page { margin: 0; }
        body { 
          font-family: 'Helvetica', 'Arial', sans-serif; 
          margin: 0; 
          padding: 20px; 
          color: #333; 
          line-height: 1.4;
          background: white;
        }
        h1, h2, h3 { color: #1E293B; margin-top: 0; }
        .skill-tag { margin-right: 5px; margin-bottom: 5px; display: inline-block; }
        .experience-item, .education-item { margin-bottom: 15px; }
        $css
      </style>
    </head>
    <body>
      $html
    </body>
    </html>
    """;
  }

  ({String html, String css}) _getHtmlAndCssForTemplate(ResumeTemplateModel? template, String fallbackType) {
    if (template != null && (template.htmlContent?.trim().isNotEmpty ?? false)) {
      return (html: template.htmlContent!, css: template.cssContent ?? "");
    }

    final name = (template?.templateName.isNotEmpty ?? false) ? template!.templateName : fallbackType;
    final lower = name.toLowerCase();
    final id = template?.id ?? 0;

    // 1. Modern Sidebar layout
    if (lower.contains('sidebar') || lower.contains('modern') || lower.contains('executive') || id % 4 == 2) {
      return (
        css: """
          @page { margin: 0; }
          body { font-family: 'Arial', 'Helvetica', sans-serif; margin: 0; padding: 0; color: #333; background: #FFF; }
          .container { display: flex; width: 100%; min-height: 100vh; }
          .sidebar { width: 32%; background: #1E293B; color: #F8FAFC; padding: 30px 18px; box-sizing: border-box; }
          .main { width: 68%; padding: 30px 25px; box-sizing: border-box; background: #FFFFFF; }
          .sidebar .sidebar-title { font-size: 11px; font-weight: bold; color: #60A5FA; text-transform: uppercase; letter-spacing: 1.5px; border-bottom: 1px solid #334155; padding-bottom: 4px; margin-top: 22px; margin-bottom: 10px; }
          .sidebar .contact-item { font-size: 10px; color: #CBD5E1; margin-bottom: 8px; word-break: break-all; }
          .sidebar .skill-pill, .sidebar .skill-tag { display: block; background: #334155; color: #F1F5F9; padding: 5px 8px; border-radius: 4px; font-size: 9.5px; margin-bottom: 6px; }
          .main .name { font-size: 26px; font-weight: 800; color: #0F172A; text-transform: uppercase; letter-spacing: 1px; }
          .main .title { font-size: 13px; font-weight: 700; color: #2563EB; text-transform: uppercase; margin-top: 4px; margin-bottom: 20px; }
          .main .section-title { font-size: 12px; font-weight: bold; color: #0F172A; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid #E2E8F0; padding-bottom: 4px; margin-top: 20px; margin-bottom: 12px; }
          .main .summary { font-size: 11px; color: #475569; line-height: 1.6; }
        """,
        html: """
          <div class="container">
            <div class="sidebar">
              <div class="sidebar-title">Contact</div>
              <div class="contact-item">{{phone}}</div>
              <div class="contact-item">{{email}}</div>
              <div class="contact-item">{{location}}</div>
              <div class="sidebar-title">Core Skills</div>
              {{skills_list}}
            </div>
            <div class="main">
              <div class="name">{{full_name}}</div>
              <div class="title">{{candidate_type}}</div>
              <div class="section-title">About Me</div>
              <div class="summary">{{profile_summary}}</div>
              <div class="section-title">Experience</div>
              {{experience_list}}
              <div class="section-title">Education</div>
              {{education_list}}
            </div>
          </div>
        """
      );
    }

    // 2. Creative Designer layout
    if (lower.contains('creative') || lower.contains('designer') || lower.contains('art') || lower.contains('color') || id % 4 == 3) {
      return (
        css: """
          @page { margin: 0; }
          body { font-family: 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif; margin: 0; padding: 30px; color: #1E1B4B; background: #FAF5FF; }
          .header-card { background: linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%); color: white; padding: 22px; border-radius: 12px; margin-bottom: 18px; }
          .name { font-size: 26px; font-weight: bold; letter-spacing: 0.5px; }
          .title { font-size: 13px; color: #DDD6FE; font-weight: 600; text-transform: uppercase; margin-top: 4px; }
          .contact-row { display: flex; gap: 15px; margin-top: 10px; font-size: 10px; color: #EDE9FE; }
          .section-card { background: white; padding: 18px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 16px; border-left: 4px solid #7C3AED; }
          .section-title { font-size: 12px; font-weight: bold; color: #4C1D95; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 10px; }
          .summary { font-size: 11px; color: #4C1D95; line-height: 1.6; opacity: 0.9; }
          .skill-badge, .skill-tag { display: inline-block; background: #F3E8FF; color: #6B21A8; padding: 5px 12px; border-radius: 20px; font-size: 9.5px; font-weight: 600; margin-right: 6px; margin-bottom: 6px; }
        """,
        html: """
          <div class="header-card">
            <div class="name">{{full_name}}</div>
            <div class="title">{{candidate_type}}</div>
            <div class="contact-row">
              <span>{{phone}}</span>
              <span>{{email}}</span>
              <span>{{location}}</span>
            </div>
          </div>
          <div class="section-card">
            <div class="section-title">Profile Overview</div>
            <div class="summary">{{profile_summary}}</div>
          </div>
          <div class="section-card">
            <div class="section-title">Work Experience</div>
            {{experience_list}}
          </div>
          <div class="section-card">
            <div class="section-title">Education</div>
            {{education_list}}
          </div>
          <div class="section-card">
            <div class="section-title">Skills & Expertise</div>
            {{skills_list}}
          </div>
        """
      );
    }

    // 3. Minimal Tech layout
    if (lower.contains('minimal') || lower.contains('tech') || lower.contains('code') || lower.contains('developer') || lower.contains('clean') || id % 4 == 0) {
      return (
        css: """
          @page { margin: 0; }
          body { font-family: 'Consolas', 'Fira Code', 'Courier New', monospace, sans-serif; margin: 0; padding: 30px; color: #0F172A; background: #FFFFFF; line-height: 1.5; }
          .header { border-bottom: 2px dashed #0F172A; padding-bottom: 14px; margin-bottom: 18px; }
          .name { font-size: 24px; font-weight: bold; color: #0F172A; }
          .title { font-size: 12px; color: #2563EB; font-weight: bold; margin-top: 4px; }
          .contact { font-size: 10px; color: #64748B; margin-top: 8px; }
          .section-title { font-size: 11.5px; font-weight: bold; color: #0F172A; text-transform: uppercase; margin-top: 18px; margin-bottom: 10px; background: #F1F5F9; padding: 4px 8px; border-left: 3px solid #0F172A; }
          .summary { font-size: 10.5px; color: #334155; line-height: 1.6; }
          .tech-tag, .skill-tag { display: inline-block; background: #0F172A; color: #F8FAFC; padding: 3px 8px; border-radius: 3px; font-size: 9px; font-family: monospace; margin-right: 5px; margin-bottom: 5px; }
        """,
        html: """
          <div class="header">
            <div class="name">&lt;{{full_name}} /&gt;</div>
            <div class="title">// {{candidate_type}}</div>
            <div class="contact">contact: [{{phone}}] [{{email}}] [{{location}}]</div>
          </div>
          <div class="section-title">01. Summary</div>
          <div class="summary">{{profile_summary}}</div>
          <div class="section-title">02. Experience</div>
          {{experience_list}}
          <div class="section-title">03. Education</div>
          {{education_list}}
          <div class="section-title">04. Tech Stack & Skills</div>
          {{skills_list}}
        """
      );
    }

    // 4. Default: Classic Professional
    return (
      css: """
        @page { margin: 0; }
        body { font-family: 'Helvetica', 'Arial', sans-serif; margin: 0; padding: 35px; color: #1E293B; line-height: 1.5; background: white; }
        .header { text-align: center; border-bottom: 2px solid #2563EB; padding-bottom: 18px; margin-bottom: 22px; }
        .name { font-size: 28px; font-weight: bold; text-transform: uppercase; color: #0F172A; letter-spacing: 1px; }
        .title { font-size: 13px; color: #2563EB; font-weight: bold; margin-top: 4px; text-transform: uppercase; letter-spacing: 1px; }
        .contact-info { margin-top: 8px; font-size: 11px; color: #64748B; }
        .section-title { font-size: 12px; font-weight: bold; color: #0F172A; border-bottom: 1.5px solid #E2E8F0; padding-bottom: 4px; margin-top: 20px; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 0.8px; }
        .summary { font-size: 11px; color: #334155; line-height: 1.6; }
        .skill-tag { display: inline-block; background: #F1F5F9; color: #334155; padding: 4px 10px; border-radius: 4px; font-size: 10px; font-weight: 600; border: 1px solid #E2E8F0; margin-right: 6px; margin-bottom: 6px; }
      """,
      html: """
        <div class="header">
          <div class="name">{{full_name}}</div>
          <div class="title">{{candidate_type}}</div>
          <div class="contact-info">{{phone}} &nbsp;|&nbsp; {{email}} &nbsp;|&nbsp; {{location}}</div>
        </div>
        <div class="section-title">Professional Summary</div>
        <div class="summary">{{profile_summary}}</div>
        <div class="section-title">Work Experience</div>
        {{experience_list}}
        <div class="section-title">Education</div>
        {{education_list}}
        <div class="section-title">Skills & Competencies</div>
        {{skills_list}}
      """
    );
  }

  String _toCamelCase(String text) {
    List<String> parts = text.split('_');
    if (parts.length == 1) return text;
    String camel = parts[0];
    for (int i = 1; i < parts.length; i++) {
      camel += parts[i][0].toUpperCase() + parts[i].substring(1);
    }
    return camel;
  }

  // --- PDF Generation ---
  Future<void> _generateAndDownloadPdf(ProfileState state, ResumeTemplateModel? activeTemplate) async {
    try {
      final profile = state.profile.valueOrNull;
      if (profile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile data not available for download.")));
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generating PDF... Please wait."), duration: Duration(seconds: 1)));
      }

      Uint8List? pdfBytes;
      final fullHtml = _getProcessedHtml(state, activeTemplate);

      if (fullHtml.isNotEmpty) {
        try {
          pdfBytes = await Printing.convertHtml(
            format: PdfPageFormat.a4,
            html: fullHtml,
          ).timeout(const Duration(seconds: 12));
        } catch (e) {
          debugPrint("HTML conversion failed or timed out on download: $e");
        }
      }

      pdfBytes ??= await _generateNativePdfBytes(state, activeTemplate);

      final templateName = activeTemplate?.templateName ?? widget.templateType;

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes!,
        name: '${profile.firstName}_${profile.lastName}_${templateName.replaceAll(" ", "_")}_Resume.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generating PDF: $e")));
      }
    }
  }

  Future<Uint8List> _generateNativePdfBytes(ProfileState state, ResumeTemplateModel? activeTemplate) async {
    final profile = state.profile.valueOrNull;
    if (profile == null) return Uint8List(0);

    final pdf = pw.Document();
    final employments = state.employments.valueOrNull ?? [];
    final educations = state.educations.valueOrNull ?? [];
    final skills = state.skills.valueOrNull ?? [];

    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(right: 20, bottom: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (pw.Context context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 40, right: 40, top: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("${profile.firstName.toUpperCase()} ${profile.lastName.toUpperCase()}", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text(profile.candidateType?.toUpperCase() ?? "SOFTWARE ENGINEER", style: pw.TextStyle(fontSize: 14, color: PdfColors.indigo, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text("${profile.city}, ${profile.state}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  pw.SizedBox(height: 10),
                  pw.Row(children: [
                    pw.Text("Phone: ${profile.phoneNumber}", style: const pw.TextStyle(fontSize: 10)),
                    if (profile.linkedinUrl != null) ...[pw.SizedBox(width: 15), pw.Text("LinkedIn", style: const pw.TextStyle(fontSize: 10))],
                    if (profile.githubUrl != null) ...[pw.SizedBox(width: 15), pw.Text("GitHub", style: const pw.TextStyle(fontSize: 10))],
                  ]),
                  pw.Divider(height: 30, thickness: 1.5),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfSectionTitle("PROFESSIONAL SUMMARY", boldFont),
                  pw.SizedBox(height: 10),
                  pw.Text(profile.profileSummary ?? "", style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
                  pw.SizedBox(height: 20),
                ],
              ),
            ),
            if (employments.isNotEmpty) ...[
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                child: _buildPdfSectionTitle("WORK EXPERIENCE", boldFont),
              ),
              ...employments.map((e) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(e.designation, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text("${e.joinedDate} - ${e.isCurrent ? 'Present' : e.workedTill}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ],
                    ),
                    pw.Text(e.organizationName, style: pw.TextStyle(fontSize: 10, color: PdfColors.indigo, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(e.jobProfile, style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.2)),
                  ],
                ),
              )),
            ],
            if (educations.isNotEmpty) ...[
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: _buildPdfSectionTitle("EDUCATION", boldFont),
              ),
              ...educations.map((e) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(e.courseName ?? "Degree", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text("${e.startYear} - ${e.endYear}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ],
                    ),
                    pw.Text(e.institutionName ?? "University", style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              )),
            ],
            if (skills.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPdfSectionTitle("SKILLS", boldFont),
                    pw.SizedBox(height: 10),
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((s) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))),
                        child: pw.Text(s.skillName, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildPdfSectionTitle(String title, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: boldFont),
        ),
        pw.SizedBox(height: 2),
        pw.Container(width: 30, height: 1.5, color: PdfColors.indigo),
      ],
    );
  }
}
