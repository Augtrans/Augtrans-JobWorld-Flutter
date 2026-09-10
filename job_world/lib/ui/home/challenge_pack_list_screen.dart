import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/challenge_pack/ChallengePackTypeModel.dart';
import 'package:job_world/ui/home/ChallengePackViewModel.dart';
import 'package:job_world/ui/home/challenge_pack_nav_args.dart';

class _PackListItem {
  final String sourceType;
  final PackDomainModel domain;

  _PackListItem({required this.sourceType, required this.domain});
}

class ChallengePackListScreen extends ConsumerStatefulWidget {
  const ChallengePackListScreen({super.key});

  @override
  ConsumerState<ChallengePackListScreen> createState() => _ChallengePackListScreenState();
}

class _ChallengePackListScreenState extends ConsumerState<ChallengePackListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packState = ref.watch(challengePackViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: Dimensions.level2Margin(context) + 12),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimensions.verticalSpace(context, 10),
            Text(
              "Elevate Your Skills with\nChallenge Packs",
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 4, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), height: 1.25),
            ),
            Dimensions.verticalSpace(context, 10),
            Text(
              "Complete curated sets of tasks designed to accelerate your career growth, earn prestigious badges, and climb the leaderboard.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600, height: 1.5),
            ),
            Dimensions.verticalSpace(context, 25),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search topics...",
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
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: Dimensions.level3Margin(context) - 1),
                    ),
                  ),
                ),
                Dimensions.horizontalSpace(context, 12),
                Container(
                  padding: EdgeInsets.all(Dimensions.level3Margin(context) - 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tune_rounded, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
                ),
              ],
            ),
            Dimensions.verticalSpace(context, 20),
            Text(
              "Featured Packs",
              style: TextStyle(fontSize: Dimensions.smallTextSize(context) + 1, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            Dimensions.verticalSpace(context, 12),
            _buildFilterChips(context),
            Dimensions.verticalSpace(context, 20),
            packState.packTypes.when(
              data: (packTypes) => _buildPackList(context, packTypes),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Text("Failed to load challenge packs.", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.read(challengePackViewModelProvider.notifier).fetchPackTypes(force: true),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Dimensions.verticalSpace(context, 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ["All", "MCQ", "Coding"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter == "All" ? "All Packs" : filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              selectedColor: AppColors.primaryBlue,
              backgroundColor: const Color(0xFFF1F5F9),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.utilizationTextSize(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.transparent),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackList(BuildContext context, List<ChallengePackTypeModel> packTypes) {
    final List<_PackListItem> items = [];
    for (final type in packTypes) {
      if (_selectedFilter == "MCQ" && !type.isMcq) continue;
      if (_selectedFilter == "Coding" && type.isMcq) continue;
      for (final domain in type.items) {
        if (_searchQuery.isNotEmpty && !domain.name.toLowerCase().contains(_searchQuery)) continue;
        items.add(_PackListItem(sourceType: type.sourceType, domain: domain));
      }
    }

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text("No challenge packs found.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Dimensions.verticalSpace(context, 16),
      itemBuilder: (context, index) => _buildPackCard(context, items[index]),
    );
  }

  Widget _buildPackCard(BuildContext context, _PackListItem item) {
    final bool isMcq = item.sourceType.toUpperCase() == 'MCQ';
    final Color accent = isMcq ? AppColors.primaryBlue : const Color(0xFF16A34A);
    final IconData icon = isMcq ? Icons.checklist_rtl_rounded : Icons.integration_instructions_rounded;
    final String badge = isMcq ? "MCQ" : "CODING";
    final String subtitle = isMcq
        ? "Test your knowledge with curated MCQ challenges."
        : "Sharpen your coding skills with hands-on problems.";

    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context) + 4),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: accent, size: Dimensions.level3Margin(context) + 6),
          ),
          Dimensions.horizontalSpace(context, 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.domain.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(badge, style: TextStyle(color: accent, fontSize: Dimensions.smallerTextSize(context) + 1, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Dimensions.verticalSpace(context, 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Dimensions.verticalSpace(context, 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        AppRoutes.challengePackTopics,
                        extra: ChallengePackTopicArgs(sourceType: item.sourceType, id: item.domain.id, name: item.domain.name),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: Dimensions.level2Margin(context) + 2),
                    ),
                    child: Text("Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
