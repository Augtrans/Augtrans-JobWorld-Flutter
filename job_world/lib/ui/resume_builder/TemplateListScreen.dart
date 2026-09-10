import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/ui/resume_builder/TemplateViewModel.dart';
import 'package:job_world/data/model/profile/ResumeTemplateModel.dart';

class TemplateListScreen extends ConsumerStatefulWidget {
  const TemplateListScreen({super.key});

  @override
  ConsumerState<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends ConsumerState<TemplateListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateState = ref.watch(templateViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: Dimensions.level2Margin(context) + 16),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Trending Templates",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.level3Margin(context) + 4,
              vertical: Dimensions.level2Margin(context) + 2,
            ),
            child: Text(
              "Choose Your Style",
              style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 1, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          _buildSearchBar(context),
          Expanded(
            child: templateState.templates.when(
              data: (templates) {
                final filtered = templates.where((t) {
                  if (_searchQuery.isEmpty) return true;
                  return t.templateName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No templates available."));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final template = filtered[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.level3Margin(context) + 4),
                      child: _buildTemplateItem(context, template),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Failed to load templates"),
                    TextButton(
                      onPressed: () => ref.read(templateViewModelProvider.notifier).fetchTemplates(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomButton(context, templateState),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.level3Margin(context) + 4,
        vertical: Dimensions.level2Margin(context) + 2,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search templates...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: Dimensions.utilizationTextSize(context) + 2),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: Dimensions.level3Margin(context) - 4),
        ),
      ),
    );
  }

  Widget _buildTemplateItem(BuildContext context, ResumeTemplateModel template) {
    final selectedId = ref.watch(templateViewModelProvider.select((s) => s.selectedTemplateId));
    bool isSelected = selectedId == template.id;

    return GestureDetector(
      onTap: () => ref.read(templateViewModelProvider.notifier).selectTemplate(template.id),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100, width: isSelected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                _buildTemplateThumbnail(context, template),
                if (isSelected)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.level2Margin(context) + 2,
                        vertical: Dimensions.level1Margin(context),
                      ),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: Dimensions.utilizationTextSize(context) + 2),
                          Dimensions.horizontalSpace(context, 4),
                          Text(
                            "Selected",
                            style: TextStyle(color: Colors.white, fontSize: Dimensions.superSmallTextSize(context) + 1, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(Dimensions.level3Margin(context) - 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.templateName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Dimensions.verticalSpace(context, 2),
                        Text(
                          "Created: ${template.createdAt?.substring(0, 10) ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: Dimensions.utilizationTextSize(context)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.level3Margin(context) - 4,
                      vertical: Dimensions.level1Margin(context) + 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "FREE",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: Dimensions.superSmallTextSize(context) + 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateThumbnail(BuildContext context, ResumeTemplateModel template) {
    final name = template.templateName.toLowerCase();

    // 1. Modern Sidebar (2-Column preview with dark left bar)
    if (name.contains("sidebar") || name.contains("modern") || template.id % 4 == 2) {
      return Container(
        height: 140,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 20, height: 4, color: const Color(0xFF60A5FA)),
                  const SizedBox(height: 8),
                  Container(width: 30, height: 3, color: Colors.white24),
                  const SizedBox(height: 4),
                  Container(width: 25, height: 3, color: Colors.white24),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 8, color: const Color(0xFF0F172A)),
                  const SizedBox(height: 4),
                  Container(width: 50, height: 5, color: const Color(0xFF2563EB)),
                  const SizedBox(height: 12),
                  Container(width: double.infinity, height: 3, color: Colors.grey.shade300),
                  const SizedBox(height: 4),
                  Container(width: 100, height: 3, color: Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Creative Designer (Purple gradient top card preview)
    if (name.contains("creative") || name.contains("designer") || template.id % 4 == 3) {
      return Container(
        height: 140,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF5FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 70, height: 6, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(width: 40, height: 4, color: Colors.white70),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: Color(0xFF7C3AED), width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 50, height: 4, color: const Color(0xFF4C1D95)),
                  const SizedBox(height: 4),
                  Container(width: 100, height: 3, color: Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. Minimal Tech (Monospace bracketed layout preview)
    if (name.contains("minimal") || name.contains("tech") || template.id % 4 == 0) {
      return Container(
        height: 140,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 1))),
              child: Row(
                children: [
                  const Text("[Developer Name]", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: "monospace")),
                  const Spacer(),
                  Container(width: 30, height: 4, color: Colors.grey.shade400),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              color: const Color(0xFFF1F5F9),
              child: Container(width: 60, height: 4, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Container(width: 110, height: 3, color: Colors.grey.shade300),
          ],
        ),
      );
    }

    // 4. Default: Classic Professional (Centered header preview)
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Container(width: 90, height: 8, color: const Color(0xFF0F172A)),
                const SizedBox(height: 4),
                Container(width: 50, height: 4, color: const Color(0xFF2563EB)),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 1, color: const Color(0xFF2563EB)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(width: 70, height: 4, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Container(width: double.infinity, height: 3, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, TemplateState state) {
    final selectedId = state.selectedTemplateId;
    final isEnabled = selectedId != null;

    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: Dimensions.level1Size(context) + 5,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  final selectedTemplate = state.templates.valueOrNull?.firstWhere((t) => t.id == selectedId);
                  context.push(AppRoutes.resumePreview, extra: selectedTemplate);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(
            "Continue with template",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
          ),
        ),
      ),
    );
  }
}
