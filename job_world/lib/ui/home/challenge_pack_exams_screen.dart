import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/exam/McqExamModel.dart';
import 'package:job_world/ui/home/ChallengePackViewModel.dart';
import 'package:job_world/ui/home/challenge_pack_nav_args.dart';

class ChallengePackExamsScreen extends ConsumerStatefulWidget {
  final ChallengePackExamsArgs args;

  const ChallengePackExamsScreen({super.key, required this.args});

  @override
  ConsumerState<ChallengePackExamsScreen> createState() => _ChallengePackExamsScreenState();
}

class _ChallengePackExamsScreenState extends ConsumerState<ChallengePackExamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengePackViewModelProvider.notifier).fetchSubdomainExams(widget.args.subdomainId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final packState = ref.watch(challengePackViewModelProvider);
    final examsAsync = packState.subdomainExams[widget.args.subdomainId] ?? const AsyncValue.loading();

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
          widget.args.subdomainName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pick a difficulty",
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 8),
            Text(
              "Choose an MCQ challenge to start testing your knowledge.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600),
            ),
            Dimensions.verticalSpace(context, 25),
            examsAsync.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text("No exams available for this subdomain.", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exams.length,
                  separatorBuilder: (context, index) => Dimensions.verticalSpace(context, 20),
                  itemBuilder: (context, index) => _buildExamCard(context, exams[index]),
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
                      const Text("Failed to load exams.", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.read(challengePackViewModelProvider.notifier).fetchSubdomainExams(widget.args.subdomainId, force: true),
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

  Widget _buildExamCard(BuildContext context, McqExamModel exam) {
    String diffLabel = "BEGINNER";
    Color diffColor = AppColors.primaryBlue;

    final diffUpper = exam.difficulty.toUpperCase();
    if (diffUpper == 'I' || diffUpper.contains('INT')) {
      diffLabel = "INTERMEDIATE";
      diffColor = Colors.orange;
    } else if (diffUpper == 'A' || diffUpper.contains('ADV')) {
      diffLabel = "ADVANCED";
      diffColor = Colors.red;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.level2Margin(context) + 2, vertical: Dimensions.level1Margin(context)),
            decoration: BoxDecoration(color: diffColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              diffLabel,
              style: TextStyle(fontSize: Dimensions.smallerTextSize(context) + 1, fontWeight: FontWeight.bold, color: diffColor),
            ),
          ),
          Dimensions.verticalSpace(context, 12),
          Text(
            exam.titleName,
            style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          Dimensions.verticalSpace(context, 4),
          Text(
            exam.description.isNotEmpty ? exam.description : "Self Assessment Challenge",
            style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade500),
          ),
          Dimensions.verticalSpace(context, 16),
          Row(
            children: [
              _buildInfoItem(context, Icons.library_books_outlined, "${exam.noOfQuestions} Questions"),
              Dimensions.horizontalSpace(context, 12),
              _buildInfoItem(context, Icons.access_time, "${exam.totalDurationMinutes} mins"),
              Dimensions.horizontalSpace(context, 12),
              _buildInfoItem(context, Icons.check_circle_outline, "Pass ${exam.passPercentage}%"),
            ],
          ),
          Dimensions.verticalSpace(context, 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exam.isAttempted ? "Score: ${exam.score.toInt()}%" : "Not Attempted",
                style: TextStyle(
                  fontSize: Dimensions.utilizationTextSize(context),
                  color: exam.isAttempted ? Colors.green : Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.examSetup, extra: exam),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
                  minimumSize: Size(0, Dimensions.level3Margin(context) + 24),
                ),
                child: Row(
                  children: [
                    Text(
                      exam.isAttempted ? "Re-take" : "Start",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2),
                    ),
                    Dimensions.horizontalSpace(context, 8),
                    Icon(Icons.arrow_outward_rounded, size: Dimensions.largeTextSize(context) + 1),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade400),
        Dimensions.horizontalSpace(context, 4),
        Text(
          label,
          style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) - 2, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}