import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/data/model/challenge_pack/PackSubdomainModel.dart';
import 'package:job_world/data/model/challenge_pack/PackSubcategoryModel.dart';
import 'package:job_world/ui/home/ChallengePackViewModel.dart';
import 'package:job_world/ui/home/challenge_pack_nav_args.dart';

class ChallengePackTopicsScreen extends ConsumerStatefulWidget {
  final ChallengePackTopicArgs args;

  const ChallengePackTopicsScreen({super.key, required this.args});

  @override
  ConsumerState<ChallengePackTopicsScreen> createState() => _ChallengePackTopicsScreenState();
}

class _ChallengePackTopicsScreenState extends ConsumerState<ChallengePackTopicsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.args.isMcq) {
        ref.read(challengePackViewModelProvider.notifier).fetchMcqSubdomains(widget.args.id);
      } else {
        ref.read(challengePackViewModelProvider.notifier).fetchCodingSubcategories(widget.args.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final packState = ref.watch(challengePackViewModelProvider);

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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimensions.verticalSpace(context, 10),
            Text(
              "Choose Your Learning Mode",
              style: TextStyle(fontSize: Dimensions.xlargeTextSize(context) + 4, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Dimensions.verticalSpace(context, 8),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey.shade600, height: 1.5),
                children: [
                  const TextSpan(text: "Select how you want to approach the "),
                  TextSpan(text: widget.args.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const TextSpan(text: " syllabus today."),
                ],
              ),
            ),
            Dimensions.verticalSpace(context, 25),
            widget.args.isMcq ? _buildMcqSubdomains(context, packState) : _buildCodingSubcategories(context, packState),
            Dimensions.verticalSpace(context, 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMcqSubdomains(BuildContext context, ChallengePackState packState) {
    final subdomainsAsync = packState.mcqSubdomains[widget.args.id] ?? const AsyncValue.loading();

    return subdomainsAsync.when(
      data: (subdomains) {
        if (subdomains.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text("No subdomains available.", style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subdomains.length,
          separatorBuilder: (context, index) => Dimensions.verticalSpace(context, 16),
          itemBuilder: (context, index) => _buildSubdomainCard(context, subdomains[index]),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Text("Failed to load subdomains.", style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref.read(challengePackViewModelProvider.notifier).fetchMcqSubdomains(widget.args.id, force: true),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodingSubcategories(BuildContext context, ChallengePackState packState) {
    final subcatsAsync = packState.codingSubcategories[widget.args.id] ?? const AsyncValue.loading();

    return subcatsAsync.when(
      data: (subcats) {
        if (subcats.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text("No subcategories available.", style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subcats.length,
          separatorBuilder: (context, index) => Dimensions.verticalSpace(context, 16),
          itemBuilder: (context, index) => _buildSubcategoryCard(context, subcats[index]),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Text("Failed to load subcategories.", style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref.read(challengePackViewModelProvider.notifier).fetchCodingSubcategories(widget.args.id, force: true),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubdomainCard(BuildContext context, PackSubdomainModel subdomain) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.quiz_rounded, color: AppColors.primaryBlue, size: Dimensions.level2Margin(context) + 12),
              ),
              Dimensions.horizontalSpace(context, 12),
              Expanded(
                child: Text(
                  subdomain.subdomainName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
                ),
              ),
            ],
          ),
          Dimensions.verticalSpace(context, 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subdomain.difficulties.map((d) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "${d.difficulty}: ${d.availableQuestions}",
                  style: TextStyle(fontSize: Dimensions.superSmallTextSize(context) + 1, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                ),
              );
            }).toList(),
          ),
          Dimensions.verticalSpace(context, 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  AppRoutes.challengePackMcqExams,
                  extra: ChallengePackExamsArgs(subdomainId: subdomain.subdomainId, subdomainName: subdomain.subdomainName),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
                minimumSize: Size(0, Dimensions.level3Margin(context) + 20),
              ),
              child: Text("Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(BuildContext context, PackSubcategoryModel subcategory) {
    return Container(
      padding: EdgeInsets.all(Dimensions.level3Margin(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.code_rounded, color: const Color(0xFF16A34A), size: Dimensions.level2Margin(context) + 12),
          ),
          Dimensions.horizontalSpace(context, 12),
          Expanded(
            child: Text(
              subcategory.subcatName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 1),
            ),
          ),
          Dimensions.horizontalSpace(context, 12),
          ElevatedButton(
            onPressed: () {
              context.push(
                AppRoutes.challengePackCodingQuestions,
                extra: ChallengePackQuestionsArgs(subcategoryId: subcategory.id, subcategoryName: subcategory.subcatName),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 4),
              minimumSize: Size(0, Dimensions.level3Margin(context) + 20),
            ),
            child: Text("Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.utilizationTextSize(context) + 1)),
          ),
        ],
      ),
    );
  }
}
