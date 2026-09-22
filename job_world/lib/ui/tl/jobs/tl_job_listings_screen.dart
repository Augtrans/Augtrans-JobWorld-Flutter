import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/core/networking/api_exception.dart';
import 'package:job_world/data/model/jobpost/TlJobPostModel.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/ui/tl/jobs/TlJobsViewModel.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

class TlJobListingsScreen extends ConsumerStatefulWidget {
  const TlJobListingsScreen({super.key});

  @override
  ConsumerState<TlJobListingsScreen> createState() => _TlJobListingsScreenState();
}

class _TlJobListingsScreenState extends ConsumerState<TlJobListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TlJobPostModel> _filtered(List<TlJobPostModel> jobs) {
    if (_query.trim().isEmpty) return jobs;
    final q = _query.toLowerCase();
    return jobs.where((j) {
      final loc = j.locationNames.join(", ").toLowerCase();
      return j.jobTitle.toLowerCase().contains(q) || loc.contains(q);
    }).toList();
  }

  Future<void> _openPostJob({TlJobPostModel? existingJob}) async {
    final result = await context.push(AppRoutes.tlPostJob, extra: existingJob);
    if (result == true) {
      ref.invalidate(tlJobsViewModelProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(tlJobsViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(tlJobsViewModelProvider.notifier).fetchPostedJobs(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.level3Margin(context) + 2,
              vertical: Dimensions.level3Margin(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Dimensions.verticalSpace(context, 20),
                const Text("Job listings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text("Here's your recruitment overview for posted jobs", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                Dimensions.verticalSpace(context, 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPostJob(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("Post Job", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                Dimensions.verticalSpace(context, 24),
                const Text("Active Requisitions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                jobsAsync.when(
                  loading: () => Text("Loading...", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  error: (e, st) => Text("Failed to load jobs", style: TextStyle(fontSize: 12, color: Colors.red.shade400)),
                  data: (jobs) {
                    final deptCount = jobs.map((j) => j.departmentName).where((d) => d.isNotEmpty).toSet().length;
                    return Text(
                      "${jobs.length} active postings across $deptCount department${deptCount == 1 ? '' : 's'}",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    );
                  },
                ),
                Dimensions.verticalSpace(context, 14),
                TlSearchFilterBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  onFilterTap: () => showTlSnack(context, "Filters coming soon"),
                ),
                Dimensions.verticalSpace(context, 14),
                Row(
                  children: [
                    _filterPill(context, "Department"),
                    const SizedBox(width: 10),
                    _filterPill(context, "Status"),
                    const SizedBox(width: 10),
                    _filterPill(context, "Sort: Newest"),
                  ],
                ),
                Dimensions.verticalSpace(context, 18),
                jobsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => _buildErrorState(context),
                  data: (jobs) {
                    final filtered = _filtered(jobs);
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text("No jobs found.", style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (int i = 0; i < filtered.length; i++) ...[
                          _buildJobCard(context, filtered[i], i + 1),
                          const SizedBox(height: 14),
                        ],
                      ],
                    );
                  },
                ),
                Dimensions.verticalSpace(context, 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 36),
            const SizedBox(height: 10),
            Text("Failed to load jobs.", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(tlJobsViewModelProvider),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(BuildContext context, String label) {
    return GestureDetector(
      onTap: () => showTlSnack(context, "$label filter coming soon"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFEEF2FF),
          child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WELCOME, BACK!",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            const SizedBox(height: 2),
            const Text("Akshay Khandekar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF334155), size: 22),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, TlJobPostModel job, int number) {
    final location = job.locationNames.isEmpty ? "-" : job.locationNames.join(", ");
    return TlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(top: 1, right: 10),
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text("$number", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.jobTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                      job.departmentName.isEmpty ? "REQ-${job.id}" : job.departmentName,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              _jobPopupMenu(context, job),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              const SizedBox(width: 16),
              Icon(Icons.work_outline_rounded, size: 15, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text("${job.minYoe}-${job.maxYoe} Yrs", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("₹${job.budget}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Text(job.employmentTypeName, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TlStatusChip.forTag(job.statusDisplay),
              _statusDropdown(context, job),
              _approvalHistoryButton(context, job),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.tlJobDetail, extra: job.id),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text("View", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: Color(0xFFC7D2FE)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddRemarkDialog(context, job),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text("Add", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Status codes per PATCH .../post-jobs/{id}/update-status/: "1" Open,
  // "2" Closed, "3" On Hold.
  static const Map<String, String> _jobLifecycleCodes = {"1": "Open", "2": "Closed", "3": "On Hold"};

  Color _lifecycleColor(String label) {
    switch (label) {
      case "Open":
        return AppColors.primaryBlue;
      case "On Hold":
        return const Color(0xFFD97706);
      case "Closed":
        return const Color(0xFFDC2626);
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _statusDropdown(BuildContext context, TlJobPostModel job) {
    final currentCode = _jobLifecycleCodes.containsKey(job.status) ? job.status : "1";
    final currentLabel = _jobLifecycleCodes[currentCode]!;
    final color = _lifecycleColor(currentLabel);
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (code) => _updateJobLifecycle(context, job, code),
      itemBuilder: (context) => [
        for (final entry in _jobLifecycleCodes.entries)
          PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: _lifecycleColor(entry.value)),
                const SizedBox(width: 10),
                Text(entry.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _lifecycleColor(entry.value))),
                if (entry.key == currentCode) ...[const Spacer(), Icon(Icons.check_rounded, size: 16, color: _lifecycleColor(entry.value))],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _updateJobLifecycle(BuildContext context, TlJobPostModel job, String statusCode) async {
    if (statusCode == job.status) return;
    try {
      await ref.read(tlJobRepositoryProvider).updateJobStatus(job.id, statusCode);
      ref.invalidate(tlJobsViewModelProvider);
      if (!context.mounted) return;
      showTlSnack(context, "${job.jobTitle} marked as ${_jobLifecycleCodes[statusCode]}");
    } catch (e) {
      if (!context.mounted) return;
      showTlSnack(context, _statusUpdateErrorMessage(e));
    }
  }

  String _statusUpdateErrorMessage(Object error) {
    if (error is ApiException) {
      final data = error.data;
      if (data is Map) {
        for (final key in ['detail', 'message', 'error', 'status']) {
          final value = data[key];
          if (value is String && value.isNotEmpty) return value;
          if (value is List && value.isNotEmpty) return value.first.toString();
        }
      }
    }
    return "Failed to update status";
  }

  Widget _approvalHistoryButton(BuildContext context, TlJobPostModel job) {
    return GestureDetector(
      onTap: () => _showApprovalHistory(context, job),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
        child: const Icon(Icons.history_rounded, size: 16, color: Color(0xFF64748B)),
      ),
    );
  }

  Future<void> _showApprovalHistory(BuildContext context, TlJobPostModel job) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ApprovalHistorySheet(
        jobTitle: job.jobTitle,
        future: ref.read(tlJobRepositoryProvider).getJobApprovalHistory(job.id),
      ),
    );
  }

  Future<void> _showAddRemarkDialog(BuildContext context, TlJobPostModel job) async {
    final controller = TextEditingController(text: job.remark);
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> save() async {
            final remark = controller.text.trim();
            if (remark.isEmpty) {
              showTlSnack(dialogContext, "Please write a remark before saving");
              return;
            }
            setDialogState(() => saving = true);
            try {
              await ref.read(tlJobRepositoryProvider).updateJobRemark(job.id, remark);
              ref.invalidate(tlJobsViewModelProvider);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              showTlSnack(context, "Remark saved for ${job.jobTitle}");
            } catch (e) {
              setDialogState(() => saving = false);
              if (!dialogContext.mounted) return;
              showTlSnack(dialogContext, _remarkErrorMessage(e));
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add/Update remark", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(job.jobTitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  const Text("REMARK", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.6)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
                    child: TextField(
                      controller: controller,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write your remark here...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: saving ? null : () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF334155),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: saving ? null : save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: saving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _remarkErrorMessage(Object error) {
    if (error is ApiException) {
      final data = error.data;
      if (data is Map) {
        for (final key in ['error', 'detail', 'message']) {
          final value = data[key];
          if (value is String && value.isNotEmpty) return value;
        }
        final remarkErrors = data['remark'];
        if (remarkErrors is List && remarkErrors.isNotEmpty) return "Remark: ${remarkErrors.first}";
      }
      return error.message;
    }
    return "Failed to save remark. Please try again.";
  }

  Widget _jobPopupMenu(BuildContext context, TlJobPostModel job) {
    return TlPopupMenuButton(items: [
      TlPopupItem(
        label: "Copy Share Link",
        icon: Icons.link_rounded,
        color: const Color(0xFFD97706),
        onTap: () => showTlSnack(context, "Share link copied for ${job.jobTitle}"),
      ),
      TlPopupItem(
        label: "Round Management",
        icon: Icons.account_tree_outlined,
        onTap: () => showTlSnack(context, "Round management coming soon"),
      ),
      TlPopupItem(
        label: "Edit",
        icon: Icons.edit_outlined,
        onTap: () => _openPostJob(existingJob: job),
      ),
      TlPopupItem(
        label: "Delete",
        icon: Icons.delete_outline_rounded,
        color: const Color(0xFFDC2626),
        onTap: () => _confirmDelete(context, job),
      ),
      TlPopupItem(
        label: "Download JD",
        icon: Icons.download_outlined,
        color: const Color(0xFF16A34A),
        onTap: () => showTlSnack(context, "Downloading JD for ${job.jobTitle}..."),
      ),
    ]);
  }

  void _confirmDelete(BuildContext context, TlJobPostModel job) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete job?"),
        content: Text("This will remove \"${job.jobTitle}\" from your active requisitions."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              showTlSnack(context, "${job.jobTitle} deleted");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing a job post's approval workflow, from
/// GET /jobpost/jobs/{id}/approval-history/.
class _ApprovalHistorySheet extends StatelessWidget {
  final String jobTitle;
  final Future<TlJobApprovalHistoryModel> future;

  const _ApprovalHistorySheet({required this.jobTitle, required this.future});

  String _eventLabel(String event) {
    return event
        .split('_')
        .map((w) => w.isEmpty ? w : "${w[0]}${w.substring(1).toLowerCase()}")
        .join(' ');
  }

  String _formatTime(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final local = parsed.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return "${local.day}/${local.month}/${local.year} · $hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Approval Timeline", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(jobTitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<TlJobApprovalHistoryModel>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            "Failed to load approval history.\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                      );
                    }
                    final data = snapshot.data!;
                    if (data.history.isEmpty) {
                      return const TlNoDataFound();
                    }
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Text("Current Stage", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              TlStatusChip.forTag(_eventLabel(data.currentStage)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        for (int i = 0; i < data.history.length; i++) _buildEntry(context, data.history, i),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntry(BuildContext context, List<TlJobApprovalHistoryEntry> entries, int index) {
    final entry = entries[index];
    final isLast = index == entries.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: isLast ? const Color(0xFF16A34A) : AppColors.primaryBlue, shape: BoxShape.circle),
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
                  border: isLast ? Border.all(color: const Color(0xFF86EFAC)) : null,
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
                              Text(_eventLabel(entry.event), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: entry.by, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                    const TextSpan(text: " · ", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    TextSpan(
                                      text: entry.byRole,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLast ? const Color(0xFF16A34A) : AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_formatTime(entry.time), style: TextStyle(fontSize: 11, color: isLast ? const Color(0xFF16A34A) : Colors.grey.shade500)),
                    if (entry.from.isNotEmpty && entry.from != "-") ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                            child: Text("${entry.from} → ${entry.to}",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                          ),
                          if (entry.departmentName != null && entry.departmentName!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                              child: Text(entry.departmentName!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            ),
                        ],
                      ),
                    ],
                    if (entry.comment != null && entry.comment!.isNotEmpty && entry.comment != "NA") ...[
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
                              child: Text('"${entry.comment}"',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primaryBlue, height: 1.4)),
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
