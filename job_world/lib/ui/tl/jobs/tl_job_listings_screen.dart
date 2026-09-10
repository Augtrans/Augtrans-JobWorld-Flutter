import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// Root screen for the TL bottom-nav "JOBS" tab.
/// Mirrors the "Job listings" screen: search + filters, active requisitions,
/// and per-job actions (View / Add / Copy link / Round management / Edit / Delete / Download JD).
class TlJobListingsScreen extends StatefulWidget {
  const TlJobListingsScreen({super.key});

  @override
  State<TlJobListingsScreen> createState() => _TlJobListingsScreenState();
}

class _TlJobListingsScreenState extends State<TlJobListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TlJobModel> get _filteredJobs {
    if (_query.trim().isEmpty) return mockTlJobs;
    final q = _query.toLowerCase();
    return mockTlJobs.where((j) => j.title.toLowerCase().contains(q) || j.location.toLowerCase().contains(q)).toList();
  }

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
                  onPressed: () => showTlSnack(context, "Post Job form coming soon"),
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
              Text(
                "${mockTlJobs.length} active postings across 6 departments",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
              for (final job in _filteredJobs) ...[
                _buildJobCard(context, job),
                const SizedBox(height: 14),
              ],
              Center(
                child: TextButton(
                  onPressed: () => showTlSnack(context, "Loading more jobs..."),
                  child: const Text("Load More Jobs", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ),
              ),
              Dimensions.verticalSpace(context, 20),
            ],
          ),
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

  Widget _buildJobCard(BuildContext context, TlJobModel job) {
    return TlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.primaryBlue),
                        const SizedBox(width: 6),
                        Text(job.reqId, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ],
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
              Text(job.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 16),
              Icon(Icons.work_outline_rounded, size: 15, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(job.experience, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(job.salary, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Text(job.employmentType, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              TlStatusChip.forTag(job.status),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.tlJobDetail, extra: job),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text("View", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => showTlSnack(context, "Add candidate flow coming soon"),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text("Add", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _jobPopupMenu(BuildContext context, TlJobModel job) {
    return TlPopupMenuButton(items: [
      TlPopupItem(
        label: "Copy Share Link",
        icon: Icons.link_rounded,
        color: const Color(0xFFD97706),
        onTap: () => showTlSnack(context, "Share link copied for ${job.title}"),
      ),
      TlPopupItem(
        label: "Round Management",
        icon: Icons.account_tree_outlined,
        onTap: () => showTlSnack(context, "Round management coming soon"),
      ),
      TlPopupItem(
        label: "Edit",
        icon: Icons.edit_outlined,
        onTap: () => showTlSnack(context, "Edit ${job.title} coming soon"),
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
        onTap: () => showTlSnack(context, "Downloading JD for ${job.title}..."),
      ),
    ]);
  }

  void _confirmDelete(BuildContext context, TlJobModel job) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete job?"),
        content: Text("This will remove \"${job.title}\" from your active requisitions."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              showTlSnack(context, "${job.title} deleted");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
