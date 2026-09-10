import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/interview/BotInterviewConfigModel.dart';
import '../../data/model/interview/InterviewSessionModel.dart';
import '../../data/repositories/InterviewRepository.dart';

class AiInterviewState {
  final AsyncValue<List<BotInterviewConfigModel>> configs;
  final BotInterviewConfigModel? selectedConfig;
  final AsyncValue<InterviewSessionModel?> sessionStatus;

  AiInterviewState({
    this.configs = const AsyncValue.loading(),
    this.selectedConfig,
    this.sessionStatus = const AsyncValue.data(null),
  });

  AiInterviewState copyWith({
    AsyncValue<List<BotInterviewConfigModel>>? configs,
    BotInterviewConfigModel? selectedConfig,
    AsyncValue<InterviewSessionModel?>? sessionStatus,
  }) {
    return AiInterviewState(
      configs: configs ?? this.configs,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      sessionStatus: sessionStatus ?? this.sessionStatus,
    );
  }
}

final interviewRepositoryProvider = Provider<InterviewRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InterviewRepository(apiClient);
});

final aiInterviewViewModelProvider = StateNotifierProvider<AiInterviewViewModel, AiInterviewState>((ref) {
  final repository = ref.watch(interviewRepositoryProvider);
  return AiInterviewViewModel(repository);
});

class AiInterviewViewModel extends StateNotifier<AiInterviewState> {
  final InterviewRepository _repository;

  AiInterviewViewModel(this._repository) : super(AiInterviewState()) {
    fetchBotInterviewConfigs();
  }

  Future<void> fetchBotInterviewConfigs({bool force = false}) async {
    if (!force && state.configs is AsyncData && state.configs.valueOrNull != null) return;
    state = state.copyWith(configs: const AsyncValue.loading());
    try {
      final list = await _repository.getBotInterviewConfigs();
      state = state.copyWith(
        configs: AsyncValue.data(list),
        selectedConfig: state.selectedConfig ?? (list.isNotEmpty ? list.first : null),
      );
    } catch (e, stack) {
      state = state.copyWith(configs: AsyncValue.error(e, stack));
    }
  }

  void selectConfig(BotInterviewConfigModel config) {
    state = state.copyWith(selectedConfig: config);
  }

  Future<void> startInterviewSession() async {
    final config = state.selectedConfig;
    if (config == null) return;
    state = state.copyWith(sessionStatus: const AsyncValue.loading());
    try {
      final session = await _repository.startInterviewSession(config.configId);
      state = state.copyWith(sessionStatus: AsyncValue.data(session));
    } catch (e, stack) {
      state = state.copyWith(sessionStatus: AsyncValue.error(e, stack));
    }
  }
}
