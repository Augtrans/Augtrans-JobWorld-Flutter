import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/dimensions.dart';

/// "Applied Candidates" list for a job — reached from the Job Detail screen.
class TlAppliedCandidatesScreen extends StatefulWidget {
  final TlJobModel job;

  const TlAppliedCandidatesScreen({super.key, required this.job});

  @override
  State<TlAppliedCandidatesScreen> createState() => _TlAppliedCandidatesScreenState();
}

class _TlAppliedCandidatesScreenState extends State<TlAppliedCandidatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<TlCandidateModel> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = mockAppliedCandidates(widget.job.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateStatus(int index, String status) {
    setState(() => _candidates[index] = _candidates[index].copyWith(selectStatus: status));
    if (status == 'Rejected' || status == 'On Hold') {
      context.push(AppRoutes.tlAddRemark, extra: _candidates[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const TlHeaderBar(title: "Applied Candidates"),
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
              TlSearchFilterBar(controller: _searchController, onFilterTap: () => showTlSnack(context, "Filters coming soon")),
              Dimensions.verticalSpace(context, 16),
              for (int i = 0; i < _candidates.length; i++) ...[
                _buildCard(context, i),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
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
                Expanded(child: _statusDropdown(context, index, candidate)),
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

  Widget _statusDropdown(BuildContext context, int index, TlCandidateModel candidate) {
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
            if (value != null) _updateStatus(index, value);
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
}
