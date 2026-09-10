import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

class QuestResultsScreen extends StatelessWidget {
  const QuestResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: Dimensions.level2Margin(context) + 12),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          "Solve Quest",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
        children: [
          _buildResultCard(
            context: context,
            status: "Accepted",
            statusColor: Colors.green,
            date: "Jul 31, 2026 • 14:21 IST",
            score: "10/10",
            runtime: "0.02s",
            memory: "1.2 MB",
            language: "C (GCC)",
            isPass: true,
          ),
          Dimensions.verticalSpace(context, 20),
          _buildResultCard(
            context: context,
            status: "Accepted",
            statusColor: Colors.green,
            date: "Jul 31, 2026 • 14:21 IST",
            score: "10/10",
            runtime: "0.02s",
            memory: "1.2 MB",
            language: "C (GCC)",
            isPass: true,
          ),
          Dimensions.verticalSpace(context, 20),
          _buildResultCard(
            context: context,
            status: "Wrong Answer",
            statusColor: Colors.red,
            date: "Jul 30, 2026 • 11:04 IST",
            score: "0/10",
            runtime: "0.01s",
            memory: "1.1 MB",
            language: "C (GCC)",
            isPass: false,
          ),
          Dimensions.verticalSpace(context, 20),
          _buildResultCard(
            context: context,
            status: "Wrong Answer",
            statusColor: Colors.red,
            date: "Jul 30, 2026 • 11:04 IST",
            score: "0/10",
            runtime: "0.01s",
            memory: "1.1 MB",
            language: "C (GCC)",
            isPass: false,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required BuildContext context,
    required String status,
    required Color statusColor,
    required String date,
    required String score,
    required String runtime,
    required String memory,
    required String language,
    required bool isPass,
  }) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.level2Margin(context) + 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(isPass ? Icons.check_rounded : Icons.close_rounded, color: statusColor, size: Dimensions.level2Margin(context) + 16),
              ),
              Dimensions.horizontalSpace(context, 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          status,
                          style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        ),
                        Dimensions.horizontalSpace(context, 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.level2Margin(context),
                            vertical: Dimensions.level0Padding(context),
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPass ? "PASS" : "FAIL",
                            style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) - 1, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    Dimensions.verticalSpace(context, 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: Dimensions.utilizationTextSize(context), color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.level2Margin(context) + 4,
                  vertical: Dimensions.level2Margin(context),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: isPass ? AppColors.primaryBlue : Colors.grey.shade400, size: Dimensions.level3Margin(context)),
                    Dimensions.horizontalSpace(context, 4),
                    Text(
                      score,
                      style: TextStyle(
                        fontSize: Dimensions.utilizationTextSize(context) + 2,
                        fontWeight: FontWeight.bold,
                        color: isPass ? const Color(0xFF1E293B) : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Dimensions.verticalSpace(context, 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(context, Icons.access_time_rounded, "RUNTIME", runtime),
              _buildMetricItem(context, Icons.memory_rounded, "MEMORY", memory),
              _buildMetricItem(context, Icons.code_rounded, "LANGUAGE", language, isLang: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, IconData icon, String label, String value, {bool isLang = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade300),
            Dimensions.horizontalSpace(context, 8),
            Text(
              label,
              style: TextStyle(fontSize: Dimensions.superSmallTextSize(context), fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 0.5),
            ),
          ],
        ),
        Dimensions.verticalSpace(context, 6),
        Row(
          children: [
            if (isLang) ...[
               Icon(Icons.circle, size: Dimensions.level1Margin(context) + 2, color: Colors.blue),
               Dimensions.horizontalSpace(context, 6),
            ],
            Text(
              value,
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 1, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
      ],
    );
  }
}