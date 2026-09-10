import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/practice/PracticeCategoryModel.dart';
import 'package:job_world/data/model/practice/PracticeSubcategoryModel.dart';
import 'package:job_world/ui/home/PracticeViewModel.dart';

class LanguageDetailScreen extends ConsumerStatefulWidget {
  final String languageName;
  final int? categoryId;
  final PracticeCategoryModel? category;

  const LanguageDetailScreen({
    super.key,
    required this.languageName,
    this.categoryId,
    this.category,
  });

  @override
  ConsumerState<LanguageDetailScreen> createState() => _LanguageDetailScreenState();
}

class _LanguageDetailScreenState extends ConsumerState<LanguageDetailScreen> {
  int get _resolvedCategoryId {
    if (widget.category != null && widget.category!.id > 0) {
      return widget.category!.id;
    }
    if (widget.categoryId != null && widget.categoryId! > 0) {
      return widget.categoryId!;
    }
    return 1; // Default category ID
  }

  String get _resolvedCategoryName {
    if (widget.category != null && widget.category!.categoryName.isNotEmpty) {
      return widget.category!.categoryName;
    }
    if (widget.languageName.isNotEmpty) {
      return widget.languageName;
    }
    return "Category Details";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(practiceViewModelProvider.notifier).fetchSubcategories(_resolvedCategoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final subcatAsync = practiceState.subcategories[_resolvedCategoryId] ?? const AsyncValue.loading();

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
          _resolvedCategoryName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimensions.verticalSpace(context, 20),
            Text(
              _resolvedCategoryName,
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 6, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 8),
            Text(
              "Master systems programming, core logic, and foundational topics.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600),
            ),
            Dimensions.verticalSpace(context, 25),

            subcatAsync.when(
              data: (subcategories) {
                int totalSubcats = subcategories.length;
                int solvedCount = subcategories.where((s) => s.solved).length;
                double progress = totalSubcats > 0 ? (solvedCount / totalSubcats).clamp(0.0, 1.0) : 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Path Progress Card
                    Container(
                      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subcategory Progress",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1, color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                          Dimensions.verticalSpace(context, 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: Dimensions.level2Margin(context),
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Dimensions.verticalSpace(context, 20),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.check_circle_rounded,
                            value: "$solvedCount",
                            label: "Completed",
                            iconColor: Colors.green,
                            bgColor: const Color(0xFFF0FDF4),
                          ),
                        ),
                        Dimensions.horizontalSpace(context, 16),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.hourglass_bottom_rounded,
                            value: "${totalSubcats - solvedCount}",
                            label: "Remaining",
                            iconColor: Colors.orange,
                            bgColor: const Color(0xFFFFF7ED),
                          ),
                        ),
                      ],
                    ),
                    Dimensions.verticalSpace(context, 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Subcategories",
                              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                            ),
                            Dimensions.horizontalSpace(context, 10),
                            Text(
                              "$totalSubcats Total",
                              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => ref.read(practiceViewModelProvider.notifier).fetchSubcategories(_resolvedCategoryId, force: true),
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                        ),
                      ],
                    ),
                    Dimensions.verticalSpace(context, 15),

                    if (subcategories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "No subcategories available for this category.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subcategories.length,
                        separatorBuilder: (context, index) => Dimensions.verticalSpace(context, 16),
                        itemBuilder: (context, index) {
                          final subcat = subcategories[index];
                          return _buildSubcategoryCard(context, subcat);
                        },
                      ),
                  ],
                );
              },
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
                      const Text("Failed to load subcategories.", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.read(practiceViewModelProvider.notifier).fetchSubcategories(_resolvedCategoryId, force: true),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Dimensions.verticalSpace(context, 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context)),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: Dimensions.level2Margin(context) + 12),
          ),
          Dimensions.verticalSpace(context, 12),
          Text(
            value,
            style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          Text(
            label,
            style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(BuildContext context, PracticeSubcategoryModel subcat) {

    Color accentColor = subcat.solved ? Colors.green : (subcat.easyCount > 0 ? AppColors.primaryBlue : Colors.orange);
    String statusText = subcat.solved ? "COMPLETED" : "START";
    Color statusColor = subcat.solved ? Colors.green : AppColors.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: Dimensions.level0Padding(context) * 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.code, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
                        ),
                        Dimensions.horizontalSpace(context, 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      subcat.subcategoryName,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Dimensions.horizontalSpace(context, 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.level1Margin(context) + 2,
                                      vertical: Dimensions.level0Padding(context),
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: Dimensions.superSmallTextSize(context) - 1,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Dimensions.verticalSpace(context, 4),
                              Text(
                                subcat.summary.isNotEmpty
                                    ? subcat.summary
                                    : "${subcat.totalQuestions} Questions • ${subcat.easyCount} Easy • ${subcat.mediumCount} Medium • ${subcat.hardCount} Hard",
                                style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Dimensions.verticalSpace(context, 16),
                    Row(
                      children: [
                        _buildChallengeInfo(context, Icons.list_alt_rounded, "${subcat.totalQuestions} Questions"),
                        Dimensions.horizontalSpace(context, 12),
                        _buildChallengeInfo(context, Icons.circle, "${subcat.easyCount} Easy", Colors.green),
                        Dimensions.horizontalSpace(context, 8),
                        _buildChallengeInfo(context, Icons.circle, "${subcat.mediumCount} Medium", Colors.orange),
                        Dimensions.horizontalSpace(context, 8),
                        _buildChallengeInfo(context, Icons.circle, "${subcat.hardCount} Hard", Colors.red),
                      ],
                    ),
                    Dimensions.verticalSpace(context, 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Score: ${subcat.score}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2),
                            ),
                            Text(
                              subcat.solved ? "Completed" : "In Progress",
                              style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.push("${AppRoutes.practice}/${AppRoutes.languageDetail}/${AppRoutes.questionList}", extra: subcat);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: subcat.solved ? Colors.white : AppColors.primaryBlue,
                            foregroundColor: subcat.solved ? Colors.black : Colors.white,
                            elevation: 0,
                            side: subcat.solved ? BorderSide(color: Colors.grey.shade300) : null,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
                          ),
                          child: Text(
                            subcat.solved ? "Review" : "Start",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeInfo(BuildContext context, IconData icon, String label, [Color? iconColor]) {
    return Row(
      children: [
        Icon(icon, size: 12, color: iconColor ?? Colors.grey.shade400),
        Dimensions.horizontalSpace(context, 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}