import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/exam/McqExamModel.dart';
import '../../data/model/exam/McqExamQuestionModel.dart';
import '../../data/model/exam/ExamAttemptModel.dart';
import '../../data/model/exam/ExamAnswerModel.dart';
import '../../data/model/exam/ExamResultModel.dart';
import '../../data/model/exam/ExamTitleModel.dart';
import '../../data/repositories/ExamRepository.dart';

class ExamState {
  final AsyncValue<List<McqExamModel>> exams;
  final AsyncValue<List<ExamTitleModel>> examTitles;
  final Map<int, AsyncValue<List<McqExamQuestionModel>>> examQuestions;
  final AsyncValue<void> actionStatus;

  ExamState({
    this.exams = const AsyncValue.loading(),
    this.examTitles = const AsyncValue.loading(),
    this.examQuestions = const {},
    this.actionStatus = const AsyncValue.data(null),
  });

  ExamState copyWith({
    AsyncValue<List<McqExamModel>>? exams,
    AsyncValue<List<ExamTitleModel>>? examTitles,
    Map<int, AsyncValue<List<McqExamQuestionModel>>>? examQuestions,
    AsyncValue<void>? actionStatus,
  }) {
    return ExamState(
      exams: exams ?? this.exams,
      examTitles: examTitles ?? this.examTitles,
      examQuestions: examQuestions ?? this.examQuestions,
      actionStatus: actionStatus ?? this.actionStatus,
    );
  }
}

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExamRepository(apiClient);
});

final examViewModelProvider = StateNotifierProvider<ExamViewModel, ExamState>((ref) {
  final repository = ref.watch(examRepositoryProvider);
  return ExamViewModel(repository);
});

class ExamViewModel extends StateNotifier<ExamState> {
  final ExamRepository _repository;

  ExamViewModel(this._repository) : super(ExamState()) {
    fetchExams();
    fetchExamTitles();
  }

  Future<void> fetchExams({bool force = false}) async {
    if (!force && state.exams is AsyncData && state.exams.valueOrNull != null) return;
    state = state.copyWith(exams: const AsyncValue.loading());
    try {
      final list = await _repository.getPracticeExams();
      state = state.copyWith(exams: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(exams: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchExamTitles({bool force = false}) async {
    if (!force && state.examTitles is AsyncData && state.examTitles.valueOrNull != null) return;
    state = state.copyWith(examTitles: const AsyncValue.loading());
    try {
      final list = await _repository.getExamTitles();
      state = state.copyWith(examTitles: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(examTitles: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchExamQuestions(int examId, {bool force = false}) async {
    final existing = state.examQuestions[examId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updatedMap = Map<int, AsyncValue<List<McqExamQuestionModel>>>.from(state.examQuestions);
    updatedMap[examId] = const AsyncValue.loading();
    state = state.copyWith(examQuestions: updatedMap);

    try {
      final list = await _repository.getExamQuestions(examId);
      final newMap = Map<int, AsyncValue<List<McqExamQuestionModel>>>.from(state.examQuestions);
      newMap[examId] = AsyncValue.data(list);
      state = state.copyWith(examQuestions: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<McqExamQuestionModel>>>.from(state.examQuestions);
      newMap[examId] = AsyncValue.error(e, stack);
      state = state.copyWith(examQuestions: newMap);
    }
  }

  Future<ExamAttemptModel> startExamAttempt(int examId, {int? packId}) async {
    return await _repository.startExamAttempt(examId, packId: packId);
  }

  Future<dynamic> bulkSubmitAnswers(int attemptId, List<ExamAnswerModel> answers) async {
    return await _repository.bulkSubmitAnswers(attemptId, answers);
  }

  Future<ExamResultModel> completeExam(int attemptId) async {
    final result = await _repository.completeExam(attemptId);
    fetchExams(force: true);
    return result;
  }

  Future<McqExamModel> createSelfAssessmentExam({
    required int titleId,
    required String difficulty,
    required String description,
    required int totalDurationMinutes,
    required int passPercentage,
    required int noOfQuestions,
    List<int>? requiredSkills,
  }) async {
    state = state.copyWith(actionStatus: const AsyncValue.loading());
    try {
      final newExam = await _repository.createSelfAssessmentExam(
        titleId: titleId,
        difficulty: difficulty,
        description: description,
        totalDurationMinutes: totalDurationMinutes,
        passPercentage: passPercentage,
        noOfQuestions: noOfQuestions,
        requiredSkills: requiredSkills,
      );
      state = state.copyWith(actionStatus: const AsyncValue.data(null));
      fetchExams(force: true);
      return newExam;
    } catch (e, stack) {
      state = state.copyWith(actionStatus: AsyncValue.error(e, stack));
      rethrow;
    }
  }
}
