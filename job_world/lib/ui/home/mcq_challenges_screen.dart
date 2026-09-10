import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/data/model/exam/McqExamModel.dart';
import 'package:job_world/data/model/exam/ExamTitleModel.dart';
import 'package:job_world/ui/home/ExamViewModel.dart';

class McqChallengesScreen extends ConsumerStatefulWidget {
  const McqChallengesScreen({super.key});

  @override
  ConsumerState<McqChallengesScreen> createState() => _McqChallengesScreenState();
}

class _McqChallengesScreenState extends ConsumerState<McqChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(examViewModelProvider.notifier).fetchExams();
      ref.read(examViewModelProvider.notifier).fetchExamTitles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examViewModelProvider);

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
            Dimensions.verticalSpace(context, 20),
            Text(
              "MCQ Challenges",
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 8),
            Text(
              "Master the logic and syntax of modern development through curated challenges across 15+ specializations.",
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600),
            ),
            Dimensions.verticalSpace(context, 25),
            _buildCreateChallengeButton(context),
            Dimensions.verticalSpace(context, 25),

            examState.exams.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text("No MCQ challenges available.", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exams.length,
                  separatorBuilder: (context, index) => Dimensions.verticalSpace(context, 20),
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _buildMcqCardFromModel(context, exam);
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
                      const Text("Failed to load practice exams.", style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.read(examViewModelProvider.notifier).fetchExams(force: true),
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

  Widget _buildCreateChallengeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showCreateChallengeDialog(context),
        icon: const Icon(Icons.add, size: 20),
        label: const Text("Create Challenge", style: TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: BorderSide(color: Colors.grey.shade200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateChallengeDialog(),
    );
  }

  Widget _buildMcqCardFromModel(BuildContext context, McqExamModel exam) {
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.level2Margin(context) + 2,
              vertical: Dimensions.level1Margin(context),
            ),
            decoration: BoxDecoration(
              color: diffColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              diffLabel,
              style: TextStyle(
                fontSize: Dimensions.smallerTextSize(context) + 1,
                fontWeight: FontWeight.bold,
                color: diffColor,
              ),
            ),
          ),
          Dimensions.verticalSpace(context, 12),
          Text(
            exam.titleName,
            style: TextStyle(
              fontSize: Dimensions.largeTextSize(context) + 3,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
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
                onPressed: () {
                  context.push(AppRoutes.examSetup, extra: exam);
                },
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.utilizationTextSize(context) + 2,
                      ),
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
          style: TextStyle(
            fontSize: Dimensions.utilizationTextSize(context) - 2,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class CreateChallengeDialog extends ConsumerStatefulWidget {
  const CreateChallengeDialog({super.key});

  @override
  ConsumerState<CreateChallengeDialog> createState() => _CreateChallengeDialogState();
}

class _CreateChallengeDialogState extends ConsumerState<CreateChallengeDialog> {
  int? _selectedTitleId;
  String _selectedDifficulty = "B";
  final TextEditingController _questionsController = TextEditingController(text: "15");
  final TextEditingController _descriptionController = TextEditingController(text: "My Self Assessment Test");
  bool _isLoading = false;

  final Map<String, String> _difficultyOptions = {
    "B": "Beginner",
    "I": "Intermediate",
    "A": "Advanced",
  };

  @override
  void dispose() {
    _questionsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitCreateChallenge() async {
    final numQuestions = int.tryParse(_questionsController.text.trim()) ?? 15;
    final desc = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : "My Self Assessment Test";

    if (_selectedTitleId == null || _selectedTitleId! <= 0) {
      CommonMethods.showSnackBar(context, "Please select an exam title", backgroundColor: Colors.red.shade700);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newExam = await ref.read(examViewModelProvider.notifier).createSelfAssessmentExam(
        titleId: _selectedTitleId!,
        difficulty: _selectedDifficulty,
        description: desc,
        totalDurationMinutes: 15,
        passPercentage: 50,
        noOfQuestions: numQuestions,
      );

      if (mounted) {
        final router = GoRouter.of(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Challenge Created Successfully!")),
        );
        router.push(AppRoutes.examSetup, extra: newExam);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = CommonMethods.extractErrorMessage(e);
        CommonMethods.showSnackBar(
          context,
          errorMessage,
          backgroundColor: Colors.red.shade700,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Create Course Challenge",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              Dimensions.verticalSpace(context, 20),
              Text("Exam Track / Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context))),
              Dimensions.verticalSpace(context, 8),
              _buildTitleDropdown(),
              Dimensions.verticalSpace(context, 16),
              Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context))),
              Dimensions.verticalSpace(context, 8),
              _buildDifficultyDropdown(),
              Dimensions.verticalSpace(context, 16),
              Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context))),
              Dimensions.verticalSpace(context, 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter description...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 16),
              Text("No. of Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context))),
              Dimensions.verticalSpace(context, 8),
              TextField(
                controller: _questionsController,
                decoration: InputDecoration(
                  hintText: "15",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              Dimensions.verticalSpace(context, 28),
              SizedBox(
                width: double.infinity,
                height: Dimensions.level1Size(context) + 6,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCreateChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Create Challenge",
                          style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              Dimensions.verticalSpace(context, 12),
              SizedBox(
                width: double.infinity,
                height: Dimensions.level1Size(context) + 6,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: Dimensions.level3Margin(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleDropdown() {
    final examTitlesAsync = ref.watch(examViewModelProvider).examTitles;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: examTitlesAsync.when(
        data: (titles) {
          if (titles.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("No exam titles available"),
            );
          }

          if (_selectedTitleId == null || !titles.any((t) => t.id == _selectedTitleId)) {
            _selectedTitleId = titles.first.id;
          }

          return DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedTitleId,
              items: titles
                  .map((t) => DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(t.name, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedTitleId = v;
                  });
                }
              },
            ),
          );
        },
        loading: () => const SizedBox(
          height: 48,
          child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text("Error loading titles", style: TextStyle(color: Colors.red.shade400, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDifficulty,
          items: _difficultyOptions.entries
              .map((e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value, style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _selectedDifficulty = v;
              });
            }
          },
        ),
      ),
    );
  }
}
