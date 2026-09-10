import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/data/model/exam/McqExamModel.dart';
import 'package:job_world/data/model/exam/McqExamQuestionModel.dart';
import 'package:job_world/data/model/exam/McqOptionModel.dart';
import 'package:job_world/data/model/exam/ExamAnswerModel.dart';
import 'package:job_world/data/model/exam/ExamResultModel.dart';
import 'package:job_world/ui/home/ExamViewModel.dart';

class ExaminationScreen extends ConsumerStatefulWidget {
  final McqExamModel? exam;
  final int? examId;

  const ExaminationScreen({super.key, this.exam, this.examId});

  @override
  ConsumerState<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends ConsumerState<ExaminationScreen> {
  int _currentIndex = 0;
  int? _attemptId;
  bool _isSubmitting = false;
  bool _isStartingExam = true;
  String? _startExamError;

  // Track selection and timing
  final Map<int, McqOptionModel> _selectedOptions = {}; // questionDetailsId -> selected Option
  final Map<int, String> _questionStartTimes = {}; // questionDetailsId -> ISO start time
  final Map<int, String> _questionEndTimes = {}; // questionDetailsId -> ISO end time

  int get _resolvedExamId {
    if (widget.exam != null && widget.exam!.id > 0) {
      return widget.exam!.id;
    }
    if (widget.examId != null && widget.examId! > 0) {
      return widget.examId!;
    }
    return 304; // Default fallback examId
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initExamSession();
    });
  }

  Future<void> _initExamSession() async {
    setState(() {
      _isStartingExam = true;
      _startExamError = null;
    });

    final notifier = ref.read(examViewModelProvider.notifier);

    try {
      final attempt = await notifier.startExamAttempt(_resolvedExamId, packId: widget.exam?.packId);
      notifier.fetchExamQuestions(_resolvedExamId);
      if (mounted) {
        setState(() {
          _attemptId = attempt.id;
          _isStartingExam = false;
        });
      }
    } catch (e) {
      debugPrint("Error starting exam attempt with packId: $e");
      final errorMsg = CommonMethods.extractErrorMessage(e);

      // If error is specifically about challenge pack step sequence, try standalone attempt
      if (errorMsg.contains("pack's current step")) {
        try {
          final fallbackAttempt = await notifier.startExamAttempt(_resolvedExamId);
          notifier.fetchExamQuestions(_resolvedExamId);
          if (mounted) {
            setState(() {
              _attemptId = fallbackAttempt.id;
              _isStartingExam = false;
            });
            return;
          }
        } catch (fallbackError) {
          final fallbackMsg = CommonMethods.extractErrorMessage(fallbackError);
          debugPrint("Error starting standalone exam attempt: $fallbackError");
          if (mounted) {
            setState(() {
              _startExamError = fallbackMsg;
              _isStartingExam = false;
            });
          }
          return;
        }
      }

      // If status code is 400 (e.g. Insufficient credits) or any error starting attempt:
      // Do NOT start exam and DO NOT show questions!
      if (mounted) {
        setState(() {
          _startExamError = errorMsg;
          _isStartingExam = false;
        });
      }
    }
  }

  void _recordQuestionStartTime(int questionDetailsId) {
    if (!_questionStartTimes.containsKey(questionDetailsId)) {
      _questionStartTimes[questionDetailsId] = DateTime.now().toIso8601String();
    }
  }

  void _recordQuestionEndTime(int questionDetailsId) {
    _questionEndTimes[questionDetailsId] = DateTime.now().toIso8601String();
  }

  Future<void> _submitExam(List<McqExamQuestionModel> questions) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final nowIso = DateTime.now().toIso8601String();
    final List<ExamAnswerModel> answersPayload = [];

    for (var qItem in questions) {
      final details = qItem.questionDetails;
      final qId = details.id;
      final selectedOpt = _selectedOptions[qId];

      final startTime = _questionStartTimes[qId] ?? nowIso;
      final endTime = _questionEndTimes[qId] ?? nowIso;

      answersPayload.add(
        ExamAnswerModel(
          question: qId,
          selectedOption: selectedOpt?.id,
          answerText: selectedOpt?.text,
          answerImage: null,
          questionStartTime: startTime,
          questionEndTime: endTime,
        ),
      );
    }

    final notifier = ref.read(examViewModelProvider.notifier);

    try {
      if (_attemptId != null && _attemptId! > 0) {
        await notifier.bulkSubmitAnswers(_attemptId!, answersPayload);
        final result = await notifier.completeExam(_attemptId!);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          _showResultDialog(context, result);
        }
      } else {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exam Submitted Successfully!")),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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

  void _showResultDialog(BuildContext context, ExamResultModel result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, color: AppColors.primaryBlue, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text("Exam Completed!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.examTitle ?? widget.exam?.titleName ?? "Practice Exam", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Score:"),
                Text("${result.totalScore}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Performance Score:"),
                Text("${result.performanceScore}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Avg Time/Question:"),
                Text("${result.averageQuestionTime}s", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            if (result.reward != null && result.reward!['blue_reward'] != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("+${result.reward!['blue_reward']} Blue Credits Earned!", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examTitle = widget.exam?.titleName ?? "MCQ Examination";

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
          examTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isStartingExam) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing Exam Session...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // IF START EXAM RETURNED STATUS CODE 400 / ERROR -> DO NOT SHOW QUESTIONS!
    if (_startExamError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.level4Margin(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_outlined, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                "Unable to Start Exam",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              Text(
                _startExamError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Go Back", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              if (_startExamError!.toLowerCase().contains("credit")) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      context.push(AppRoutes.credit);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Get Credits", style: TextStyle(color: AppColors.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final examState = ref.watch(examViewModelProvider);
    final questionsAsync = examState.examQuestions[_resolvedExamId] ?? const AsyncValue.loading();

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(
            child: Text("No questions available for this exam.", style: TextStyle(color: Colors.grey)),
          );
        }

        if (_currentIndex >= questions.length) {
          _currentIndex = questions.length - 1;
        }

        final currentQuestionItem = questions[_currentIndex];
        final details = currentQuestionItem.questionDetails;
        final int qId = details.id;

        _recordQuestionStartTime(qId);

        final selectedOpt = _selectedOptions[qId];
        final double progress = (_selectedOptions.length / questions.length).clamp(0.0, 1.0);

        return Column(
          children: [
            _buildQuestionPalette(context, questions.length, _selectedOptions.length, progress),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionHeader(context, _currentIndex + 1, questions.length, details.skill),
                    Dimensions.verticalSpace(context, 24),
                    Text(
                      details.questionType.isNotEmpty ? "${details.questionType} Question" : "Multiple Choice Question",
                      style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey),
                    ),
                    Dimensions.verticalSpace(context, 20),
                    Text(
                      details.text,
                      style: TextStyle(
                        fontSize: Dimensions.xlargeTextSize(context) - 2,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                    Dimensions.verticalSpace(context, 32),

                    if (details.options.isEmpty)
                      const Text("No options provided for this question.", style: TextStyle(color: Colors.grey))
                    else
                      ...details.options.map((opt) {
                        bool isSelected = selectedOpt?.id == opt.id;
                        return _buildOptionCard(
                          context: context,
                          optionText: opt.text,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedOptions[qId] = opt;
                            });
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context, questions),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Failed to load exam questions.", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => ref.read(examViewModelProvider.notifier).fetchExamQuestions(_resolvedExamId, force: true),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPalette(BuildContext context, int totalQuestions, int answeredCount, double progress) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.level4Margin(context) - 8,
        vertical: Dimensions.level2Margin(context) + 2,
      ),
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Expanded(
                child: Text(
                  "Question Palette",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    fontSize: Dimensions.level3Margin(context),
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: Dimensions.level4Margin(context) - 8),
            ],
          ),
          Dimensions.verticalSpace(context, 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: Dimensions.level2Margin(context),
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          Dimensions.verticalSpace(context, 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$answeredCount/$totalQuestions Answered",
              style: TextStyle(
                fontSize: Dimensions.utilizationTextSize(context),
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(BuildContext context, int current, int total, String? skill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.level3Margin(context),
            vertical: Dimensions.level2Margin(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "QUESTION $current OF $total",
            style: TextStyle(
              fontSize: Dimensions.utilizationTextSize(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        if (skill != null && skill.isNotEmpty)
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.level2Margin(context) + 4,
                vertical: Dimensions.level2Margin(context),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                skill,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String optionText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.level3Margin(context)),
        padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: Dimensions.level4Margin(context) - 8,
              height: Dimensions.level4Margin(context) - 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: Dimensions.utilizationTextSize(context),
                        height: Dimensions.utilizationTextSize(context),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            Dimensions.horizontalSpace(context, 16),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: Dimensions.utilizationTextSize(context) + 1,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, List<McqExamQuestionModel> questions) {
    bool isLast = _currentIndex >= questions.length - 1;

    return Container(
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: Dimensions.level1Size(context) + 6,
              child: OutlinedButton(
                onPressed: (_currentIndex > 0 && !_isSubmitting)
                    ? () {
                        final currentQ = questions[_currentIndex].questionDetails.id;
                        _recordQuestionEndTime(currentQ);
                        setState(() {
                          _currentIndex--;
                        });
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  "Previous",
                  style: TextStyle(
                    color: _currentIndex > 0 ? Colors.black87 : Colors.grey.shade300,
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.utilizationTextSize(context) + 2,
                  ),
                ),
              ),
            ),
          ),
          Dimensions.horizontalSpace(context, 16),
          Expanded(
            child: SizedBox(
              height: Dimensions.level1Size(context) + 6,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        final currentQ = questions[_currentIndex].questionDetails.id;
                        _recordQuestionEndTime(currentQ);

                        if (isLast) {
                          _submitExam(questions);
                        } else {
                          setState(() {
                            _currentIndex++;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isLast ? "Submit Exam" : "Save & Next",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.utilizationTextSize(context) + 2,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
