import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/app_preferences.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchAllProfileData();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.level4Margin(context) - 8,
            vertical: Dimensions.level4Margin(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.level3Margin(context)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.logout_rounded, color: const Color(0xFF434EBD), size: Dimensions.level4Margin(context) - 2),
              ),
              Dimensions.verticalSpace(context, 24),
              Text(
                "Log Out?",
                style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Dimensions.verticalSpace(context, 12),
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Dimensions.utilizationTextSize(context) + 2, color: Colors.grey, height: 1.5),
              ),
              Dimensions.verticalSpace(context, 32),
              SizedBox(
                width: double.infinity,
                height: Dimensions.level1Size(context) + 4,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(innerContext);
                    await AppPreferences.clear();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B46F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text("Log Out", style: TextStyle(fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.bold)),
                ),
              ),
              Dimensions.verticalSpace(context, 12),
              TextButton(
                onPressed: () => Navigator.pop(innerContext),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey, fontSize: Dimensions.level3Margin(context), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final profile = profileState.profile.valueOrNull;

    final String name = (profile != null && profile.firstName.isNotEmpty)
        ? "${profile.firstName} ${profile.lastName}".trim()
        : "Abc User";
    final String candidateType = (profile != null && profile.candidateType != null && profile.candidateType!.isNotEmpty)
        ? profile.candidateType!
        : "Professional";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.level3Margin(context) + 4,
            vertical: Dimensions.level3Margin(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Dimensions.level1Padding(context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(
                          Icons.person_rounded,
                          size: Dimensions.level1Size(context),
                          color: const Color(0xFF434EBD),
                        ),
                      ),
                    ),
                    Dimensions.verticalSpace(context, 16),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: Dimensions.xlargeTextSize(context),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E2448),
                      ),
                    ),
                    Dimensions.verticalSpace(context, 4),
                    Text(
                      candidateType,
                      style: TextStyle(
                        fontSize: Dimensions.utilizationTextSize(context) + 2,
                        color: const Color(0xFF8B92A7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Dimensions.verticalSpace(context, 24),
              // Stats Card
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.level3Margin(context) + 4,
                  horizontal: Dimensions.level3Margin(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF434EBD).withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, '${profileState.completionPercentage.toInt()}%', 'PROFILE SCORE'),
                    Container(width: 1, height: Dimensions.level1Margin(context) + 31, color: const Color(0xFFEEF1F6)),
                    _buildStatItem(context, '124', 'CREDITS'),
                    Container(width: 1, height: Dimensions.level1Margin(context) + 31, color: const Color(0xFFEEF1F6)),
                    _buildStatItem(context, '48', 'EXAMS'),
                  ],
                ),
              ),
              Dimensions.verticalSpace(context, 30),

              // Account Settings Title
              Text(
                'ACCOUNT SETTINGS',
                style: TextStyle(
                  fontSize: Dimensions.utilizationTextSize(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B92A7),
                  letterSpacing: 1.0,
                ),
              ),
              Dimensions.verticalSpace(context, 14),

              // Settings Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF434EBD).withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        context: context,
                        icon: Icons.edit_outlined,
                        iconBgColor: const Color(0xFFEEF2FF),
                        iconColor: const Color(0xFF434EBD),
                        title: 'Edit Profile',
                        onTap: () {
                          context.push(AppRoutes.editProfile);
                        },
                      ),
                      const Divider(height: 1, indent: 70, endIndent: 20, color: Color(0xFFF1F4F9)),
                      _buildSettingItem(
                        context: context,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconBgColor: const Color(0xFFEEF2FF),
                        iconColor: const Color(0xFF434EBD),
                        title: 'Feedback',
                        onTap: () {
                          context.push(AppRoutes.feedback);
                        },
                      ),
                      const Divider(height: 1, indent: 70, endIndent: 20, color: Color(0xFFF1F4F9)),
                      _buildSettingItem(
                        context: context,
                        icon: Icons.shield_outlined,
                        iconBgColor: const Color(0xFFEEF2FF),
                        iconColor: const Color(0xFF434EBD),
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 30),

              // Log Out Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: Icon(Icons.logout_rounded, color: Colors.white, size: Dimensions.level3Margin(context) + 4),
                  label: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B46F3),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.level4Margin(context),
                      vertical: Dimensions.level3Margin(context) - 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 90), // Space for bottom navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.xlargeTextSize(context) - 2,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E2448),
          ),
        ),
        Dimensions.verticalSpace(context, 4),
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.navigationTitleSize(context),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF434EBD),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dimensions.level3Margin(context) + 4,
        vertical: Dimensions.stepperMargin(context),
      ),
      leading: Container(
        padding: EdgeInsets.all(Dimensions.level2Margin(context) + 2),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: Dimensions.utilizationTextSize(context) + 10),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Dimensions.utilizationTextSize(context) + 3,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E2448),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: const Color(0xFF8B92A7),
        size: Dimensions.level4Margin(context) - 2,
      ),
      onTap: onTap,
    );
  }
}