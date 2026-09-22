import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/ui/home/home_screen.dart';
import 'package:job_world/ui/login/LoginScreen.dart';
import 'package:job_world/ui/profile/profile_screen.dart';
import 'package:job_world/ui/register/RegisterScreen.dart';
import 'package:job_world/ui/splash/splash_screen.dart';
import 'package:job_world/ui/profile/EditProfileScreen.dart';
import 'package:job_world/ui/profile/profile_detail_screen.dart';
import 'package:job_world/ui/register/VerifyOTPScreen.dart';
import 'package:job_world/ui/resume_builder/AiWorkspaceScreen.dart';
import 'package:job_world/ui/resume_builder/ResumeBuilderDashboard.dart';
import 'package:job_world/ui/resume_builder/resume_preview_screen.dart';
import 'package:job_world/ui/resume_builder/TemplateListScreen.dart';
import 'package:job_world/ui/resume_builder/JdFitmentResultScreen.dart';
import 'package:job_world/data/model/resume/JdFitmentModel.dart';
import 'package:job_world/ui/home/practice_screen.dart';
import 'package:job_world/ui/main_navigation_screen.dart';
import 'package:job_world/ui/profile/feedback_screen.dart';
import 'package:job_world/ui/home/language_detail_screen.dart';
import 'package:job_world/ui/home/question_list_screen.dart';
import 'package:job_world/ui/home/coding_test_ready_screen.dart';
import 'package:job_world/ui/home/mcq_challenges_screen.dart';
import 'package:job_world/ui/home/exam_setup_screen.dart';
import 'package:job_world/ui/home/examination_screen.dart';
import 'package:job_world/ui/home/ai_interview_screen.dart';
import 'package:job_world/ui/home/algorithm_challenge_screen.dart';
import 'package:job_world/ui/home/quest_ready_screen.dart';
import 'package:job_world/ui/home/quest_results_screen.dart';
import 'package:job_world/ui/home/arena_contests_screen.dart';
import 'package:job_world/ui/credit/credit_screen.dart';
import 'package:job_world/ui/credit/credit_history_screen.dart';
import 'package:job_world/ui/home/challenge_pack_list_screen.dart';
import 'package:job_world/ui/home/challenge_pack_topics_screen.dart';
import 'package:job_world/ui/home/challenge_pack_exams_screen.dart';
import 'package:job_world/ui/home/challenge_pack_coding_questions_screen.dart';
import 'package:job_world/ui/home/challenge_pack_nav_args.dart';
import 'package:job_world/data/model/profile/ResumeTemplateModel.dart';
import 'package:job_world/data/model/practice/PracticeCategoryModel.dart';
import 'package:job_world/data/model/practice/PracticeSubcategoryModel.dart';
import 'package:job_world/data/model/practice/PracticeQuestionModel.dart';
import 'package:job_world/data/model/exam/McqExamModel.dart';
import 'package:job_world/ui/tl/tl_main_navigation_screen.dart';
import 'package:job_world/ui/tl/home/tl_home_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_job_listings_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_job_detail_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_post_job_screen.dart';
import 'package:job_world/data/model/jobpost/TlJobPostModel.dart';
import 'package:job_world/ui/tl/jobs/tl_walkin_cv_pool_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_add_remark_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_timeline_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_hiring_report_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'app_navigator.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const register = "/register";
  static const verifyOtp = "/verify-otp";
  static const home = "/home";
  static const profileDetails = "/profile-details";
  static const profile = "/profile";
  static const editProfile = "/edit-profile";
  static const feedback = "/feedback";
  static const onboarding = "/leadingScreen";
  static const resumeBuilder = "/resume-builder";
  static const templateList = "/template-list";
  static const aiWorkspace = "/ai-workspace";
  static const jdFitmentResult = "/jd-fitment-result";
  static const resumePreview = "/resume-preview";
  static const practice = "/practice";
  static const languageDetail = "language-detail";
  static const questionList = "question-list";
  static const codingTestReady = "/coding-test-ready";
  static const mcqChallenges = "/mcq-challenges";
  static const examSetup = "/exam-setup";
  static const examination = "/examination";
  static const aiInterview = "/ai-interview";
  static const algorithmChallenge = "/algorithm-challenge";
  static const questReady = "/quest-ready";
  static const questResults = "/quest-results";
  static const arenaContests = "/arena-contests";
  static const credit = "/credit";
  static const creditHistory = "/credit-history";
  static const challengePacks = "/challenge-packs";
  static const challengePackTopics = "/challenge-pack-topics";
  static const challengePackMcqExams = "/challenge-pack-mcq-exams";
  static const challengePackCodingQuestions = "/challenge-pack-coding-questions";

  // TL Flow Routes
  static const tlMainNavigation = "/tl-main-navigation";
  static const tlHome = "/tl-home";
  static const tlJobListings = "/tl-job-listings";
  static const tlJobDetail = "/tl-job-detail";
  static const tlPostJob = "/tl-post-job";
  static const tlWalkinCvPool = "/tl-walkin-cv-pool";
  static const tlAddRemark = "/tl-add-remark";
  static const tlTimeline = "/tl-timeline";
  static const tlHiringReport = "/tl-hiring-report";
}

final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _jobsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'jobs');
final GlobalKey<NavigatorState> _examsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'exams');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: navigatorKey,

  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyOtp,
      builder: (context, state) {
        final email = state.extra as String? ?? "";
        return VerifyOTPScreen(email: email);
      },
    ),
    
    // StatefulShellRoute for Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: HOME
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch 1: JOBS (Placeholder)
        StatefulShellBranch(
          navigatorKey: _jobsNavigatorKey,
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const Scaffold(body: Center(child: Text("Jobs Screen"))),
            ),
          ],
        ),
        // Branch 2: EXAMS (Practice Screen)
        StatefulShellBranch(
          navigatorKey: _examsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.practice,
              builder: (context, state) => const PracticeScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.languageDetail,
                  builder: (context, state) {
                    final extra = state.extra;
                    if (extra is PracticeCategoryModel) {
                      return LanguageDetailScreen(
                        category: extra,
                        languageName: extra.categoryName,
                      );
                    }
                    if (extra is Map<String, dynamic>) {
                      return LanguageDetailScreen(
                        categoryId: extra['id'] as int?,
                        languageName: (extra['name'] ?? extra['Catg_name'] ?? extra['category_name'] ?? "Category Details").toString(),
                      );
                    }
                    if (extra is String) {
                      return LanguageDetailScreen(languageName: extra);
                    }
                    if (extra != null) {
                      try {
                        final dynamic dyn = extra;
                        final String name = (dyn.categoryName ?? dyn.Catg_name ?? dyn.name ?? "Category Details").toString();
                        final int? id = dyn.id is int ? dyn.id as int : int.tryParse(dyn.id.toString());
                        return LanguageDetailScreen(
                          categoryId: id,
                          languageName: name,
                        );
                      } catch (_) {}
                    }
                    return const LanguageDetailScreen(languageName: "Category Details");
                  },
                  routes: [
                    GoRoute(
                      path: AppRoutes.questionList,
                      builder: (context, state) {
                        final extra = state.extra;
                        if (extra is PracticeSubcategoryModel) {
                          return QuestionListScreen(
                            subcategory: extra,
                            title: extra.subcategoryName,
                          );
                        }
                        if (extra is Map<String, dynamic>) {
                          return QuestionListScreen(
                            subCategoryId: extra['id'] as int?,
                            title: (extra['name'] ?? extra['subcat_name'] ?? "Question List").toString(),
                          );
                        }
                        if (extra is String) {
                          return QuestionListScreen(title: extra);
                        }
                        if (extra != null) {
                          try {
                            final dynamic dyn = extra;
                            final String title = (dyn.subcategoryName ?? dyn.subcat_name ?? dyn.name ?? "Question List").toString();
                            final int? id = dyn.id is int ? dyn.id as int : int.tryParse(dyn.id.toString());
                            return QuestionListScreen(
                              subCategoryId: id,
                              title: title,
                            );
                          } catch (_) {}
                        }
                        return const QuestionListScreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Branch 3: PROFILE
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                // Edit Profile as a sub-route of Profile to keep bottom nav
                GoRoute(
                  path: AppRoutes.editProfile,
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: AppRoutes.feedback,
                  builder: (context, state) => const FeedbackScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.profileDetails,
      builder: (context, state) => const ProfileDetailScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.feedback,
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(
      path: AppRoutes.resumeBuilder,
      builder: (context, state) => const ResumeBuilderDashboard(),
    ),
    GoRoute(
      path: AppRoutes.templateList,
      builder: (context, state) => const TemplateListScreen(),
    ),
    GoRoute(
      path: AppRoutes.aiWorkspace,
      builder: (context, state) => const AiWorkspaceScreen(),
    ),
    GoRoute(
      path: AppRoutes.jdFitmentResult,
      builder: (context, state) {
        if (state.extra is JdFitmentModel) {
          return JdFitmentResultScreen(fitment: state.extra as JdFitmentModel);
        }
        return Scaffold(
          appBar: AppBar(title: const Text("JD Match Results")),
          body: const Center(child: Text("No fitment results available.")),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resumePreview,
      builder: (context, state) {
        if (state.extra is ResumeTemplateModel) {
          return ResumePreviewScreen(template: state.extra as ResumeTemplateModel);
        }
        final templateType = state.extra as String? ?? 'classic';
        return ResumePreviewScreen(templateType: templateType);
      },
    ),
    GoRoute(
      path: AppRoutes.codingTestReady,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is PracticeQuestionModel) {
          return CodingTestReadyScreen(question: extra);
        }
        if (extra != null && extra is! String) {
          try {
            final dynamic dyn = extra;
            return CodingTestReadyScreen(question: dyn as PracticeQuestionModel);
          } catch (_) {}
        }
        return const CodingTestReadyScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.mcqChallenges,
      builder: (context, state) => const McqChallengesScreen(),
    ),
    GoRoute(
      path: AppRoutes.examSetup,
      builder: (context, state) {
        if (state.extra is McqExamModel) {
          return ExamSetupScreen(exam: state.extra as McqExamModel);
        }
        return const ExamSetupScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.examination,
      builder: (context, state) {
        if (state.extra is McqExamModel) {
          return ExaminationScreen(exam: state.extra as McqExamModel);
        }
        if (state.extra is int) {
          return ExaminationScreen(examId: state.extra as int);
        }
        return const ExaminationScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.aiInterview,
      builder: (context, state) => const AiInterviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.algorithmChallenge,
      builder: (context, state) => const AlgorithmChallengeScreen(),
    ),
    GoRoute(
      path: AppRoutes.questReady,
      builder: (context, state) => const QuestReadyScreen(),
    ),
    GoRoute(
      path: AppRoutes.questResults,
      builder: (context, state) => const QuestResultsScreen(),
    ),
    GoRoute(
      path: AppRoutes.arenaContests,
      builder: (context, state) => const ArenaContestsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRoutes.credit,
      builder: (context, state) => const CreditScreen(),
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRoutes.creditHistory,
      builder: (context, state) => const CreditHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.challengePacks,
      builder: (context, state) => const ChallengePackListScreen(),
    ),
    GoRoute(
      path: AppRoutes.challengePackTopics,
      builder: (context, state) {
        if (state.extra is ChallengePackTopicArgs) {
          return ChallengePackTopicsScreen(args: state.extra as ChallengePackTopicArgs);
        }
        return ChallengePackTopicsScreen(args: ChallengePackTopicArgs(sourceType: 'MCQ', id: 0, name: 'Challenge Pack'));
      },
    ),
    GoRoute(
      path: AppRoutes.challengePackMcqExams,
      builder: (context, state) {
        if (state.extra is ChallengePackExamsArgs) {
          return ChallengePackExamsScreen(args: state.extra as ChallengePackExamsArgs);
        }
        return ChallengePackExamsScreen(args: ChallengePackExamsArgs(subdomainId: 0, subdomainName: 'Exams'));
      },
    ),
    GoRoute(
      path: AppRoutes.challengePackCodingQuestions,
      builder: (context, state) {
        if (state.extra is ChallengePackQuestionsArgs) {
          return ChallengePackCodingQuestionsScreen(args: state.extra as ChallengePackQuestionsArgs);
        }
        return ChallengePackCodingQuestionsScreen(args: ChallengePackQuestionsArgs(subcategoryId: 0, subcategoryName: 'Questions'));
      },
    ),
    GoRoute(
      path: AppRoutes.tlMainNavigation,
      builder: (context, state) => const TlMainNavigationScreen(),
    ),
    GoRoute(
      path: AppRoutes.tlHome,
      builder: (context, state) => const TlHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.tlJobListings,
      builder: (context, state) => const TlJobListingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.tlJobDetail,
      builder: (context, state) {
        final jobId = state.extra is int ? state.extra as int : 0;
        return TlJobDetailScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.tlPostJob,
      builder: (context, state) {
        final existingJob = state.extra is TlJobPostModel ? state.extra as TlJobPostModel : null;
        return TlPostJobScreen(existingJob: existingJob);
      },
    ),
    GoRoute(
      path: AppRoutes.tlWalkinCvPool,
      builder: (context, state) {
        if (state.extra is! TlJobModel) return const TlNoDataScreen();
        return TlWalkinCvPoolScreen(job: state.extra as TlJobModel);
      },
    ),
    GoRoute(
      path: AppRoutes.tlAddRemark,
      builder: (context, state) {
        final candidate = state.extra is TlCandidateModel ? state.extra as TlCandidateModel : null;
        return TlAddRemarkScreen(candidate: candidate);
      },
    ),
    GoRoute(
      path: AppRoutes.tlTimeline,
      builder: (context, state) {
        final candidate = state.extra is TlCandidateModel ? state.extra as TlCandidateModel : null;
        return TlTimelineScreen(candidate: candidate);
      },
    ),
    GoRoute(
      path: AppRoutes.tlHiringReport,
      builder: (context, state) {
        final candidate = state.extra is TlCandidateModel ? state.extra as TlCandidateModel : null;
        return TlHiringReportScreen(candidate: candidate);
      },
    ),
  ],
);