import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/data/model/jobpost/TlAttachedCvModel.dart';
import 'package:job_world/data/model/jobpost/TlJobPostModel.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/ui/tl/jobs/TlJobsViewModel.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// Job detail screen backed by GET /jobpost/post-jobs/{id}/. Also shows the
/// job's applied candidates inline (from GET /jobpost/attached-cvs/) —
/// there is no separate Applied Candidates page anymore.
class TlJobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;

  const TlJobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<TlJobDetailScreen> createState() => _TlJobDetailScreenState();
}

class _TlJobDetailScreenState extends ConsumerState<TlJobDetailScreen> {
  final TextEditingController _candidateSearchController = TextEditingController();
  List<TlCandidateModel> _candidates = [];
  bool _loadingCandidates = true;
  String? _candidatesError;
  bool _rankingCvs = false;

  static const List<Color> _avatarPalette = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF0EA5E9),
  ];

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void dispose() {
    _candidateSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _loadingCandidates = true;
      _candidatesError = null;
    });
    try {
      final cvs = await ref.read(tlJobRepositoryProvider).getAttachedCvs();
      if (!mounted) return;
      setState(() {
        _candidates = cvs.where((cv) => cv.postJob == widget.jobId).map(_toCandidateModel).toList();
        _loadingCandidates = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _candidatesError = e.toString();
        _loadingCandidates = false;
      });
    }
  }

  /// GET .../post-jobs/{id}/rank-cvs/ — AI-ranks every CV attached to this
  /// job and replaces the Applied Candidates list with the ranked result.
  Future<void> _rankCvs(String jobTitle) async {
    setState(() => _rankingCvs = true);
    try {
      final result = await ref.read(tlJobRepositoryProvider).rankCvs(widget.jobId);
      if (!mounted) return;
      setState(() {
        _candidates = result.rankedCandidates.map(_toCandidateModel).toList();
        _rankingCvs = false;
      });
      showTlSnack(context, result.message.isNotEmpty ? result.message : "Ranked ${result.rankedCandidatesVisible} candidate(s) for $jobTitle");
    } catch (e) {
      if (!mounted) return;
      setState(() => _rankingCvs = false);
      showTlSnack(context, "Failed to rank CVs: $e");
    }
  }

  TlCandidateModel _toCandidateModel(TlAttachedCvModel cv) {
    final details = cv.candidateDetails;
    final name = details != null && (details.firstName.isNotEmpty || details.lastName.isNotEmpty)
        ? "${details.firstName} ${details.lastName}".trim()
        : (cv.name.isNotEmpty ? cv.name : cv.emails);
    final email = details?.email.isNotEmpty == true ? details!.email : cv.emails;
    final isDone = cv.processingStatus == 'done';

    final tags = <String>[];
    if (isDone) {
      tags.add('Done');
      if (cv.approved == true) {
        tags.add('Approved');
      } else if (cv.approved == false) {
        tags.add('Rejected');
      } else {
        tags.add('Pending');
      }
    } else {
      tags.add('In Review');
    }

    final selectStatus = cv.approved == true
        ? 'Selected'
        : cv.approved == false
            ? 'Rejected'
            : 'Select Status';

    return TlCandidateModel(
      id: cv.id.toString(),
      name: name.isEmpty ? '-' : name,
      email: email,
      phone: details?.phone,
      initial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      avatarColor: _avatarPalette[cv.id % _avatarPalette.length],
      statusTags: tags,
      score: cv.totalScore?.toDouble() ?? cv.examScore?.toDouble(),
      selectStatus: selectStatus,
      source: cv.sourceType == 'walk-in' ? 'Walk-in' : 'Applied',
    );
  }

  List<TlCandidateModel> get _filteredCandidates {
    final query = _candidateSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _candidates;
    return _candidates.where((c) => c.name.toLowerCase().contains(query) || c.email.toLowerCase().contains(query)).toList();
  }

  void _updateCandidateStatus(int index, String status) {
    setState(() => _candidates[index] = _candidates[index].copyWith(selectStatus: status));
    if (status == 'Rejected' || status == 'On Hold') {
      context.push(AppRoutes.tlAddRemark, extra: _candidates[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(tlJobDetailProvider(widget.jobId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: jobAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, error),
          data: (job) => _buildContent(context, job),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 40),
            const SizedBox(height: 12),
            Text("Failed to load job details.\n$error", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(tlJobDetailProvider(widget.jobId)),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TlJobPostModel job) {
    return SingleChildScrollView(
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
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final updated = await context.push(AppRoutes.tlPostJob, extra: job);
                  if (updated == true) {
                    ref.invalidate(tlJobDetailProvider(widget.jobId));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                  child: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(job.jobTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ),
              TlStatusChip.forTag(job.statusDisplay),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/png/ic_briefcase_badge.png', width: 16, height: 16),
                  const SizedBox(width: 4),
                  Text("${job.minYoe}-${job.maxYoe} Yrs Exp", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_alt_rounded, size: 15, color: const Color(0xFF7C3AED)),
                  const SizedBox(width: 4),
                  Text("${job.numberOfVacancy} Positions Open", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              if (job.locationNames.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/png/ic_location_badge.png', width: 16, height: 16),
                    const SizedBox(width: 4),
                    Text(job.locationNames.join(", "), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              if (job.createdAt.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/png/ic_clock_badge.png', width: 16, height: 16),
                    const SizedBox(width: 4),
                    Text(_postedAgo(job.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
            ],
          ),
          Dimensions.verticalSpace(context, 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showTlSnack(context, "Job link copied to clipboard"),
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text("Share Link", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _rankingCvs ? null : () => _rankCvs(job.jobTitle),
                    icon: _rankingCvs
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(_rankingCvs ? "Ranking..." : "Rank CV with AI", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _iconLabelledCard('assets/png/ic_briefcase_badge.png', "EMPLOYMENT TYPE", job.employmentTypeName)),
              const SizedBox(width: 12),
              Expanded(child: _iconLabelledCard('assets/png/ic_rupee_badge.png', "ANNUAL BUDGET", "₹${job.budget}")),
            ],
          ),
          const SizedBox(height: 12),
          _iconLabelledCard('assets/png/ic_building_badge.png', "HIRING ENTITY", job.orgName),
          const SizedBox(height: 12),
          _iconLabelledCard(
            'assets/png/ic_location_badge.png',
            "TARGET LOCATIONS",
            job.locationNames.isEmpty ? "-" : job.locationNames.join(", "),
          ),
          Dimensions.verticalSpace(context, 22),
          TlCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader('assets/png/ic_document_badge.png', "JOB DESCRIPTION & SCOPE"),
                const SizedBox(height: 10),
                Text(job.jobDescription, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
              ],
            ),
          ),
          Dimensions.verticalSpace(context, 16),
          if (job.requiredSkillsNames.isNotEmpty)
            TlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardHeader('assets/png/ic_sparkle_badge.png', "REQUIRED SKILLS & STACK"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final skill in job.requiredSkillsNames)
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
                ],
              ),
            ),
          Dimensions.verticalSpace(context, 22),
          _navCard(
            context,
            title: "Walk-in CV Pool",
            subtitleWidget: Text("Candidates available in the talent pool.", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            onTap: () => context.push(AppRoutes.tlWalkinCvPool, extra: _toTlJobModel(job)),
          ),
          Dimensions.verticalSpace(context, 22),
          _buildAppliedCandidatesSection(context),
          Dimensions.verticalSpace(context, 24),
        ],
      ),
    );
  }

  Widget _buildAppliedCandidatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text("Applied Candidates", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
            if (!_loadingCandidates)
              Text("${_candidates.length}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 12),
        TlSearchFilterBar(
          controller: _candidateSearchController,
          onChanged: (_) => setState(() {}),
          onFilterTap: () => showTlSnack(context, "Filters coming soon"),
        ),
        const SizedBox(height: 16),
        if (_loadingCandidates)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_candidatesError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 32),
                  const SizedBox(height: 10),
                  Text("Failed to load candidates.", style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadCandidates, child: const Text("Retry")),
                ],
              ),
            ),
          )
        else if (_filteredCandidates.isEmpty)
          const TlNoDataFound()
        else
          for (int i = 0; i < _filteredCandidates.length; i++) ...[
            _buildCandidateCard(context, _candidates.indexOf(_filteredCandidates[i])),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildCandidateCard(BuildContext context, int index) {
    final candidate = _candidates[index];
    final isReviewed = candidate.statusTags.contains('Done');

    return TlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: candidate.avatarColor,
                child: Text(candidate.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                      candidate.phone != null ? "${candidate.email} • ${candidate.phone}" : candidate.email,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in candidate.statusTags) TlStatusChip.forTag(tag)],
          ),
          const SizedBox(height: 12),
          if (isReviewed)
            Row(
              children: [
                Expanded(child: _candidateStatusDropdown(context, index, candidate)),
                const SizedBox(width: 10),
                _viewDetailsLink(context, candidate),
              ],
            )
          else
            Align(alignment: Alignment.centerRight, child: _viewDetailsLink(context, candidate)),
        ],
      ),
    );
  }

  Widget _candidateStatusDropdown(BuildContext context, int index, TlCandidateModel candidate) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: candidate.selectStatus,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: const ["Select Status", "In progress", "Selected", "Rejected", "On Hold"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) _updateCandidateStatus(index, value);
          },
        ),
      ),
    );
  }

  Widget _viewDetailsLink(BuildContext context, TlCandidateModel candidate) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.tlTimeline, extra: candidate),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("View Details", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF4F46E5)),
        ],
      ),
    );
  }

  TlJobModel _toTlJobModel(TlJobPostModel job) {
    return TlJobModel(
      id: job.id.toString(),
      reqId: "REQ-${job.id}",
      title: job.jobTitle,
      location: job.locationNames.isEmpty ? "-" : job.locationNames.first,
      experience: "${job.minYoe}-${job.maxYoe} Yrs",
      openings: job.numberOfVacancy,
      salary: "₹${job.budget}",
      employmentType: job.employmentTypeName,
      status: job.statusDisplay,
      company: job.orgName,
      locations: job.locationNames,
      description: job.jobDescription,
      skills: job.requiredSkillsNames,
      appliedCount: 0,
      walkInCount: 0,
    );
  }

  String _postedAgo(String createdAt) {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return "-";
    final diff = DateTime.now().difference(parsed);
    if (diff.inDays >= 1) return "Posted ${diff.inDays}d ago";
    if (diff.inHours >= 1) return "Posted ${diff.inHours}h ago";
    if (diff.inMinutes >= 1) return "Posted ${diff.inMinutes}m ago";
    return "Posted just now";
  }

  Widget _cardHeader(String iconAsset, String label) {
    return Row(
      children: [
        Image.asset(iconAsset, width: 30, height: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.3)),
        ),
      ],
    );
  }

  Widget _iconLabelledCard(String iconAsset, String label, String value) {
    return TlCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconAsset, width: 30, height: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.6)),
                const SizedBox(height: 8),
                Text(value.isEmpty ? "-" : value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCard(
    BuildContext context, {
    required String title,
    required Widget subtitleWidget,
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
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            subtitleWidget,
          ],
        ),
      ),
    );
  }
}
