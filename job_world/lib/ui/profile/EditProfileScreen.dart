import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_world/core/networking/api_exception.dart';
import 'package:job_world/data/model/profile/UserProfileModel.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:intl/intl.dart';
import 'ProfileViewModel.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  int _selectedTab = 0;
  bool _isUploadingCv = false;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _currentCtcController = TextEditingController();
  final TextEditingController _expectedCtcController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _noticePeriodController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();

  // Form State
  String? _selectedGender;
  String? _selectedCandidateType;
  String? _selectedCountry;

  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchAllProfileData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _currentCtcController.dispose();
    _expectedCtcController.dispose();
    _experienceController.dispose();
    _noticePeriodController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _initializeData(ProfileState state) {
    if (_isDataInitialized) return;

    state.profile.whenData((profile) {
      if (profile != null) {
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _dobController.text = profile.dateOfBirth ?? "";
        
        // Normalize Gender
        if (profile.gender != null && profile.gender!.isNotEmpty) {
          final gender = profile.gender!;
          _selectedGender = ["Male", "Female"].firstWhere(
            (g) => g.toLowerCase() == gender.toLowerCase(),
            orElse: () => "Male",
          );
        } else {
          _selectedGender = "Male";
        }

        _addressController.text = profile.addressLine ?? "";
        _cityController.text = profile.city;
        _stateController.text = profile.state;
        _selectedCountry = (profile.country != null && profile.country!.isNotEmpty) ? profile.country : "India";
        _pincodeController.text = profile.pincode;
        
        _currentCtcController.text = profile.currentCtc.toString();
        _expectedCtcController.text = profile.expectedCtc.toString();
        _experienceController.text = profile.yearsOfExperience.toString();

        // Normalize Candidate Type
        if (profile.candidateType != null && profile.candidateType!.isNotEmpty) {
          final cType = profile.candidateType!;
          _selectedCandidateType = ["Fresher", "Experienced"].firstWhere(
            (t) => t.toLowerCase() == cType.toLowerCase(),
            orElse: () => "Experienced",
          );
        }

        _noticePeriodController.text = profile.noticePeriod;
        
        _phoneController.text = profile.phoneNumber.replaceAll("+91", "");
        
        _linkedinController.text = profile.linkedinUrl ?? "";
        _githubController.text = profile.githubUrl ?? "";
        _portfolioController.text = profile.portfolioUrl ?? "";
        
        _isDataInitialized = true;
      }
    });
  }

  Future<void> _pickAndUploadCv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        setState(() {
          _isUploadingCv = true;
        });

        try {
          await ref.read(profileViewModelProvider.notifier).uploadResume(filePath);
          if (!mounted) return;
          setState(() {
            _isUploadingCv = false;
          });
          CommonMethods.showSnackBar(
            context,
            "CV uploaded successfully!",
            backgroundColor: Colors.green.shade700,
          );
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isUploadingCv = false;
          });
          final errorMsg = CommonMethods.extractErrorMessage(e);
          CommonMethods.showSnackBar(
            context,
            errorMsg,
            backgroundColor: Colors.red.shade700,
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking CV file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    _initializeData(profileState);

    ref.listen(profileViewModelProvider.select((s) => s.profile), (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to load latest profile data. You can still edit available fields.")),
            );
          });
        },
      );
    });

    ref.listen(profileViewModelProvider.select((s) => s.updateStatus), (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully!")),
            );
            context.pop();
          }
        },
        error: (error, stack) {
          final errorMessage = _extractErrorMessage(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
      );
    });

    final profile = profileState.profile.valueOrNull;
    final isInitialLoading = profileState.profile.isLoading && profile == null;
    final hasError = profileState.profile.hasError && profile == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text("Failed to load profile details.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(profileViewModelProvider.notifier).fetchProfile(force: true);
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildProfileImagePicker(profile?.profilePicture),
                            const SizedBox(height: 30),
                            _buildPillTabs(),
                            const SizedBox(height: 25),
                            _buildActiveSection(profileState),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(profile),
                  ],
                ),
    );
  }

  Widget _buildActiveSection(ProfileState profileState) {
    switch (_selectedTab) {
      case 0:
        return _buildPersonalInfoSection();
      case 1:
        return _buildProfessionalSection();
      case 2:
        return _buildContactAndSocialSection();
      case 3:
        return _buildCvSection(context, profileState);
      default:
        return _buildPersonalInfoSection();
    }
  }

  Widget _buildProfileImagePicker(String? imageUrl) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPillTab(0, "Personal Info"),
          const SizedBox(width: 12),
          _buildPillTab(1, "Professional"),
          const SizedBox(width: 12),
          _buildPillTab(2, "Contact & Social"),
          const SizedBox(width: 12),
          _buildPillTab(3, "Resume & CV"),
        ],
      ),
    );
  }

  Widget _buildPillTab(int index, String label) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField("First Name", "First", _firstNameController, isRequired: true),
          const SizedBox(height: 20),
          _buildTextField("Last Name", "Last", _lastNameController, isRequired: true),
          const SizedBox(height: 20),
          _buildTextField(
            "Date of Birth", 
            "YYYY-MM-DD", 
            _dobController, 
            isRequired: true, 
            suffixIcon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            "Gender", 
            "Select Gender", 
            isRequired: true, 
            items: ["Male", "Female"],
            value: _selectedGender,
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
          const SizedBox(height: 20),
          _buildTextField("Address Line", "Street address, P.O. box...", _addressController),
          const SizedBox(height: 20),
          _buildTextField("City", "e.g. Mumbai", _cityController),
          const SizedBox(height: 20),
          _buildTextField("State", "e.g. Maharashtra", _stateController),
          const SizedBox(height: 20),
          _buildDropdownField(
            "Country", 
            "Select country", 
            items: ["India", "USA", "UK", "Canada", "Australia"],
            value: _selectedCountry,
            onChanged: (val) => setState(() => _selectedCountry = val),
          ),
          const SizedBox(height: 20),
          _buildTextField("Pincode", "e.g. 400001", _pincodeController),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Professional Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField("Current CTC", "e.g. 8.5 LPA", _currentCtcController),
          const SizedBox(height: 20),
          _buildTextField("Expected CTC", "e.g. 12 LPA", _expectedCtcController),
          const SizedBox(height: 20),
          _buildTextField("Years of Experience", "e.g. 3.5", _experienceController),
          const SizedBox(height: 20),
          _buildDropdownField(
            "Candidate Type", 
            "Select type", 
            items: ["Fresher", "Experienced"], // Display names
            value: _selectedCandidateType,
            onChanged: (val) => setState(() => _selectedCandidateType = val),
          ),
          const SizedBox(height: 20),
          _buildTextField("Notice Period", "e.g. 30 days", _noticePeriodController),
        ],
      ),
    );
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

  Widget _buildContactAndSocialSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Contact Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildTextField("Email", "anuj.rane@example.com", _emailController, isRequired: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Social Links",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField("LinkedIn", "linkedin.com/in/renukaopalkar", _linkedinController),
              const SizedBox(height: 20),
              _buildTextField("GitHub", "https://github.com/your-username", _githubController),
              const SizedBox(height: 20),
              _buildTextField("Portfolio", "portfolio-link.com", _portfolioController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCvSection(BuildContext context, ProfileState profileState) {
    final cvsAsync = profileState.cvs;
    final cvList = cvsAsync.valueOrNull ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "My Resume / CV",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E2448),
                    ),
                  ),
                ],
              ),
              if (_isUploadingCv)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (cvList.isNotEmpty) ...[
            ...cvList.map((cv) {
              final fileName = (cv.pdfFile != null && cv.pdfFile!.isNotEmpty)
                  ? cv.pdfFile!.split('/').last
                  : "Uploaded_CV_v${cv.version}.pdf";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Version ${cv.version} • ${cv.sourceType.isNotEmpty ? cv.sourceType : 'UPLOADED'}",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    if (cv.pdfFile != null && cv.pdfFile!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
                        onPressed: () async {
                          final uri = Uri.parse(cv.pdfFile!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _isUploadingCv ? null : () => _pickAndUploadCv(context),
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(
                cvList.isNotEmpty ? "Update / Upload New CV" : "Upload CV (PDF / DOC)",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isRequired = false, IconData? suffixIcon, bool readOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"),
            children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            suffixIcon: suffixIcon != null 
              ? IconButton(
                  icon: Icon(suffixIcon, size: 18, color: AppColors.primaryBlue),
                  onPressed: onTap,
                )
              : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, {bool isRequired = false, required List<String> items, String? value, ValueChanged<String?>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"),
            children: isRequired ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: (value != null && items.contains(value)) ? value : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
          ),
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: "Phone",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: "ManRope"),
            children: [TextSpan(text: " *", style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: const Row(
                children: [
                  Text("IN +91", style: TextStyle(fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: "9888888889",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActions(UserProfileModel? profile) {
    final updateStatus = ref.watch(profileViewModelProvider.select((s) => s.updateStatus));
    final isLoading = updateStatus is AsyncLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Cancel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (profile == null) return;

                      final Map<String, dynamic> updateData = {
                        "first_name": _firstNameController.text.trim(),
                        "last_name": _lastNameController.text.trim(),
                        "date_of_birth": _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
                        "gender": (_selectedGender == null || _selectedGender!.isEmpty) ? "" : _selectedGender!.toUpperCase(),
                        "address_line": _addressController.text.trim(),
                        "city": _cityController.text.trim(),
                        "state": _stateController.text.trim(),
                        "country": _selectedCountry ?? "India",
                        "pincode": _pincodeController.text.trim(),
                        "current_ctc": double.tryParse(_currentCtcController.text) ?? 0.0,
                        "expected_ctc": double.tryParse(_expectedCtcController.text) ?? 0.0,
                        "notice_period": _noticePeriodController.text.trim(),
                        "phone_number": "+91${_phoneController.text.trim()}",
                        "years_of_experience": double.tryParse(_experienceController.text) ?? 0.0,
                        "candidate_type": _selectedCandidateType?.toUpperCase(),
                        "profile_summary": profile.profileSummary ?? "",
                        "linkedin_url": _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
                        "github_url": _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
                        "portfolio_url": _portfolioController.text.trim().isEmpty ? null : _portfolioController.text.trim(),
                        "user": profile.user,
                      };

                      ref.read(profileViewModelProvider.notifier).updateProfile(profile.id, updateData);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
