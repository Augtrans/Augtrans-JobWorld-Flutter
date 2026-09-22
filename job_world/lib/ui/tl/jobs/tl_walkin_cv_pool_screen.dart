import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/dimensions.dart';

/// "Walk-in CV Pool" — reached from the Job Detail screen.
/// Same candidate-card language as Applied Candidates, plus a score,
/// an approve/reject action and a richer per-candidate action menu.
class TlWalkinCvPoolScreen extends StatefulWidget {
  final TlJobModel job;

  const TlWalkinCvPoolScreen({super.key, required this.job});

  @override
  State<TlWalkinCvPoolScreen> createState() => _TlWalkinCvPoolScreenState();
}

class _TlWalkinCvPoolScreenState extends State<TlWalkinCvPoolScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<TlCandidateModel> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateStatus(int index, String status) {
    setState(() => _candidates[index] = _candidates[index].copyWith(selectStatus: status));
  }

  void _approve(int index) {
    setState(() => _candidates[index] = _candidates[index].copyWith(selectStatus: 'Selected'));
    showTlSnack(context, "${_candidates[index].name} approved");
  }

  void _reject(int index) {
    context.push(AppRoutes.tlAddRemark, extra: _candidates[index]);
  }

  Future<void> _scheduleInterview(TlCandidateModel candidate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 11, minute: 0));
    if (time == null || !mounted) return;
    showTlSnack(context, "Interview scheduled for ${candidate.name} on ${date.day}/${date.month} at ${time.format(context)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const TlHeaderBar(title: "Walkin-in CV Pool"),
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
              if (_candidates.isEmpty)
                const TlNoDataFound()
              else
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
              _candidatePopupMenu(context, candidate),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in candidate.statusTags) TlStatusChip.forTag(tag)],
          ),
          if (candidate.score != null) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SCORE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.6)),
                      const SizedBox(height: 2),
                      Text("${candidate.score!.toStringAsFixed(2)}%",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                _viewDetailsLink(context, candidate),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _statusDropdown(context, index, candidate)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("APPROVAL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.6)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _approvalButton(icon: Icons.check_rounded, color: const Color(0xFF16A34A), bg: const Color(0xFFDCFCE7), onTap: () => _approve(index)),
                      const SizedBox(width: 8),
                      _approvalButton(icon: Icons.close_rounded, color: const Color(0xFFDC2626), bg: const Color(0xFFFEE2E2), onTap: () => _reject(index)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _approvalButton({required IconData icon, required Color color, required Color bg, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
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

  Widget _candidatePopupMenu(BuildContext context, TlCandidateModel candidate) {
    return TlPopupMenuButton(items: [
      TlPopupItem(
        label: "View Resume",
        icon: Icons.visibility_outlined,
        onTap: () => showTlSnack(context, "Opening ${candidate.name}'s resume..."),
      ),
      TlPopupItem(
        label: "View Email Logs & Timeline",
        icon: Icons.account_tree_outlined,
        color: const Color(0xFF7C3AED),
        onTap: () => context.push(AppRoutes.tlTimeline, extra: candidate),
      ),
      TlPopupItem(
        label: "Schedule Manual Interview",
        icon: Icons.calendar_today_outlined,
        onTap: () => _scheduleInterview(candidate),
      ),
      TlPopupItem(
        label: "View hiring report",
        icon: Icons.history_rounded,
        color: const Color(0xFFD97706),
        onTap: () => context.push(AppRoutes.tlHiringReport, extra: candidate),
      ),
      TlPopupItem(
        label: "Download JD",
        icon: Icons.download_outlined,
        color: const Color(0xFF16A34A),
        onTap: () => showTlSnack(context, "Downloading JD for ${widget.job.title}..."),
      ),
    ]);
  }
}
