import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/networking_providers.dart';
import '../../../data/model/jobpost/TlJobPostModel.dart';
import '../../../data/repositories/TlJobRepository.dart';

final tlJobRepositoryProvider = Provider<TlJobRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TlJobRepository(apiClient);
});

final tlJobsViewModelProvider = StateNotifierProvider<TlJobsViewModel, AsyncValue<List<TlJobPostModel>>>((ref) {
  final repository = ref.watch(tlJobRepositoryProvider);
  return TlJobsViewModel(repository);
});

class TlJobsViewModel extends StateNotifier<AsyncValue<List<TlJobPostModel>>> {
  final TlJobRepository _repository;

  TlJobsViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchPostedJobs();
  }

  Future<void> fetchPostedJobs() async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _repository.getPostedJobs();
      state = AsyncValue.data(jobs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tlJobDetailProvider =
    StateNotifierProvider.family<TlJobDetailViewModel, AsyncValue<TlJobPostModel>, int>((ref, jobId) {
  final repository = ref.watch(tlJobRepositoryProvider);
  return TlJobDetailViewModel(repository, jobId);
});

class TlJobDetailViewModel extends StateNotifier<AsyncValue<TlJobPostModel>> {
  final TlJobRepository _repository;
  final int jobId;

  TlJobDetailViewModel(this._repository, this.jobId) : super(const AsyncValue.loading()) {
    fetchJob();
  }

  Future<void> fetchJob() async {
    state = const AsyncValue.loading();
    try {
      final job = await _repository.getJobById(jobId);
      state = AsyncValue.data(job);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
