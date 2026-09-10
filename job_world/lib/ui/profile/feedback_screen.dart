import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';
import 'package:job_world/util/common_methods.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _rating = 4;
  String _selectedTypeDisplay = "General";
  final TextEditingController _controller = TextEditingController();
  File? _selectedScreenshot;
  bool _isSubmitting = false;

  final Map<String, String> _typeMapping = {
    "General": "GENERAL",
    "Suggestion": "SUGGESTION",
    "Bug": "BUG",
    "Feature": "FEATURE",
    "Other": "OTHER",
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() {
          _selectedScreenshot = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submitFeedback() async {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) {
      CommonMethods.showSnackBar(
        context,
        "Please enter your feedback message",
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final apiFeedbackType = _typeMapping[_selectedTypeDisplay] ?? "GENERAL";

    try {
      final notifier = ref.read(profileViewModelProvider.notifier);
      await notifier.submitPortalFeedback(
        feedbackType: apiFeedbackType,
        rating: _rating,
        message: messageText,
        screenshotPath: _selectedScreenshot?.path,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        CommonMethods.showSnackBar(
          context,
          "Feedback submitted successfully! Thank you.",
          backgroundColor: Colors.green.shade700,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: Dimensions.level3Margin(context) + 4),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Feedback",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimensions.largeTextSize(context) + 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.level4Margin(context) - 8),
        child: Column(
          children: [
            Dimensions.verticalSpace(context, 20),
            // Illustration Placeholder
            Container(
              height: Dimensions.level6Size(context),
              width: Dimensions.level6Size(context),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(Dimensions.level6Size(context) / 2),
              ),
              child: Center(
                child: Icon(Icons.sentiment_very_satisfied_rounded, size: Dimensions.level3Size(context), color: AppColors.primaryBlue),
              ),
            ),
            Dimensions.verticalSpace(context, 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How was your experience?",
                    style: TextStyle(fontSize: Dimensions.xlargeTextSize(context), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Dimensions.verticalSpace(context, 30),
                  Text(
                    "RATE YOUR EXPERIENCE",
                    style: TextStyle(fontSize: Dimensions.smallTextSize(context) + 1, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  Dimensions.verticalSpace(context, 12),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = index + 1),
                        child: Padding(
                          padding: EdgeInsets.only(right: Dimensions.level2Margin(context)),
                          child: Icon(
                            Icons.star_rounded,
                            size: Dimensions.level4Margin(context),
                            color: index < _rating ? AppColors.primaryBlue : Colors.grey.shade200,
                          ),
                        ),
                      );
                    }),
                  ),
                  Dimensions.verticalSpace(context, 30),
                  Text(
                    "FEEDBACK TYPE",
                    style: TextStyle(fontSize: Dimensions.smallTextSize(context) + 1, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  Dimensions.verticalSpace(context, 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTypeDisplay,
                        isExpanded: true,
                        items: _typeMapping.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(key, style: TextStyle(fontSize: Dimensions.mediumTextSize(context))),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTypeDisplay = val);
                        },
                      ),
                    ),
                  ),
                  Dimensions.verticalSpace(context, 30),
                  Text(
                    "TELL US MORE",
                    style: TextStyle(fontSize: Dimensions.smallTextSize(context) + 1, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  Dimensions.verticalSpace(context, 12),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: TextStyle(fontSize: Dimensions.mediumTextSize(context)),
                    decoration: InputDecoration(
                      hintText: "Describe your experience or suggest improvements...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: Dimensions.mediumTextSize(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                  Dimensions.verticalSpace(context, 30),
                  Text(
                    "UPLOAD SCREENSHOT (OPTIONAL)",
                    style: TextStyle(fontSize: Dimensions.smallTextSize(context) + 1, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  Dimensions.verticalSpace(context, 12),
                  GestureDetector(
                    onTap: _pickScreenshot,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Dimensions.level4Margin(context) - 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), style: BorderStyle.solid),
                      ),
                      child: _selectedScreenshot != null
                          ? Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedScreenshot!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedScreenshot!.path.split('/').last,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      const Text("Tap to change screenshot", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedScreenshot = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(Dimensions.level2Margin(context) + 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.file_upload_outlined, color: AppColors.primaryBlue, size: Dimensions.level3Margin(context) + 8),
                                ),
                                Dimensions.verticalSpace(context, 16),
                                Text(
                                  "Tap to upload screenshot",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.mediumTextSize(context) + 1),
                                ),
                                Dimensions.verticalSpace(context, 4),
                                Text(
                                  "PNG, JPG up to 10MB",
                                  style: TextStyle(fontSize: Dimensions.smallTextSize(context) + 1, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Dimensions.verticalSpace(context, 40),
                  SizedBox(
                    width: double.infinity,
                    height: Dimensions.level1Size(context) + 6,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Submit Feedback", style: TextStyle(fontSize: Dimensions.mediumTextSize(context) + 3, fontWeight: FontWeight.bold)),
                                Dimensions.horizontalSpace(context, 8),
                                Icon(Icons.send_rounded, size: Dimensions.mediumTextSize(context) + 5),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Dimensions.verticalSpace(context, 40),
          ],
        ),
      ),
    );
  }
}
