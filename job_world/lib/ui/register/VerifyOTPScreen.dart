import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/ui/register/RegisterViewModel.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import '../../core/networking/api_exception.dart';
import '../../routes/AppRoute.dart';

class VerifyOTPScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyOTPScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends ConsumerState<VerifyOTPScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToVerificationState();

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    "assets/png/main_logo.png",
                    height: Dimensions.level1Size(context),
                  ),
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildSubHeader(),
                  const SizedBox(height: 40),
                  _buildOtpForm(),
                  const SizedBox(height: 30),
                  _buildVerifyButton(),
                  const SizedBox(height: 20),
                  _buildResendText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listenToVerificationState() {
    // Listen to Registration Status (Step 1 in the new flow)
    ref.listen(registerViewModelProvider.select((s) => s.registrationStatus), (previous, next) {
      next.maybeWhen(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration Error: ${_extractErrorMessage(error)}")),
          );
        },
        orElse: () {},
      );
    });

    // Listen to OTP Verification Status (Step 2)
    ref.listen(registerViewModelProvider.select((s) => s.otpVerificationStatus), (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account verified successfully!")),
            );
            context.go(AppRoutes.login);
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification Error: ${_extractErrorMessage(error)}")),
          );
        },
        loading: () {},
      );
    });
  }

  String _extractErrorMessage(Object error) {
    if (error is ApiException && error.data != null && error.data is Map) {
      final Map<String, dynamic> errorData = Map<String, dynamic>.from(error.data);
      if (errorData.isNotEmpty) {
        final firstKey = errorData.keys.first;
        final firstValue = errorData[firstKey];
        if (firstValue is List && firstValue.isNotEmpty) {
          return "$firstKey: ${firstValue.first}";
        } else if (firstValue is String) {
          return "$firstKey: $firstValue";
        }
      }
    }
    return error.toString();
  }

  Widget _buildHeader() {
    return const Text(
      "Verify Account",
      style: TextStyle(
        fontSize: 24,
        fontFamily: "ManRope",
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubHeader() {
    return Text(
      "Enter the 6-digit code sent to ${widget.email}",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 14,
        fontFamily: "ManRope",
      ),
    );
  }

  Widget _buildOtpForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
            onChanged: (value) => _onOtpChanged(value, index),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final registrationStatus = ref.watch(registerViewModelProvider.select((s) => s.registrationStatus));
    final otpStatus = ref.watch(registerViewModelProvider.select((s) => s.otpVerificationStatus));
    
    final isLoading = registrationStatus is AsyncLoading || otpStatus is AsyncLoading;

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
        onPressed: isLoading
            ? null
            : () {
                String otp = _controllers.map((e) => e.text).join();
                if (otp.length == 6) {
                  ref.read(registerViewModelProvider.notifier).verifyOtp(widget.email, otp);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter complete 6-digit OTP")),
                  );
                }
              },
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "Verify",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildResendText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive code? "),
        GestureDetector(
          onTap: () {

          },
          child: const Text(
            "Resend Code",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
