import '../../core/networking/api_client.dart';
import '../model/credit/WalletModel.dart';
import 'endpoints/api_endpoints.dart';

class WalletRepository {
  final ApiClient _client;

  WalletRepository(this._client);

  Future<WalletModel> getWallet() async {
    try {
      return await _client.request<WalletModel>(
        ApiConstants.walletEndpoint,
        method: 'GET',
        parser: (data) => WalletModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }
}
