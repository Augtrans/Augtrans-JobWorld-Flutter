import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/practice/PracticeCategoryModel.dart';
import '../../data/model/practice/PracticeSubcategoryModel.dart';
import '../../data/model/practice/PracticeQuestionModel.dart';
import '../../data/repositories/PracticeRepository.dart';

class PracticeState {
  final AsyncValue<List<PracticeCategoryModel>> categories;
  final Map<int, AsyncValue<List<PracticeSubcategoryModel>>> subcategories;
  final Map<int, AsyncValue<List<PracticeQuestionModel>>> questions;

  PracticeState({
    this.categories = const AsyncValue.loading(),
    this.subcategories = const {},
    this.questions = const {},
  });

  PracticeState copyWith({
    AsyncValue<List<PracticeCategoryModel>>? categories,
    Map<int, AsyncValue<List<PracticeSubcategoryModel>>>? subcategories,
    Map<int, AsyncValue<List<PracticeQuestionModel>>>? questions,
  }) {
    return PracticeState(
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      questions: questions ?? this.questions,
    );
  }
}

final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PracticeRepository(apiClient);
});

final practiceViewModelProvider = StateNotifierProvider<PracticeViewModel, PracticeState>((ref) {
  final repository = ref.watch(practiceRepositoryProvider);
  return PracticeViewModel(repository);
});

class PracticeViewModel extends StateNotifier<PracticeState> {
  final PracticeRepository _repository;

  PracticeViewModel(this._repository) : super(PracticeState()) {
    fetchCategories();
  }

  Future<void> fetchCategories({bool force = false}) async {
    if (!force && state.categories is AsyncData && state.categories.valueOrNull != null) return;
    state = state.copyWith(categories: const AsyncValue.loading());
    try {
      final list = await _repository.getCategories();
      state = state.copyWith(categories: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(categories: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchSubcategories(int categoryId, {bool force = false}) async {
    final existing = state.subcategories[categoryId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updatedMap = Map<int, AsyncValue<List<PracticeSubcategoryModel>>>.from(state.subcategories);
    updatedMap[categoryId] = const AsyncValue.loading();
    state = state.copyWith(subcategories: updatedMap);

    try {
      final list = await _repository.getSubcategories(categoryId);
      final newMap = Map<int, AsyncValue<List<PracticeSubcategoryModel>>>.from(state.subcategories);
      newMap[categoryId] = AsyncValue.data(list);
      state = state.copyWith(subcategories: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<PracticeSubcategoryModel>>>.from(state.subcategories);
      newMap[categoryId] = AsyncValue.error(e, stack);
      state = state.copyWith(subcategories: newMap);
    }
  }

  Future<void> fetchQuestions(int subCategoryId, {bool force = false}) async {
    final existing = state.questions[subCategoryId];
    if (!force && existing is AsyncData && existing?.valueOrNull != null) return;

    final updatedMap = Map<int, AsyncValue<List<PracticeQuestionModel>>>.from(state.questions);
    updatedMap[subCategoryId] = const AsyncValue.loading();
    state = state.copyWith(questions: updatedMap);

    try {
      final list = await _repository.getQuestions(subCategoryId);
      final newMap = Map<int, AsyncValue<List<PracticeQuestionModel>>>.from(state.questions);
      newMap[subCategoryId] = AsyncValue.data(list);
      state = state.copyWith(questions: newMap);
    } catch (e, stack) {
      final newMap = Map<int, AsyncValue<List<PracticeQuestionModel>>>.from(state.questions);
      newMap[subCategoryId] = AsyncValue.error(e, stack);
      state = state.copyWith(questions: newMap);
    }
  }
}
