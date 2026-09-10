import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

class QuestReadyScreen extends StatelessWidget {
  const QuestReadyScreen({super.key});

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
      body: Padding(
        padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
        child: Column(
          children: [
            const Spacer(),
            // Illustration
            Container(
              height: Dimensions.level5Size(context) + 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.laptop_mac_rounded, size: Dimensions.level3Size(context), color: AppColors.primaryBlue),
            ),
            Dimensions.verticalSpace(context, 40),
            Text(
              "Your Test is Ready!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.xlargeTextSize(context) + 2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Dimensions.verticalSpace(context, 32),
            _buildInfoRow(
              context: context,
              icon: Icons.laptop_rounded,
              text: "Please use a laptop/desktop for the best experience.",
            ),
            Dimensions.verticalSpace(context, 24),
            _buildInfoRow(
              context: context,
              icon: Icons.shield_outlined,
              text: "This round must be completed on a laptop or desktop and cannot be started on mobile.",
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              height: Dimensions.level1Size(context) + 6,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.questResults),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  "Alright",
                  style: TextStyle(fontSize: Dimensions.largeTextSize(context) + 3, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Dimensions.verticalSpace(context, 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required BuildContext context, required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
        ),
        Dimensions.horizontalSpace(context, 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Dimensions.utilizationTextSize(context) + 2,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
