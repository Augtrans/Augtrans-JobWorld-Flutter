class WalletModel {
  final double greenCredits;
  final double blueCredits;
  final double goldPoints;
  final double totalCredits;

  WalletModel({
    this.greenCredits = 0.0,
    this.blueCredits = 0.0,
    this.goldPoints = 0.0,
    this.totalCredits = 0.0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      greenCredits: _toDouble(json['green_credits']),
      blueCredits: _toDouble(json['blue_credits']),
      goldPoints: _toDouble(json['gold_points']),
      totalCredits: _toDouble(json['total_credits']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
