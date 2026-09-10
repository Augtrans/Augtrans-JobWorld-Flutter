import 'package:flutter/material.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// "Add/Update remark" — opened when a TL rejects / puts a candidate on hold,
/// or from the candidate detail actions.
class TlAddRemarkScreen extends StatefulWidget {
  final TlCandidateModel? candidate;

  const TlAddRemarkScreen({super.key, this.candidate});

  @override
  State<TlAddRemarkScreen> createState() => _TlAddRemarkScreenState();
}

class _TlAddRemarkScreenState extends State<TlAddRemarkScreen> {
  final TextEditingController _remarkController = TextEditingController();

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  void _save() {
    if (_remarkController.text.trim().isEmpty) {
      showTlSnack(context, "Please write a remark before saving");
      return;
    }
    Navigator.of(context).maybePop();
    showTlSnack(
      context,
      widget.candidate != null ? "Remark saved for ${widget.candidate!.name}" : "Remark saved",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const TlHeaderBar(title: "Add/Update remark"),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.level3Margin(context) + 2,
            vertical: Dimensions.level3Margin(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TlCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("REMARK",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.6)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                          child: TextField(
                            controller: _remarkController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: "Write your remark here...",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Dimensions.verticalSpace(context, 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
