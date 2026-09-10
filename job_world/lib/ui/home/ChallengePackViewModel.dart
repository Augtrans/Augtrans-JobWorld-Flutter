import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/challenge_pack/ChallengePackTypeModel.dart';
import '../../data/model/challenge_pack/PackSubdomainModel.dart';
import '../../data/model/challenge_pack/PackSubcategoryModel.dart';
import '../../data/model/exam/McqExamModel.dart';
import '../../data/model/practice/PracticeQuestionModel.dart';
import '../../data/repositories/ChallengePackRepository.dart';

class ChallengePackState {

  final AsyncValue<List<ChallengePackTypeModel>> packTypes;
  final Map<int, AsyncValue<List<PackSubdomainModel>>> mcqSubdomains;
  final Map<int, AsyncValue<List<PackSubcategoryModel>>> codingSubcategories;
  final Map<int, AsyncValue<List<McqExamModel>>> subdomainExams;
  final Map<int, AsyncValue<List<PracticeQuestionModel>>> subdomainCodingQuestions;

  ChallengePackState({
    this.packTypes = const AsyncValue.loading(),
    this.mcqSubdomains = const {},
    this.codingSubcategories = const {},
    this.subdomainExams = const {},
    this.subdomainCodingQuestions = const {},
  });

  ChallengePackState copyWith({
    AsyncValue<List<ChallengePackTypeModel>>? packTypes,
    Map<int, AsyncValue<List<PackSubdomainModel>>>? mcqSubdomains,
    Map<int, AsyncValue<List<PackSubcategoryModel>>>? codingSubcategories,
    Map<int, AsyncValue<List<McqExamModel>>>? subdomainExams,
    Map<int, AsyncValue<List<PracticeQuestionModel>>>? subdomainCodingQuestions,
  }) {
    return ChallengePackState(
      packTypes: packTypes ?? this.packTypes,
      mcqSubdomains: mcqSubdomains ?? this.mcqSubdomains,
      codingSubcategories: codingSubcategories ?? this.codingSubcategories,
      subdomainExams: subdomainExams ?? this.subdomainExams,
      subdomainCodingQuestions: subdomainCodingQuestions ?? this.subdomainCodingQuestions,
    );
  }
}

final challengePackRepositoryProvider = Provider<ChallengePackRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChallengePackRepository(apiClient);
});

final challengePackViewModelProvider = StateNotifierProvider<ChallengePackViewModel, ChallengePackState>((ref) {
  final repository = ref.watch(challengePackRepositoryProvider);
  return ChallengePackViewModel(repository);
});

class ChallengePackViewModel extends StateNotifier<ChallengePackState> {
  final ChallengePackRepository _repository;

  ChallengePackViewModel(this._repository) : super(ChallengePackState()) {
    fetchPackTypes();
  }

  Future<void> fetchPackTypes({bool force = false}) async {
    if (!force && state.packTypes is AsyncData && state.packTypes.valueOrNull != null) return;
    state = state.copyWith(packTypes: const AsyncValue.loading());
    try {
      final list = await _repository.getPackTypes();
      state = state.copyWith(packTypes: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(packTypes: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchMcqSubdomains(int domainId, {bool force = false}) async {
    final existing = state.mcqSubdomains[domainId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updated = Map<int, AsyncValue<List<PackSubdomainModel>>>.from(state.mcqSubdomains);
    updated[domainId] = const AsyncValue.loading();
    state = state.copyWith(mcqSubdomains: updated);

    try {
      final list = await _repository.getMcqSubdomains(domainId);
      final newMap = Map<int, AsyncValue<List<PackSubdomainModel>>>.from(state.mcqSubdomains);
      newMap[domainId] = AsyncValue.data(list);
      state = state.copyWith(mcqSubdomains: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<PackSubdomainModel>>>.from(state.mcqSubdomains);
      newMap[domainId] = AsyncValue.error(e, stack);
      state = state.copyWith(mcqSubdomains: newMap);
    }
  }

  Future<void> fetchCodingSubcategories(int categoryId, {bool force = false}) async {
    final existing = state.codingSubcategories[categoryId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updated = Map<int, AsyncValue<List<PackSubcategoryModel>>>.from(state.codingSubcategories);
    updated[categoryId] = const AsyncValue.loading();
    state = state.copyWith(codingSubcategories: updated);

    try {
      final list = await _repository.getCodingSubcategories(categoryId);
      final newMap = Map<int, AsyncValue<List<PackSubcategoryModel>>>.from(state.codingSubcategories);
      newMap[categoryId] = AsyncValue.data(list);
      state = state.copyWith(codingSubcategories: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<PackSubcategoryModel>>>.from(state.codingSubcategories);
      newMap[categoryId] = AsyncValue.error(e, stack);
      state = state.copyWith(codingSubcategories: newMap);
    }
  }

  Future<void> fetchSubdomainExams(int subdomainId, {bool force = false}) async {
    final existing = state.subdomainExams[subdomainId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updated = Map<int, AsyncValue<List<McqExamModel>>>.from(state.subdomainExams);
    updated[subdomainId] = const AsyncValue.loading();
    state = state.copyWith(subdomainExams: updated);

    try {
      final list = await _repository.getSubdomainExams(subdomainId);
      final newMap = Map<int, AsyncValue<List<McqExamModel>>>.from(state.subdomainExams);
      newMap[subdomainId] = AsyncValue.data(list);
      state = state.copyWith(subdomainExams: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<McqExamModel>>>.from(state.subdomainExams);
      newMap[subdomainId] = AsyncValue.error(e, stack);
      state = state.copyWith(subdomainExams: newMap);
    }
  }

  Future<void> fetchSubdomainCodingQuestions(int subcategoryId, {bool force = false}) async {
    final existing = state.subdomainCodingQuestions[subcategoryId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updated = Map<int, AsyncValue<List<PracticeQuestionModel>>>.from(state.subdomainCodingQuestions);
    updated[subcategoryId] = const AsyncValue.loading();
    state = state.copyWith(subdomainCodingQuestions: updated);

    try {
      final list = await _repository.getSubdomainCodingQuestions(subcategoryId);
      final newMap = Map<int, AsyncValue<List<PracticeQuestionModel>>>.from(state.subdomainCodingQuestions);
      newMap[subcategoryId] = AsyncValue.data(list);
      state = state.copyWith(subdomainCodingQuestions: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<PracticeQuestionModel>>>.from(state.subdomainCodingQuestions);
      newMap[subcategoryId] = AsyncValue.error(e, stack);
      state = state.copyWith(subdomainCodingQuestions: newMap);
    }
  }
}
