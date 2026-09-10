import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/practice/PracticeQuestionModel.dart';
import 'package:job_world/ui/home/ChallengePackViewModel.dart';
import 'package:job_world/ui/home/challenge_pack_nav_args.dart';

class ChallengePackCodingQuestionsScreen extends ConsumerStatefulWidget {
  final ChallengePackQuestionsArgs args;

  const ChallengePackCodingQuestionsScreen({super.key, required this.args});

  @override
  ConsumerState<ChallengePackCodingQuestionsScreen> createState() => _ChallengePackCodingQuestionsScreenState();
}

class _ChallengePackCodingQuestionsScreenState extends ConsumerState<ChallengePackCodingQuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengePackViewModelProvider.notifier).fetchSubdomainCodingQuestions(widget.args.subcategoryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packState = ref.watch(challengePackViewModelProvider);
    final questionsAsync = packState.subdomainCodingQuestions[widget.args.subcategoryId] ?? const AsyncValue.loading();

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
          widget.args.subcategoryName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
        child: Column(
          children: [
            Dimensions.verticalSpace(context, 20),
            Container(
              padding: EdgeInsets.all(Dimensions.level3Margin(context)),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Dimensions.level2Margin(context)),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.code_rounded, color: const Color(0xFF16A34A), size: Dimensions.level2Margin(context) + 12),
                  ),
                  Dimensions.horizontalSpace(context, 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.args.subcategoryName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
                        ),
                        Text(
                          "Solve curated coding challenges and boost skills",
                          style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(challengePackViewModelProvider.notifier).fetchSubdomainCodingQuestions(widget.args.subcategoryId, force: true),
                    icon: Icon(Icons.refresh, size: Dimensions.utilizationTextSize(context) + 4, color: const Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),
            Dimensions.verticalSpace(context, 20),
            TextField(
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
            Dimensions.verticalSpace(context, 25),
            questionsAsync.when(
              data: (questions) {
                final filtered = questions.where((q) {
                  if (_searchQuery.isEmpty) return true;
                  return q.questionName.toLowerCase().contains(_searchQuery);
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
                  itemBuilder: (context, index) => _buildQuestionCard(context, filtered[index]),
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
                        onPressed: () => ref.read(challengePackViewModelProvider.notifier).fetchSubdomainCodingQuestions(widget.args.subcategoryId, force: true),
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

  Widget _buildQuestionCard(BuildContext context, PracticeQuestionModel question) {
    Color difficultyColor = Colors.green;
    final diffLower = question.difficulty.toLowerCase();
    if (diffLower.contains('medium')) {
      difficultyColor = Colors.orange;
    } else if (diffLower.contains('hard')) {
      difficultyColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context)),
                ),
                Dimensions.verticalSpace(context, 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.level2Margin(context) + 2, vertical: Dimensions.level1Margin(context)),
                  decoration: BoxDecoration(color: difficultyColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    question.difficulty.toUpperCase(),
                    style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, fontWeight: FontWeight.bold, color: difficultyColor),
                  ),
                ),
              ],
            ),
          ),
          Dimensions.horizontalSpace(context, 12),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.codingTestReady, extra: question),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4, vertical: 0),
              minimumSize: Size(Dimensions.level3Size(context) - 30, Dimensions.level3Margin(context) + 20),
            ),
            child: Text(
              "Solve Now",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1),
            ),
          ),
        ],
      ),
    );
  }
}
