import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'WalletViewModel.dart';

class CreditScreen extends ConsumerStatefulWidget {
  const CreditScreen({super.key});

  @override
  ConsumerState<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends ConsumerState<CreditScreen> {
  final NumberFormat _numberFormat = NumberFormat("#,##0.##");

  String _format(double value) => _numberFormat.format(value);

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Credit",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletViewModelProvider.notifier).fetchWallet(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMyWalletHeader(),
              const SizedBox(height: 20),
              _buildTotalBalanceCard(walletState),
              const SizedBox(height: 30),
              _buildTopUpCreditsSection(context),
              const SizedBox(height: 35),
              _buildGoldMarketplaceSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyWalletHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "My Wallet",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        SizedBox(height: 4),
        Text(
          "Global currency management for your professional ecosystem.",
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(WalletState walletState) {
    final wallet = walletState.wallet;
    final isLoading = wallet is AsyncLoading;
    final hasError = wallet is AsyncError;
    final data = wallet.valueOrNull;

    final totalText = isLoading ? "…" : (hasError ? "--" : _format(data?.totalCredits ?? 0));
    final blueText = isLoading ? "…" : (hasError ? "--" : _format(data?.blueCredits ?? 0));
    final greenText = isLoading ? "…" : (hasError ? "--" : _format(data?.greenCredits ?? 0));
    final goldText = isLoading ? "…" : (hasError ? "--" : _format(data?.goldPoints ?? 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF4FF), Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL BALANCE",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$totalText ",
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const TextSpan(
                          text: "pts",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                        ),
                      ],
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => ref.read(walletViewModelProvider.notifier).fetchWallet(force: true),
                      child: const Text(
                        "Couldn't load wallet. Tap to retry.",
                        style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSubCreditCard(blueText, "BLUE", const Color(0xFF2563EB), const Color(0xFFEFF6FF), Icons.diamond_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _buildSubCreditCard(greenText, "GREEN", const Color(0xFF16A34A), const Color(0xFFF0FDF4), Icons.bolt_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _buildSubCreditCard(goldText, "GOLD", const Color(0xFFD97706), const Color(0xFFFFFBEB), Icons.workspace_premium_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubCreditCard(String value, String label, Color color, Color bgIconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgIconColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpCreditsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Top-up Credits",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 2),
                Text(
                  "Boost your ecosystem power.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.creditHistory),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: const [
                    Text(
                      "History",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Color(0xFF6366F1), size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildStarterPackCard(),
        const SizedBox(height: 18),
        _buildProPackCard(),
        const SizedBox(height: 18),
        _buildElitePackCard(),
      ],
    );
  }

  Widget _buildStarterPackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Starter Pack", style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: "3,000 ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                TextSpan(text: "Credits", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem("Valid for all basic exams"),
          const SizedBox(height: 6),
          _buildCheckItem("Instant delivery"),
          const SizedBox(height: 16),
          _build3DCoinBanner("JW 1000 CREDITS", const Color(0xFF064E3B), const Color(0xFF10B981)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("₹10", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProPackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF818CF8), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PRO PACK", style: TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: "17,000 ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                TextSpan(text: "Credits", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem("Unlock AI Interviewer"),
          const SizedBox(height: 6),
          _buildCheckItem("Priority Support Access"),
          const SizedBox(height: 6),
          _buildCheckItem("Bonus: 500 Gold Points"),
          const SizedBox(height: 16),
          _build3DServerBanner("PRO CREDITS PACK", const Color(0xFF1E1B4B), const Color(0xFF4F46E5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("₹50", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Buy Pro Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElitePackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Elite Pack", style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: "35,000 ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                TextSpan(text: "Credits", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem("Enterprise Level Access"),
          const SizedBox(height: 6),
          _buildCheckItem("Custom Profile Badges"),
          const SizedBox(height: 16),
          _build3DChestBanner("ELITE CREDITS VAULT", const Color(0xFF022C22), const Color(0xFF059669)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("₹100", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
      ],
    );
  }

  Widget _build3DCoinBanner(String title, Color darkBg, Color accentColor) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkBg, const Color(0xFF022C22)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: CircleAvatar(radius: 60, backgroundColor: accentColor.withValues(alpha: 0.15)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 3),
              boxShadow: [
                BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Text("JW", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DServerBanner(String title, Color darkBg, Color accentColor) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkBg, const Color(0xFF312E81)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_rounded, color: accentColor, size: 48),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("JobWorld", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Credits Management", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _build3DChestBanner(String title, Color darkBg, Color accentColor) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkBg, const Color(0xFF064E3B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded, color: accentColor, size: 48),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("JMC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                Text("JobWorld Credits Vault", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGoldMarketplaceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 8),
                Text(
                  "Gold Marketplace",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const Text(
              "See all",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 330,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMarketplaceCard(
                title: "AI Interview Access",
                subtitle: "Mock interviews with advanced LLMs.",
                requiredGold: "500",
                buttonText: "LOCKED",
                isFeatured: true,
              ),
              const SizedBox(width: 16),
              _buildMarketplaceCard(
                title: "Extra Resume Templates",
                subtitle: "Unlock premium design layouts.",
                requiredGold: "100",
                buttonText: "LOCKED",
                isFeatured: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceCard({
    required String title,
    required String subtitle,
    required String requiredGold,
    required String buttonText,
    required bool isFeatured,
  }) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: const Text("FEATURED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ),
            )
          else
            const SizedBox(height: 22),
          const SizedBox(height: 10),
          Center(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF6366F1)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("REQUIRED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFD97706), size: 14),
                      const SizedBox(width: 4),
                      Text(requiredGold, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6), letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
