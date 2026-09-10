import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/core/networking/api_exception.dart';
import 'package:job_world/data/model/register/OrganizationModel.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'RegisterViewModel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isIndividual = true;
  bool _isAdmin = true;
  int _orgAdminStep = 1;

  final _registrationFormKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _adminOrgNameController = TextEditingController();
  final TextEditingController _nonAdminOrgNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _orgSizeController = TextEditingController();

  int? _selectedRoleId;
  int? _selectedOrgId;
  int? _selectedDeptId;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gstinController.dispose();
    _adminOrgNameController.dispose();
    _nonAdminOrgNameController.dispose();
    _countryController.dispose();
    _orgSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listenToRegistrationState();
    _listenToOrgCreationState();

    return Scaffold(
      body: Form(
        key: _registrationFormKey,
        child: Container(
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
                  const SizedBox(height: 30),
                  _buildLogo(),
                  const SizedBox(height: 30),
                  _buildFormContainer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listenToRegistrationState() {
    ref.listen(registerViewModelProvider.select((s) => s.registrationStatus), (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration successful!")),
            );
            if (_isIndividual) {
              context.go(AppRoutes.verifyOtp, extra: _emailController.text.trim());
            } else {
              context.go('/login');
            }
          }
        },
        error: (error, stack) {
          final errorMessage = _extractErrorMessage(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        loading: () {},
      );
    });
  }

  void _listenToOrgCreationState() {
    ref.listen(registerViewModelProvider.select((s) => s.orgCreationStatus), (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            setState(() {
              _orgAdminStep = 2;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Organization details saved!")),
            );
          }
        },
        error: (error, stack) {
          final errorMessage = _extractErrorMessage(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
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

  Widget _buildLogo() {
    return Image.asset(
      "assets/png/main_logo.png",
      height: Dimensions.smallSize(context),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggle(),
          const SizedBox(height: 30),
          _buildHeader(),
          const SizedBox(height: 25),
          _isIndividual ? _buildIndividualForm() : _buildOrganizationForm(),
          const SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildToggleButton("Individual", _isIndividual, () => setState(() => _isIndividual = true)),
          _buildToggleButton("Organization", !_isIndividual, () => setState(() => _isIndividual = false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontFamily: "ManRope",
              fontSize: Dimensions.mediumTextSize(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = "Create Account";
    if (!_isIndividual && _isAdmin && _orgAdminStep == 2) {
      title = "Verify Email";
    }
    return Text(
      title,
      style: TextStyle(
        fontSize: Dimensions.xlargeTextSize(context),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIndividualForm() {
    final rolesAsync = ref.watch(registerViewModelProvider.select((s) => s.roles));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Username"),
        TextFormField(
          controller: _usernameController,
          validator: (value) => (value == null || value.isEmpty) ? "Please enter your username" : null,
          decoration: _inputDecoration(hintText: "Enter username", prefixIconPath: 'assets/svg/ic_username.svg'),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Select Role"),
        rolesAsync.when(
          data: (roles) {
            final individualRoles = roles.where((role) {
              final name = role.name.toUpperCase();
              return name == "CND" || name == "FREELANCER" || name.contains("CANDIDATE") || name.contains("INDIVIDUAL");
            }).toList();

            return DropdownButtonFormField<int>(
              initialValue: _selectedRoleId,
              validator: (value) => (value == null) ? "Please Select Role" : null,
              decoration: _inputDecoration(prefixIconPath: 'assets/svg/ic_select_role.svg'),
              hint: _buildHintText("Choose Role"),
              items: individualRoles.map((role) {
                String displayName = role.name;
                if (role.name.toUpperCase() == "CND") displayName = "Candidate";
                if (role.name.toUpperCase() == "FREELANCER") displayName = "Freelancer";
                return DropdownMenuItem(value: role.id, child: Text(displayName));
              }).toList(),
              onChanged: (value) => setState(() => _selectedRoleId = value),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => DropdownButtonFormField<int>(
            decoration: _inputDecoration(prefixIconPath: 'assets/svg/ic_select_role.svg'),
            hint: _buildHintText("Choose Role"),
            items: const [],
            onChanged: null,
          ),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Email"),
        TextFormField(
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
            return null;
          },
          decoration: _inputDecoration(hintText: "Enter email", prefixIconPath: 'assets/svg/ic_email.svg'),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Password"),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
          decoration: _inputDecoration(
            hintText: "Enter password",
            prefixIconPath: 'assets/svg/ic_password.svg',
            isPassword: true,
            isObscured: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Confirm Password"),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (value) => (value != _passwordController.text) ? 'Passwords do not match' : null,
          decoration: _inputDecoration(
            hintText: "Enter confirm password",
            prefixIconPath: 'assets/svg/ic_password.svg',
            isPassword: true,
            isObscured: _obscureConfirmPassword,
            onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        const SizedBox(height: 30),
        _buildActionButton("Register", () {
          if (_registrationFormKey.currentState!.validate()) {
            ref.read(registerViewModelProvider.notifier).registerIndividual(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              roleId: _selectedRoleId ?? 0,
            );
          }
        }, registrationStatus: ref.watch(registerViewModelProvider.select((s) => s.registrationStatus))),
      ],
    );
  }

  Widget _buildOrganizationForm() {
    final creationStatus = ref.watch(registerViewModelProvider.select((s) => s.orgCreationStatus));
    final registrationStatus = ref.watch(registerViewModelProvider.select((s) => s.registrationStatus));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_orgAdminStep == 1) _buildOrgTabToggle(),
        const SizedBox(height: 25),
        if (_isAdmin) _buildAdminFields() else _buildNonAdminFields(),
        const SizedBox(height: 30),
        _buildActionButton(
          _isAdmin ? (_orgAdminStep == 1 ? "Next" : "Register") : "Register",
          () {
            if (_registrationFormKey.currentState!.validate()) {
              if (_isAdmin) {
                if (_orgAdminStep == 1) {
                  ref.read(registerViewModelProvider.notifier).createOrganization(
                        name: _adminOrgNameController.text,
                        gstin: _gstinController.text,
                        organizationSize: int.tryParse(_orgSizeController.text) ?? 0,
                        country: _countryController.text,
                      );
                } else {
                  ref.read(registerViewModelProvider.notifier).registerOrganizationAdmin(
                        username: _usernameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        roleId: _selectedRoleId ?? 10,
                      );
                }
              } else {
                // Non-Admin logic
                ref.read(registerViewModelProvider.notifier).registerOrganizationNonAdmin(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  roleId: _selectedRoleId ?? 11, // Defaulting to EMPLOYEE role id
                  organizationName: _nonAdminOrgNameController.text,
                  departmentId: _selectedDeptId ?? 1,
                );
              }
            }
          },
          registrationStatus: _isAdmin && _orgAdminStep == 1 ? creationStatus : registrationStatus,
        ),
        if (_isAdmin && _orgAdminStep == 2) ...[
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _orgAdminStep = 1),
              child: const Text("Back to Organization Details", style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrgTabToggle() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildSubToggleButton("Admin", _isAdmin, () => setState(() => _isAdmin = true)),
          _buildSubToggleButton("Non-Admin", !_isAdmin, () => setState(() => _isAdmin = false)),
        ],
      ),
    );
  }

  Widget _buildSubToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 1) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryBlue : Colors.black54,
              fontWeight: FontWeight.w600,
              fontFamily: "ManRope",
              fontSize: Dimensions.mediumTextSize(context) * 0.9,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminFields() {
    final rolesAsync = ref.watch(registerViewModelProvider.select((s) => s.roles));

    if (_orgAdminStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Organization Name"),
          TextFormField(
            controller: _adminOrgNameController,
            validator: (value) => (value == null || value.isEmpty) ? "Please enter organization name" : null,
            decoration: _inputDecoration(hintText: "Enter organization name"),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("GSTIN Number"),
          TextFormField(
            controller: _gstinController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter GSTIN number";
              if (value.length != 15) return "GSTIN must be exactly 15 characters";
              return null;
            },
            decoration: _inputDecoration(
              hintText: "Enter GSTIN number",
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("Country"),
          TextFormField(
            controller: _countryController,
            validator: (value) => (value == null || value.isEmpty) ? "Please enter country" : null,
            decoration: _inputDecoration(hintText: "Enter country"),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("Organization Size"),
          TextFormField(
            controller: _orgSizeController,
            keyboardType: TextInputType.number,
            validator: (value) => (value == null || value.isEmpty) ? "Enter organization size" : null,
            decoration: _inputDecoration(hintText: "Enter organization size"),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Username"),
          TextFormField(
            controller: _usernameController,
            validator: (value) => (value == null || value.isEmpty) ? "Please enter username" : null,
            decoration: _inputDecoration(hintText: "Enter username", prefixIconPath: 'assets/svg/ic_username.svg'),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("Email"),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
              return null;
            },
            decoration: _inputDecoration(hintText: "Enter email", prefixIconPath: 'assets/svg/ic_email.svg'),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("Password"),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
            decoration: _inputDecoration(
              hintText: "Enter password",
              prefixIconPath: 'assets/svg/ic_password.svg',
              isPassword: true,
              isObscured: _obscurePassword,
              onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("Select Role"),
          rolesAsync.when(
            data: (roles) => DropdownButtonFormField<int>(
              initialValue: _selectedRoleId,
              validator: (value) => (value == null) ? "Please Select Role" : null,
              decoration: _inputDecoration(prefixIconPath: 'assets/svg/ic_select_role.svg'),
              hint: _buildHintText("Choose Role"),
              items: roles.map((role) => DropdownMenuItem(value: role.id, child: Text(role.name))).toList(),
              onChanged: (value) => setState(() => _selectedRoleId = value),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => DropdownButtonFormField<int>(
              decoration: _inputDecoration(prefixIconPath: 'assets/svg/ic_select_role.svg'),
              hint: _buildHintText("Choose Role"),
              items: const [],
              onChanged: null,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNonAdminFields() {
    final rolesAsync = ref.watch(registerViewModelProvider.select((s) => s.roles));
    final orgsAsync = ref.watch(registerViewModelProvider.select((s) => s.organizations));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Organization Name"),
        orgsAsync.when(
          data: (orgs) => Autocomplete<OrganizationModel>(
            displayStringForOption: (OrganizationModel option) => option.name,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<OrganizationModel>.empty();
              }
              return orgs.where((OrganizationModel option) {
                return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (OrganizationModel selection) {
              setState(() {
                _selectedOrgId = selection.id;
                _nonAdminOrgNameController.text = selection.name;
                _selectedDeptId = null; // Reset department on org change
              });
              // Update state in ViewModel so registration logic knows the org ID
              final notifier = ref.read(registerViewModelProvider.notifier);
              notifier.state = notifier.state.copyWith(createdOrgId: selection.id);
              // Fetch departments for the selected organization
              notifier.fetchDepartments(selection.id);
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter organization name";
                  if (_selectedOrgId == null) return "Please select a valid organization from the suggestions";
                  return null;
                },
                decoration: _inputDecoration(hintText: "Search organization"),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => TextFormField(
            enabled: false,
            decoration: _inputDecoration(hintText: "Error loading organizations"),
          ),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Department"),
        Consumer(
          builder: (context, ref, child) {
            final deptsAsync = ref.watch(registerViewModelProvider.select((s) => s.departments));
            return deptsAsync.when(
              data: (depts) => DropdownButtonFormField<int>(
                initialValue: _selectedDeptId,
                validator: (value) => (value == null) ? "Please select department" : null,
                decoration: _inputDecoration(),
                hint: _buildHintText("Select Department"),
                items: depts.map((dept) => DropdownMenuItem(value: dept.id, child: Text(dept.name))).toList(),
                onChanged: (val) => setState(() => _selectedDeptId = val),
              ),
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (err, stack) => DropdownButtonFormField<int>(
                decoration: _inputDecoration(),
                hint: _buildHintText("Error loading departments"),
                items: const [],
                onChanged: null,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Username"),
        TextFormField(
          controller: _usernameController,
          validator: (value) => (value == null || value.isEmpty) ? "Please enter username" : null,
          decoration: _inputDecoration(hintText: "Enter username", prefixIconPath: 'assets/svg/ic_username.svg'),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Email"),
        TextFormField(
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
            return null;
          },
          decoration: _inputDecoration(hintText: "Enter email", prefixIconPath: 'assets/svg/ic_email.svg'),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Password"),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
          decoration: _inputDecoration(
            hintText: "Enter password",
            prefixIconPath: 'assets/svg/ic_password.svg',
            isPassword: true,
            isObscured: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel("Organization Role"),
        rolesAsync.when(
          data: (roles) => DropdownButtonFormField<int>(
            initialValue: _selectedRoleId,
            validator: (value) => (value == null) ? "Please select role" : null,
            decoration: _inputDecoration(prefixIconPath: 'assets/svg/ic_select_role.svg'),
            hint: _buildHintText("Select Role"),
            items: roles.map((role) => DropdownMenuItem(value: role.id, child: Text(role.name))).toList(),
            onChanged: (val) => setState(() => _selectedRoleId = val),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => DropdownButtonFormField<int>(
            decoration: _inputDecoration(prefixIconPath: 'assets/svg/ic_select_role.svg'),
            hint: _buildHintText("Select Role"),
            items: const [],
            onChanged: null,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: Dimensions.mediumTextSize(context),
            fontWeight: FontWeight.w600,
            fontFamily: "ManRope",
            color: const Color(0xFF444655),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHintText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Dimensions.mediumTextSize(context),
        fontWeight: FontWeight.w600,
        fontFamily: "ManRope",
        color: const Color(0xFF94A3B8),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? prefixIconPath,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      counterText: counterText,
      prefixIcon: prefixIconPath != null
          ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: SvgPicture.asset(prefixIconPath, width: 20, height: 20),
            )
          : null,
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleVisibility,
            )
          : null,
      border: _outlineBorder(const Color(0xFFE2E8F0)),
      enabledBorder: _outlineBorder(const Color(0xFFE2E8F0)),
      focusedBorder: _outlineBorder(const Color(0xFFB3B4FF)),
      errorBorder: _outlineBorder(const Color(0xFFFF5A5A)),
      focusedErrorBorder: _outlineBorder(const Color(0xFFB3B4FF)),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {AsyncValue<void>? registrationStatus}) {
    final status = registrationStatus ?? ref.watch(registerViewModelProvider.select((s) => s.registrationStatus));
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: status?.maybeWhen(loading: () => null, orElse: () => onPressed),
        child: status?.maybeWhen(
          loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          orElse: () => Text(label, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black54, fontSize: 16),
          children: [
            const TextSpan(text: "Already have an account? ", style: TextStyle(fontFamily: "ManRope")),
            TextSpan(
              text: "Login",
              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontFamily: "ManRope"),
              recognizer: TapGestureRecognizer()..onTap = () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}