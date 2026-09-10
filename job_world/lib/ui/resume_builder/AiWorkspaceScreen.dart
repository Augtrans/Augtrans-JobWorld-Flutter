import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/ui/resume_builder/TemplateViewModel.dart';

class AiWorkspaceScreen extends ConsumerStatefulWidget {
  const AiWorkspaceScreen({super.key});

  @override
  ConsumerState<AiWorkspaceScreen> createState() => _AiWorkspaceScreenState();
}

class _AiWorkspaceScreenState extends ConsumerState<AiWorkspaceScreen> {
  final TextEditingController _jdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _calculateMatchScore() async {
    final jdText = _jdController.text.trim();
    if (jdText.isEmpty) {
      CommonMethods.showSnackBar(
        context,
        "Please paste or enter target job description text.",
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(resumeRepositoryProvider);
      final fitmentResult = await repository.calculateJdFitment(jdText);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.push(AppRoutes.jdFitmentResult, extra: fitmentResult);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = CommonMethods.extractErrorMessage(e);
        CommonMethods.showSnackBar(
          context,
          errorMessage,
          backgroundColor: Colors.red.shade700,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: Dimensions.level2Margin(context) + 16),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "AI Resume Workspace",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
        child: Column(
          children: [
            _buildInputCard(context),
            Dimensions.verticalSpace(context, 25),
            _buildProTip(context),
            Dimensions.verticalSpace(context, 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(context),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5F3FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.assignment_outlined, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 16),
              ),
              Dimensions.horizontalSpace(context, 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Paste Target Job Description",
                      style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) - 4, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    Dimensions.verticalSpace(context, 10),
                    Text(
                      "Drop the full text requirements, responsibilities, or raw job posting details below to automatically check your compatibility rate.",
                      style: TextStyle(color: const Color(0xFF64748B), fontSize: Dimensions.utilizationTextSize(context), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 25),
          Container(
            height: Dimensions.level7Size(context) - 80,
            padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _jdController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: "Paste the target job description text here (including roles, qualifications, and core technical skill requirements)...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: Dimensions.utilizationTextSize(context) + 1, height: 1.5),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: const Color(0xFF334155), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTip(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context)),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
          ),
          Dimensions.horizontalSpace(context, 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pro Tip",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 2, color: const Color(0xFF1E293B)),
                ),
                Dimensions.verticalSpace(context, 4),
                Text(
                  "Ensure you include the 'Required Skills' and 'Minimum Qualifications' sections for the most accurate score.",
                  style: TextStyle(color: const Color(0xFF64748B), fontSize: Dimensions.utilizationTextSize(context), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: Dimensions.level1Size(context) + 5,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _calculateMatchScore,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  "Calculate Match Score",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Dimensions.level3Margin(context)),
                ),
        ),
      ),
    );
  }
}
