import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/credit/WalletModel.dart';
import '../../data/repositories/WalletRepository.dart';

class WalletState {
  final AsyncValue<WalletModel> wallet;

  WalletState({
    this.wallet = const AsyncValue.loading(),
  });

  WalletState copyWith({
    AsyncValue<WalletModel>? wallet,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
    );
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient);
});

final walletViewModelProvider = StateNotifierProvider<WalletViewModel, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletViewModel(repository);
});

class WalletViewModel extends StateNotifier<WalletState> {
  final WalletRepository _repository;

  WalletViewModel(this._repository) : super(WalletState()) {
    fetchWallet();
  }

  Future<void> fetchWallet({bool force = false}) async {
    if (!force && state.wallet is AsyncData) return;
    state = state.copyWith(wallet: const AsyncValue.loading());
    try {
      final wallet = await _repository.getWallet();
      state = state.copyWith(wallet: AsyncValue.data(wallet));
    } catch (e, stack) {
      state = state.copyWith(wallet: AsyncValue.error(e, stack));
    }
  }
}
