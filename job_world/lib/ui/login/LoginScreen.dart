import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/ui/login/LoginViewModel.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import '../../routes/AppRoute.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginState loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF7F7FB),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/png/bg_login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: Dimensions.level4Margin(context)),
                Image.asset(
                  "assets/png/main_logo.png",
                  height: Dimensions.level1Size(context),
                ),
                const SizedBox(height: 25),
                _buildHeader(context),
                const SizedBox(height: 10),
                _buildSubHeader(context),
                const SizedBox(height: 1),
                _buildLoginForm(context, loginState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: Dimensions.xlargeTextSize(context),
          fontFamily: "ManRope",
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        children: const [
          TextSpan(text: "Welcome Back "),
          TextSpan(
            text: "to Job World.",
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        "Log in to continue building skills, tracking performance and managing hiring workflows.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
          fontSize: Dimensions.mediumTextSize(context),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, LoginState loginState) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login to your account",
              style: TextStyle(
                fontSize: Dimensions.xlargeTextSize(context),
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 30),
            _buildLabel("Username", context),
            const SizedBox(height: 10),
            _buildUsernameField(),
            const SizedBox(height: 20),
            _buildLabel("Password", context),
            const SizedBox(height: 8),
            _buildPasswordField(),
            _buildForgotPassword(),
            const SizedBox(height: 20),
            _buildLoginButton(context, loginState),
            const SizedBox(height: 20),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Dimensions.mediumTextSize(context),
        fontWeight: FontWeight.w600,
        color: const Color(0xFF444655),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      validator: (value) =>
          (value == null || value.isEmpty) ? "Please enter username" : null,
      decoration: _inputDecoration(
        hintText: "Enter your username",
        iconPath: 'assets/svg/ic_username.svg',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (value) =>
          (value == null || value.isEmpty) ? "Please enter password" : null,
      decoration: _inputDecoration(
        hintText: "Password",
        iconPath: 'assets/svg/ic_password.svg',
        isPassword: true,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required String iconPath,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: isPassword ? const ColorFilter.mode(Colors.grey, BlendMode.srcIn) : null,
        ),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: _outlineBorder(const Color(0xFFF8FAFB), 0.5),
      enabledBorder: _outlineBorder(const Color(0xFFE2E8F0), 1),
      focusedBorder: _outlineBorder(const Color(0xFFB3B4FF), 1),
      errorBorder: _outlineBorder(Colors.red, 1),
      focusedErrorBorder: _outlineBorder(Colors.red, 1.5),
    );
  }

  OutlineInputBorder _outlineBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          "Forgot password?",
          style: TextStyle(color: Color(0xFF667FE3)),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState loginState) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: loginState.isLoading
            ? null
            : () {
                if (_loginFormKey.currentState!.validate()) {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text.trim();
                  ref.read(loginViewModelProvider.notifier).login(username, password, context);
                }
              },
        child: loginState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Login",
                style: TextStyle(
                  fontSize: Dimensions.mediumTextSize(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.white
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.register),
          child: const Text(
            "Create Account",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}