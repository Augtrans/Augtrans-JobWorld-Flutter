import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/practice/PracticeCategoryModel.dart';
import 'package:job_world/ui/home/PracticeViewModel.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);

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
        title: Text(
          "Practice",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Coding Practice",
                  style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                _buildViewAndMenuActions(context),
              ],
            ),
            Dimensions.verticalSpace(context, 10),
            Text(
              "Master the logic and syntax of modern development through curated challenges across 15+ specializations.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600, height: 1.5),
            ),
            Dimensions.verticalSpace(context, 25),
            TextField(
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
            Dimensions.verticalSpace(context, 30),
            practiceState.categories.when(
              data: (categories) {
                final filtered = categories.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  return c.categoryName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text("No coding categories found.", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    return _buildPracticeCardFromModel(context, category);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Text("Failed to load practice categories.", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.read(practiceViewModelProvider.notifier).fetchCategories(force: true),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCardFromModel(BuildContext context, PracticeCategoryModel category) {
    double progress = 0.0;
    if (category.totalCount > 0) {
      progress = (category.solvedCount / category.totalCount).clamp(0.0, 1.0);
    }
    bool isCompleted = progress == 1.0 && category.totalCount > 0;

    IconData icon = _getCategoryIcon(category.categoryName);
    Color accentColor = _getCategoryAccentColor(category.categoryName);
    String tag = category.totalCount > 0 ? "${category.solvedCount}/${category.totalCount} Solved" : "ALL LEVELS";

    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) - 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.level2Margin(context)),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFE8FDF0) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isCompleted ? Colors.green : accentColor, size: Dimensions.level2Margin(context) + 12),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.level2Margin(context),
                    vertical: Dimensions.level1Margin(context),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimensions.smallerTextSize(context),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 15),
          Text(
            category.categoryName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.largeTextSize(context) - 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Dimensions.verticalSpace(context, 4),
          Text(
            "${category.totalCount} Total Questions",
            style: TextStyle(
              fontSize: Dimensions.superSmallTextSize(context) + 1,
              color: Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          if (category.totalCount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: Dimensions.superSmallTextSize(context) + 1,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : const Color(0xFF6366F1),
                  ),
                ),
                if (isCompleted) Icon(Icons.check_circle, color: Colors.green, size: Dimensions.utilizationTextSize(context) + 2),
              ],
            ),
            Dimensions.verticalSpace(context, 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: Dimensions.level1Margin(context),
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : const Color(0xFF6366F1)),
              ),
            ),
            Dimensions.verticalSpace(context, 12),
          ],
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                context.push("${AppRoutes.practice}/${AppRoutes.languageDetail}", extra: category);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.white : const Color(0xFF6366F1),
                foregroundColor: isCompleted ? Colors.black : Colors.white,
                elevation: 0,
                side: isCompleted ? BorderSide(color: Colors.grey.shade300) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level3Margin(context) - 1,
                  vertical: 0,
                ),
                minimumSize: Size(0, Dimensions.level3Margin(context) + 14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCompleted ? "Review" : "Start",
                    style: TextStyle(
                      fontSize: Dimensions.navigationTitleSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isCompleted) ...[
                    Dimensions.horizontalSpace(context, 4),
                    Icon(Icons.arrow_outward_rounded, size: Dimensions.utilizationTextSize(context)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('data') || lower.contains('storage') || lower.contains('sql')) {
      return Icons.storage_rounded;
    } else if (lower.contains('ai') || lower.contains('intelligence') || lower.contains('ml')) {
      return Icons.psychology_rounded;
    } else if (lower.contains('algo') || lower.contains('logic')) {
      return Icons.terminal_rounded;
    }
    return Icons.code_rounded;
  }

  Color _getCategoryAccentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('data') || lower.contains('storage')) {
      return Colors.green;
    } else if (lower.contains('ai') || lower.contains('intelligence')) {
      return const Color(0xFF1E293B);
    } else if (lower.contains('algo')) {
      return const Color(0xFFD97706);
    }
    return const Color(0xFF6366F1);
  }

  Widget _buildViewAndMenuActions(BuildContext context) {
    final double iconSize = Dimensions.level2Margin(context) + 12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                icon: Icon(
                  Icons.grid_view_rounded,
                  size: iconSize,
                  color: const Color(0xFF6366F1),
                ),
                onPressed: () {},
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                icon: Icon(
                  Icons.list_rounded,
                  size: iconSize,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          onSelected: (value) {
            switch (value) {
              case 'Coding Round':
                break;
              case 'MCQ Round':
                context.push(AppRoutes.mcqChallenges);
                break;
              case 'AI Interview Round':
                context.push(AppRoutes.aiInterview);
                break;
            }
          },
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: const BoxConstraints(
            minWidth: 200,
          ),
          icon: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'Coding Round',
              child: Text(
                'Coding Round',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'MCQ Round',
              child: Text(
                'MCQ Round',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'AI Interview Round',
              child: Text(
                'AI Interview Round',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
