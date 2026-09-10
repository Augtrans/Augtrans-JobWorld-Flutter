import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreditHistoryScreen extends StatefulWidget {
  const CreditHistoryScreen({super.key});

  @override
  State<CreditHistoryScreen> createState() => _CreditHistoryScreenState();
}

class _CreditHistoryScreenState extends State<CreditHistoryScreen> {
  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMyWalletHeader(),
            const SizedBox(height: 20),
            _buildTotalBalanceCard(),
            const SizedBox(height: 30),
            _buildAnalyticsSection(),
            const SizedBox(height: 30),
            _buildRewardBannerCard(),
            const SizedBox(height: 35),
            _buildTransactionHistorySection(),
            const SizedBox(height: 40),
          ],
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

  Widget _buildTotalBalanceCard() {
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
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "2,675 ",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        TextSpan(
                          text: "pts",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                        ),
                      ],
                    ),
                  ),
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
              Expanded(child: _buildSubCreditCard("100", "BLUE", const Color(0xFF2563EB), const Color(0xFFEFF6FF), Icons.diamond_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _buildSubCreditCard("2,500", "GREEN", const Color(0xFF16A34A), const Color(0xFFF0FDF4), Icons.bolt_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _buildSubCreditCard("75", "GOLD", const Color(0xFFD97706), const Color(0xFFFFFBEB), Icons.workspace_premium_rounded)),
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

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Analytics",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBgColor: const Color(0xFFDCFCE7),
                title: "Lifetime Earned",
                value: "2,500",
                tagText: "📈 +12% this month",
                tagBgColor: const Color(0xFFF0FDF4),
                tagTextColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAnalyticsCard(
                icon: Icons.shopping_cart_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFDBEAFE),
                title: "Lifetime Purchased",
                value: "120,000",
                tagText: "⚡ Core driver",
                tagBgColor: const Color(0xFFEFF6FF),
                tagTextColor: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                icon: Icons.credit_card_rounded,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                title: "Total Spent",
                value: "118,500",
                tagText: "📉 -5% vs last month",
                tagBgColor: const Color(0xFFFEF2F2),
                tagTextColor: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAnalyticsCard(
                icon: Icons.category_rounded,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFEDD5),
                title: "Most Used",
                value: "MCQ Practice",
                tagText: "👑 Top category",
                tagBgColor: const Color(0xFFFFFBEB),
                tagTextColor: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String tagText,
    required Color tagBgColor,
    required Color tagTextColor,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: value.length > 8 ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: tagBgColor, borderRadius: BorderRadius.circular(8)),
            child: Text(
              tagText,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBannerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text("Earned", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 12),
                    SizedBox(width: 4),
                    Text("Aug 21, 2026", style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "MCQ Challenge\nReward",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD97706)),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFD97706).withValues(alpha: 0.15),
            ),
            child: const Text("● GOLD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("YOU EARNED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1)),
                    SizedBox(height: 2),
                    Text("+25 Credits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Added to your account", style: TextStyle(fontSize: 10, color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Transaction History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          icon: Icons.arrow_downward_rounded,
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: "Earned",
          subtitle: "MCQ_EXAM",
          date: "6 OCT 2026",
          amount: "+50",
          tagText: "● Gold",
          tagTextColor: const Color(0xFFD97706),
          balanceText: "Balance: 75",
        ),
        const Divider(height: 24, color: Color(0xFFF1F5F9)),
        _buildTransactionItem(
          icon: Icons.shopping_cart_outlined,
          iconBgColor: const Color(0xFFF1F5F9),
          iconColor: const Color(0xFF334155),
          title: "Purchased",
          subtitle: "RAZORPAY",
          date: "6 OCT 2026",
          amount: "+3000",
          tagText: "Green",
          tagTextColor: const Color(0xFF16A34A),
          balanceText: "Balance: 2700",
        ),
        const Divider(height: 24, color: Color(0xFFF1F5F9)),
        _buildTransactionItem(
          icon: Icons.card_giftcard_rounded,
          iconBgColor: const Color(0xFFF1F5F9),
          iconColor: const Color(0xFF334155),
          title: "Granted",
          subtitle: "WELCOME",
          date: "6 OCT 2026",
          amount: "+100",
          tagText: "Blue",
          tagTextColor: const Color(0xFF2563EB),
          balanceText: "Balance: 100",
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String date,
    required String amount,
    required String tagText,
    required Color tagTextColor,
    required String balanceText,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(width: 4),
                Text(tagText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tagTextColor)),
              ],
            ),
            const SizedBox(height: 4),
            Text(balanceText, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }
}
