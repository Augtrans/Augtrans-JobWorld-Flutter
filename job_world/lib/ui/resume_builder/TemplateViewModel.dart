import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/profile/ResumeTemplateModel.dart';
import '../../data/repositories/ResumeRepository.dart';

class TemplateState {
  final AsyncValue<List<ResumeTemplateModel>> templates;
  final int? selectedTemplateId;

  TemplateState({
    this.templates = const AsyncValue.loading(),
    this.selectedTemplateId,
  });

  TemplateState copyWith({
    AsyncValue<List<ResumeTemplateModel>>? templates,
    int? selectedTemplateId,
  }) {
    return TemplateState(
      templates: templates ?? this.templates,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
    );
  }
}

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ResumeRepository(apiClient);
});

final templateViewModelProvider = StateNotifierProvider<TemplateViewModel, TemplateState>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return TemplateViewModel(repository);
});

class TemplateViewModel extends StateNotifier<TemplateState> {
  final ResumeRepository _repository;

  TemplateViewModel(this._repository) : super(TemplateState()) {
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    state = state.copyWith(templates: const AsyncValue.loading());
    try {
      final templates = await _repository.getTemplates();
      state = state.copyWith(
        templates: AsyncValue.data(templates),
        selectedTemplateId: templates.isNotEmpty ? templates.first.id : null,
      );
    } catch (e, stack) {
      state = state.copyWith(templates: AsyncValue.error(e, stack));
    }
  }

  void selectTemplate(int id) {
    state = state.copyWith(selectedTemplateId: id);
  }
}
