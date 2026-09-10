import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/practice/PracticeSubcategoryModel.dart';
import 'package:job_world/data/model/practice/PracticeQuestionModel.dart';
import 'package:job_world/ui/home/PracticeViewModel.dart';

class QuestionListScreen extends ConsumerStatefulWidget {
  final int? subCategoryId;
  final String? title;
  final PracticeSubcategoryModel? subcategory;

  const QuestionListScreen({
    super.key,
    this.subCategoryId,
    this.title,
    this.subcategory,
  });

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  int get _resolvedSubCategoryId {
    if (widget.subcategory != null && widget.subcategory!.id > 0) {
      return widget.subcategory!.id;
    }
    if (widget.subCategoryId != null && widget.subCategoryId! > 0) {
      return widget.subCategoryId!;
    }
    return 8; // Default subcategory ID
  }

  String get _resolvedTitle {
    if (widget.subcategory != null && widget.subcategory!.subcategoryName.isNotEmpty) {
      return widget.subcategory!.subcategoryName;
    }
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    return "Question List";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(practiceViewModelProvider.notifier).fetchQuestions(_resolvedSubCategoryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final questionsAsync = practiceState.questions[_resolvedSubCategoryId] ?? const AsyncValue.loading();

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
          _resolvedTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
        child: Column(
          children: [
            Dimensions.verticalSpace(context, 20),
            // Header Matrix Card
            Container(
              padding: EdgeInsets.all(Dimensions.level3Margin(context)),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Dimensions.level2Margin(context)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.quiz_rounded, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
                  ),
                  Dimensions.horizontalSpace(context, 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resolvedTitle,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
                        ),
                        Text(
                          "Solve curated challenges and boost skills",
                          style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(practiceViewModelProvider.notifier).fetchQuestions(_resolvedSubCategoryId, force: true),
                    icon: Icon(Icons.refresh, size: Dimensions.utilizationTextSize(context) + 4, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
            Dimensions.verticalSpace(context, 20),
            // Search and Filter Row
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
                      hintText: "Search questions...",
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
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: Dimensions.level3Margin(context) - 1),
                    ),
                  ),
                ),
                Dimensions.horizontalSpace(context, 12),
                Container(
                  padding: EdgeInsets.all(Dimensions.level3Margin(context) - 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(Icons.tune_rounded, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
                ),
              ],
            ),
            Dimensions.verticalSpace(context, 25),

            // Questions List from API
            questionsAsync.when(
              data: (questions) {
                final filtered = questions.where((q) {
                  if (_searchQuery.isEmpty) return true;
                  return q.questionName.toLowerCase().contains(_searchQuery) ||
                      (q.problemStatement != null && q.problemStatement!.toLowerCase().contains(_searchQuery));
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text("No questions available.", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final question = filtered[index];
                    return _buildQuestionCardFromModel(context, question);
                  },
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
                      const Text("Failed to load questions.", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.read(practiceViewModelProvider.notifier).fetchQuestions(_resolvedSubCategoryId, force: true),
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

  Widget _buildQuestionCardFromModel(BuildContext context, PracticeQuestionModel question) {
    Color difficultyColor = Colors.green;
    final diffLower = question.difficulty.toLowerCase();
    if (diffLower.contains('medium')) {
      difficultyColor = Colors.orange;
    } else if (diffLower.contains('hard')) {
      difficultyColor = Colors.red;
    }

    bool isSolved = question.questionStatus.toLowerCase() == 'solved' || question.questionStatus.toLowerCase() == 'completed';

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  question.questionName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level2Margin(context) + 2,
                  vertical: Dimensions.level1Margin(context),
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.difficulty.toUpperCase(),
                  style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, fontWeight: FontWeight.bold, color: difficultyColor),
                ),
              ),
            ],
          ),
          if (question.problemStatement != null && question.problemStatement!.isNotEmpty) ...[
            Dimensions.verticalSpace(context, 8),
            Text(
              question.problemStatement!,
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade600, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          Dimensions.verticalSpace(context, 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${question.points} ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2),
                    ),
                    TextSpan(
                      text: "PTS",
                      style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.codingTestReady, extra: question);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSolved ? const Color(0xFFF1F5F9) : AppColors.primaryBlue,
                  foregroundColor: isSolved ? Colors.grey : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4, vertical: 0),
                  minimumSize: Size(Dimensions.level3Size(context) + 20, Dimensions.level3Margin(context) + 20),
                ),
                child: Text(
                  question.questionStatus.isNotEmpty ? question.questionStatus : (isSolved ? "Solved" : "Solve Now"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
