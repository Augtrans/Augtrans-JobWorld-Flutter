import 'package:flutter/material.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// Shared building blocks reused across the TL job/candidate flow screens
/// so every screen matches the same header, search bar and card language.

/// Back-button + centered title header used on every pushed TL screen
/// (Walk-in CV Pool, Applied Candidates, Add/Update Remark, Timeline, ...).
class TlHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const TlHeaderBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.level3Margin(context),
          vertical: Dimensions.level2Margin(context),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF0F172A)),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                if (actions != null) ...actions! else const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}

/// Search field + filter icon button, used on the listing-style TL screens.
class TlSearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const TlSearchFilterBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: "Search ...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

/// Small rounded status pill (Done / Approved / Pending / In Review / Open / Closed ...).
class TlStatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const TlStatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  factory TlStatusChip.forTag(String tag) {
    switch (tag) {
      case 'Done':
        return const TlStatusChip(
          label: 'Done',
          background: Color(0xFF22C55E),
          foreground: Colors.white,
          icon: Icons.check_circle_rounded,
        );
      case 'Approved':
        return const TlStatusChip(label: 'Approved', background: Color(0xFFEEF2FF), foreground: Color(0xFF4F46E5));
      case 'Pending':
        return const TlStatusChip(label: 'Pending', background: Color(0xFFFEF3C7), foreground: Color(0xFFD97706));
      case 'In Review':
        return const TlStatusChip(label: 'In Review', background: Color(0xFFDBEAFE), foreground: Color(0xFF2563EB));
      case 'Open':
        return const TlStatusChip(label: 'Open', background: Color(0xFFDCFCE7), foreground: Color(0xFF16A34A));
      case 'Closed':
        return const TlStatusChip(label: 'Closed', background: Color(0xFFFEF3C7), foreground: Color(0xFFD97706));
      default:
        return TlStatusChip(label: tag, background: const Color(0xFFF1F5F9), foreground: Colors.grey.shade600);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground)),
        ],
      ),
    );
  }
}

/// Generic three-dot popup menu used on job cards / candidate cards.
class TlPopupItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const TlPopupItem({
    required this.label,
    required this.icon,
    this.color = const Color(0xFF4F46E5),
    required this.onTap,
  });
}

class TlPopupMenuButton extends StatelessWidget {
  final List<TlPopupItem> items;

  const TlPopupMenuButton({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        for (int i = 0; i < items.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Icon(items[i].icon, size: 18, color: items[i].color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items[i].label,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: items[i].color),
                  ),
                ),
              ],
            ),
          ),
      ],
      onSelected: (index) => items[index].onTap(),
    );
  }
}

/// A single, reusable info card container used across job/candidate detail screens.
class TlCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const TlCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Shown wherever a list has no data and there is no mock fallback to fall
/// back on — e.g. a candidate list before the API is wired up, or an empty
/// API response.
class TlNoDataFound extends StatelessWidget {
  final String message;

  const TlNoDataFound({super.key, this.message = "No data found"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Full-page fallback for a route that needed data (e.g. a job passed via
/// `extra`) that was never supplied — shows "No data found" instead of
/// falling back to a fabricated placeholder.
class TlNoDataScreen extends StatelessWidget {
  const TlNoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const TlHeaderBar(title: ""),
      body: const SafeArea(top: false, child: TlNoDataFound()),
    );
  }
}

void showTlSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF0F172A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}
