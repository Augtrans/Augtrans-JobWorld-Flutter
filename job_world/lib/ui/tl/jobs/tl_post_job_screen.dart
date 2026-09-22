import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_world/core/networking/api_exception.dart';
import 'package:job_world/data/model/jobpost/TlJobPostModel.dart';
import 'package:job_world/data/model/profile/EducationMasterModel.dart';
import 'package:job_world/data/model/profile/SkillModel.dart';
import 'package:job_world/ui/profile/ProfileViewModel.dart';
import 'package:job_world/ui/tl/jobs/TlJobsViewModel.dart';
import 'package:job_world/ui/tl/jobs/tl_common_widgets.dart';
import 'package:job_world/ui/tl/jobs/tl_models.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

/// 3-step "Post Job" wizard for the TL jobs flow: Job Basics -> Requirements -> Details.
/// Mirrors the header/card language of [TlJobListingsScreen] and friends.
/// Employment Type, Work Mode, Continent, Country and Location are backed by
/// their masters APIs; Recruiter/Department stay local mock options until a
/// masters API exists for them.
class TlPostJobScreen extends ConsumerStatefulWidget {
  final TlJobPostModel? existingJob;

  const TlPostJobScreen({super.key, this.existingJob});

  @override
  ConsumerState<TlPostJobScreen> createState() => _TlPostJobScreenState();
}

class _StepInfo {
  final String label;
  const _StepInfo(this.label);
}

const List<_StepInfo> _steps = [
  _StepInfo("Job Basics"),
  _StepInfo("Requirements"),
  _StepInfo("Details"),
];

class _JobLocation {
  final int continentId;
  final String continent;
  final int countryId;
  final String country;
  final int cityId;
  final String city;
  const _JobLocation({
    required this.continentId,
    required this.continent,
    required this.countryId,
    required this.country,
    required this.cityId,
    required this.city,
  });
}

Widget _staticFieldLabel(String label, bool isRequired, {int? number}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (number != null) ...[
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
          child: Text("$number", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
      ],
      RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          children: [
            TextSpan(text: label),
            if (isRequired) const TextSpan(text: " *", style: TextStyle(color: AppColors.red600)),
          ],
        ),
      ),
    ],
  );
}

/// Inline single-select dropdown: tapping the field expands a bounded,
/// scrollable option list directly below it in the form (no modal bottom
/// sheet, no overlay menu) — avoids the RenderFlex overflow a bottom sheet
/// hits when an options list (e.g. hundreds of skills/locations) doesn't fit
/// the screen.
class _InlineDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final int? number;
  final Map<T, String> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<String>? onSearchChanged;
  final bool loading;

  const _InlineDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.value,
    required this.onChanged,
    this.onSearchChanged,
    this.isRequired = false,
    this.number,
    this.loading = false,
  });

  @override
  State<_InlineDropdown<T>> createState() => _InlineDropdownState<T>();
}

class _InlineDropdownState<T> extends State<_InlineDropdown<T>> {
  bool _expanded = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _InlineDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged == null && _expanded) {
      _expanded = false;
      _searchQuery = "";
      _searchController.clear();
    }
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      _searchQuery = "";
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final displayText = widget.value != null ? widget.options[widget.value] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staticFieldLabel(widget.label, widget.isRequired, number: widget.number),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? _toggleExpanded : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(14))
                    : BorderRadius.circular(14),
                border: Border.all(color: _expanded ? AppColors.primaryBlue : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText ?? widget.hint,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: displayText != null ? FontWeight.w500 : FontWeight.normal,
                        color: displayText != null ? const Color(0xFF0F172A) : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) _buildOptionPanel(),
      ],
    );
  }

  Widget _buildOptionPanel() {
    final filteredEntries = widget.onSearchChanged != null
        ? widget.options.entries.toList()
        : widget.options.entries.where((entry) {
            if (_searchQuery.trim().isEmpty) return true;
            return entry.value.toLowerCase().contains(_searchQuery.trim().toLowerCase());
          }).toList();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.primaryBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          setState(() {
                            _searchQuery = "";
                            _searchController.clear();
                          });
                          if (widget.onSearchChanged != null) {
                            widget.onSearchChanged!("");
                          }
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
                if (widget.onSearchChanged != null) {
                  widget.onSearchChanged!(val);
                }
              },
            ),
          ),
          Expanded(
            child: widget.loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : widget.options.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Text("No options available.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      )
                    : filteredEntries.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            child: Text("No matching options found.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: filteredEntries.length,
                            itemBuilder: (context, index) {
                              final entry = filteredEntries[index];
                              final selected = entry.key == widget.value;
                              return InkWell(
                                onTap: () {
                                  widget.onChanged!(entry.key);
                                  _toggleExpanded();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                            color: selected ? AppColors.primaryBlue : const Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                      if (selected) const Icon(Icons.check_rounded, size: 18, color: AppColors.primaryBlue),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/// Inline multi-select: tapping the field expands a bounded, scrollable
/// checklist directly below it (no modal bottom sheet). Stays open while
/// picking several options; tap the header again (or outside) to collapse.
class _InlineMultiDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final Map<T, String> options;
  final List<T> selectedValues;
  final ValueChanged<T> onToggle;
  final bool loading;

  const _InlineMultiDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selectedValues,
    required this.onToggle,
    this.isRequired = false,
    this.loading = false,
  });

  @override
  State<_InlineMultiDropdown<T>> createState() => _InlineMultiDropdownState<T>();
}

class _InlineMultiDropdownState<T> extends State<_InlineMultiDropdown<T>> {
  bool _expanded = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      _searchQuery = "";
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staticFieldLabel(widget.label, widget.isRequired),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: _expanded ? const BorderRadius.vertical(top: Radius.circular(14)) : BorderRadius.circular(14),
              border: Border.all(color: _expanded ? AppColors.primaryBlue : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: widget.selectedValues.isEmpty
                      ? Text(widget.hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final id in widget.selectedValues)
                              if (widget.options[id] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    widget.options[id]!,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                                  ),
                                ),
                          ],
                        ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) _buildOptionPanel(),
      ],
    );
  }

  Widget _buildOptionPanel() {
    final filteredEntries = widget.options.entries.where((entry) {
      if (_searchQuery.trim().isEmpty) return true;
      return entry.value.toLowerCase().contains(_searchQuery.trim().toLowerCase());
    }).toList();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.options.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.primaryBlue),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () {
                            setState(() {
                              _searchQuery = "";
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
          Expanded(
            child: widget.loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : widget.options.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Text("No options available.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      )
                    : filteredEntries.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            child: Text("No matching options found.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: filteredEntries.length,
                            itemBuilder: (context, index) {
                              final entry = filteredEntries[index];
                              final selected = widget.selectedValues.contains(entry.key);
                              return InkWell(
                                onTap: () => widget.onToggle(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                        size: 20,
                                        color: selected ? AppColors.primaryBlue : Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                            color: selected ? AppColors.primaryBlue : const Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _TlPostJobScreenState extends ConsumerState<TlPostJobScreen> {
  int _currentStep = 0;

  final _companyNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _minExperienceController = TextEditingController();
  final _maxExperienceController = TextEditingController();
  final _budgetController = TextEditingController();
  final _tatController = TextEditingController();
  final _vacancyController = TextEditingController();

  final List<int> _selectedSkillIds = [];
  final List<int> _selectedQualificationIds = [];
  int? _salaryUnitId;

  // Continent -> Country -> Location masters (GET /jobpost/continents|countries|locations/).
  bool _loadingMasters = true;
  String? _mastersError;
  List<EducationMasterModel> _continentOptions = [];
  List<EducationMasterModel> _employmentTypeOptions = [];
  List<EducationMasterModel> _workModeOptions = [];
  List<EducationMasterModel> _salaryUnitOptions = [];
  List<EducationMasterModel> _departmentOptions = [];
  List<EducationMasterModel> _qualificationOptions = [];
  List<MasterSkillModel> _skillOptions = [];
  List<EducationMasterModel> _countryOptions = [];
  List<EducationMasterModel> _cityOptions = [];
  bool _loadingCountries = false;
  bool _loadingCities = false;

  int? _selectedContinentId;
  int? _selectedCountryId;
  int? _selectedCityId;
  bool _candidateCanRelocate = false;
  final List<_JobLocation> _locations = [];

  int? _employmentTypeId;
  int? _workModeId;
  int? _departmentId;
  List<TlJobAssignUserModel> _recruiterOptions = [];
  int? _recruiterId;
  DateTime? _tatDate;
  bool _submitting = false;
  bool _refiningWithAi = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMasters();
  }

  Future<void> _loadInitialMasters() async {
    final jobRepository = ref.read(tlJobRepositoryProvider);
    final profileRepository = ref.read(profileRepositoryProvider);
    try {
      final results = await Future.wait([
        jobRepository.getContinents(),
        jobRepository.getWorkModes(),
        profileRepository.getEmploymentTypes(),
        profileRepository.getSalaryUnits(),
        profileRepository.getDepartments(),
        profileRepository.getEducationTypes(),
      ]);
      final skills = await profileRepository.getMasterSkills();
      final recruiters = await jobRepository.getAssignableRecruiters();
      if (!mounted) return;
      setState(() {
        _continentOptions = results[0];
        _workModeOptions = results[1];
        _employmentTypeOptions = results[2];
        _salaryUnitOptions = results[3];
        _departmentOptions = results[4];
        _qualificationOptions = results[5];
        _skillOptions = skills;
        _recruiterOptions = recruiters;
        _loadingMasters = false;
      });
      _prefillFromExistingJob();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mastersError = e.toString();
        _loadingMasters = false;
      });
    }
  }

  void _prefillFromExistingJob() {
    final job = widget.existingJob;
    if (job == null) return;
    _companyNameController.text = job.orgName;
    _jobTitleController.text = job.jobTitle;
    _jobDescriptionController.text = job.jobDescription;
    _minExperienceController.text = job.minYoe > 0 ? job.minYoe.toString() : '';
    _maxExperienceController.text = job.maxYoe > 0 ? job.maxYoe.toString() : '';
    _budgetController.text = job.budget > 0 ? job.budget.toString() : '';
    _vacancyController.text = job.numberOfVacancy > 0 ? job.numberOfVacancy.toString() : '';
    if (job.tat != null && job.tat!.isNotEmpty) {
      final parsed = DateTime.tryParse(job.tat!);
      if (parsed != null) {
        _tatDate = parsed;
        _tatController.text = "${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}/${parsed.year}";
      }
    }

    _selectedSkillIds.addAll(job.requiredSkills);
    _selectedQualificationIds.addAll(job.qualification);
    _salaryUnitId = job.salaryUnit;
    _candidateCanRelocate = job.allowRelocation;
    _employmentTypeId = job.employmentType;
    _workModeId = job.workMode;
    _departmentId = job.department;

    _recruiterId = job.assignedRecruiter;

    // Existing saved locations shown as read-only chips — display names come
    // straight from the job response, no continent/country/location master
    // lookups needed for that (only needed when adding a *new* location).
    final count = [job.continents.length, job.countries.length, job.availableLocation.length].reduce((a, b) => a < b ? a : b);
    for (var i = 0; i < count; i++) {
      _locations.add(_JobLocation(
        continentId: job.continents[i],
        continent: i < job.continentNames.length ? job.continentNames[i] : "#${job.continents[i]}",
        countryId: job.countries[i],
        country: i < job.countryNames.length ? job.countryNames[i] : "#${job.countries[i]}",
        cityId: job.availableLocation[i],
        city: i < job.locationNames.length ? job.locationNames[i] : "#${job.availableLocation[i]}",
      ));
    }
    setState(() {});
  }

  Future<void> _onContinentChanged(int? continentId) async {
    setState(() {
      _selectedContinentId = continentId;
      _selectedCountryId = null;
      _selectedCityId = null;
      _countryOptions = [];
      _cityOptions = [];
    });
    if (continentId == null) return;
    setState(() => _loadingCountries = true);
    try {
      final jobRepository = ref.read(tlJobRepositoryProvider);
      final countries = await jobRepository.getCountries(continentId);
      if (!mounted) return;
      setState(() {
        _countryOptions = countries;
        _loadingCountries = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCountries = false);
      showTlSnack(context, "Failed to load countries: $e");
    }
  }

  Timer? _locationSearchDebounce;

  Future<void> _onCountryChanged(int? countryId) async {
    setState(() {
      _selectedCountryId = countryId;
      _selectedCityId = null;
      _cityOptions = [];
    });
    if (countryId == null) return;
    setState(() => _loadingCities = true);
    try {
      final jobRepository = ref.read(tlJobRepositoryProvider);
      final locations = await jobRepository.getLocations(countryId);
      if (!mounted) return;
      setState(() {
        _cityOptions = locations;
        _loadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCities = false);
      showTlSnack(context, "Failed to load locations: $e");
    }
  }

  void _onLocationSearch(String query) {
    _locationSearchDebounce?.cancel();
    _locationSearchDebounce = Timer(const Duration(milliseconds: 300), () async {
      final countryId = _selectedCountryId;
      if (countryId == null) return;
      setState(() => _loadingCities = true);
      try {
        final jobRepository = ref.read(tlJobRepositoryProvider);
        final locations = await jobRepository.getLocations(countryId, search: query);
        if (!mounted) return;
        setState(() {
          _cityOptions = locations;
          _loadingCities = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _loadingCities = false);
      }
    });
  }

  @override
  void dispose() {
    _locationSearchDebounce?.cancel();
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _minExperienceController.dispose();
    _maxExperienceController.dispose();
    _budgetController.dispose();
    _tatController.dispose();
    _vacancyController.dispose();
    super.dispose();
  }

  bool get _isLocked => widget.existingJob?.jobpostLock == true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TlHeaderBar(title: widget.existingJob != null ? "Edit Job" : "Post Job"),
      body: SafeArea(
        top: false,
        child: _loadingMasters
            ? const Center(child: CircularProgressIndicator())
            : _mastersError != null
                ? _buildMastersError(context)
                : Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.level3Margin(context) + 2,
                          vertical: Dimensions.level3Margin(context),
                        ),
                        child: _buildStepper(context),
                      ),
                      if (_isLocked) _buildLockedBanner(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.level3Margin(context) + 2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _steps[_currentStep].label,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              Dimensions.verticalSpace(context, 16),
                              IgnorePointer(
                                ignoring: _isLocked,
                                child: Opacity(
                                  opacity: _isLocked ? 0.6 : 1,
                                  child: _buildStepCard(context),
                                ),
                              ),
                              Dimensions.verticalSpace(context, 24),
                            ],
                          ),
                        ),
                      ),
                      _buildNavigationBar(context),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMastersError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 40),
            const SizedBox(height: 12),
            Text("Failed to load form data.\n$_mastersError", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {
                _loadingMasters = true;
                _mastersError = null;
                _loadInitialMasters();
              }),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // STEPPER
  // ----------------------------------------------------------

  Widget _buildStepper(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          Column(
            children: [
              _stepCircle(context, i),
              const SizedBox(height: 8),
              Text(
                _steps[i].label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: i == _currentStep ? FontWeight.bold : FontWeight.w500,
                  color: i <= _currentStep ? AppColors.primaryBlue : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          if (i != _steps.length - 1)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 2,
                color: i < _currentStep ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
              ),
            ),
        ],
      ],
    );
  }

  Widget _stepCircle(BuildContext context, int index) {
    final bool done = index < _currentStep;
    final bool active = index == _currentStep;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (done || active) ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text(
              "${index + 1}",
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  // ----------------------------------------------------------
  // STEP CARD
  // ----------------------------------------------------------

  Widget _buildLockedBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.level3Margin(context) + 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "This job is locked and can no longer be edited. Only HR Head or Reporting Manager can edit a locked job.",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context) {
    return TlCard(
      padding: EdgeInsets.all(_cardPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          switch (_currentStep) {
            0 => _buildJobBasicsStep(context),
            1 => _buildRequirementsStep(context),
            _ => _buildDetailsStep(context),
          },
          Dimensions.verticalSpace(context, 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildRefineWithAiButton(context),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // STEP 1 — JOB BASICS
  // ----------------------------------------------------------

  Widget _buildJobBasicsStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(context, label: "Company Name", hint: "Orbit", controller: _companyNameController, isRequired: true),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(context, label: "Job Title", hint: "xyz", controller: _jobTitleController, isRequired: true),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(
          context,
          label: "Job Description",
          hint: "Describe the role, responsibilities, and ideal candidate...",
          controller: _jobDescriptionController,
          isRequired: true,
          maxLines: 6,
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // STEP 2 — REQUIREMENTS
  // ----------------------------------------------------------

  Widget _buildRequirementsStep(BuildContext context) {
    final skillOptions = {for (final s in _skillOptions) s.id: s.name};
    final salaryUnitOptions = {for (final s in _salaryUnitOptions) s.id: s.name};
    final qualificationOptions = {for (final q in _qualificationOptions) q.id: q.name};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InlineMultiDropdown<int>(
          label: "Required Skills",
          hint: "Select skills",
          isRequired: true,
          options: skillOptions,
          selectedValues: _selectedSkillIds,
          onToggle: (id) => setState(() {
            if (_selectedSkillIds.contains(id)) {
              _selectedSkillIds.remove(id);
            } else {
              _selectedSkillIds.add(id);
            }
          }),
        ),
        Dimensions.verticalSpace(context, 20),
        _InlineMultiDropdown<int>(
          label: "Qualifications",
          hint: "Select qualifications",
          isRequired: true,
          options: qualificationOptions,
          selectedValues: _selectedQualificationIds,
          onToggle: (id) => setState(() {
            if (_selectedQualificationIds.contains(id)) {
              _selectedQualificationIds.remove(id);
            } else {
              _selectedQualificationIds.add(id);
            }
          }),
        ),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(
          context,
          label: "Min Experience",
          hint: "XYZ...",
          controller: _minExperienceController,
          isRequired: true,
          keyboardType: TextInputType.number,
        ),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(
          context,
          label: "Max Experience",
          hint: "XYZ...",
          controller: _maxExperienceController,
          isRequired: true,
          keyboardType: TextInputType.number,
        ),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(
          context,
          label: "Budget",
          hint: "Enter budget",
          controller: _budgetController,
          isRequired: true,
          keyboardType: TextInputType.number,
        ),
        Dimensions.verticalSpace(context, 20),
        _InlineDropdown<int>(
          label: "Salary Unit",
          hint: "Select unit",
          isRequired: true,
          value: _salaryUnitId,
          options: salaryUnitOptions,
          onChanged: (v) => setState(() => _salaryUnitId = v),
        ),
        Dimensions.verticalSpace(context, 24),
        _buildLocationSection(context),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final continentOptions = {for (final c in _continentOptions) c.id: c.name};
    final countryOptions = {for (final c in _countryOptions) c.id: c.name};
    final cityOptions = {for (final c in _cityOptions) c.id: c.name};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Dimensions.verticalSpace(context, 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "To add a location: select a Continent, then a Country, then one or more Cities — then click Add. Repeat to add locations from other countries or continents.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF3730A3), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Dimensions.verticalSpace(context, 16),
          _InlineDropdown<int>(
            number: 1,
            label: "Continent",
            isRequired: true,
            hint: "Select Continent",
            value: _selectedContinentId,
            options: continentOptions,
            onChanged: _onContinentChanged,
          ),
          Dimensions.verticalSpace(context, 16),
          _InlineDropdown<int>(
            number: 2,
            label: "Country",
            isRequired: true,
            hint: _selectedContinentId == null ? "Select Continent first" : "Select Country",
            value: _selectedCountryId,
            options: countryOptions,
            loading: _loadingCountries,
            onChanged: _selectedContinentId == null ? null : _onCountryChanged,
          ),
          Dimensions.verticalSpace(context, 16),
          _InlineDropdown<int>(
            number: 3,
            label: "Locations",
            isRequired: true,
            hint: _selectedCountryId == null ? "Select Country first" : "Search or Select City",
            value: _selectedCityId,
            options: cityOptions,
            loading: _loadingCities,
            onChanged: _selectedCountryId == null ? null : (v) => setState(() => _selectedCityId = v),
            onSearchChanged: _selectedCountryId == null ? null : _onLocationSearch,
          ),
          Dimensions.verticalSpace(context, 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addLocation,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Add Location", style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: Color(0xFFC7D2FE)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: const Color(0xFFEEF2FF),
              ),
            ),
          ),
          Dimensions.verticalSpace(context, 16),
          Row(
            children: [
              Checkbox(
                value: _candidateCanRelocate,
                activeColor: AppColors.primaryBlue,
                onChanged: (v) => setState(() => _candidateCanRelocate = v ?? false),
              ),
              const Expanded(child: Text("Candidate can relocate", style: TextStyle(fontSize: 13, color: Color(0xFF334155)))),
              Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey.shade400),
            ],
          ),
          Dimensions.verticalSpace(context, 8),
          if (_locations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.location_off_outlined, color: Colors.grey.shade400, size: 26),
                  const SizedBox(height: 8),
                  Text("No locations added yet.", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            )
          else
            Column(
              children: [
                for (final loc in _locations) ...[
                  _buildLocationTile(context, loc),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(BuildContext context, _JobLocation loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${loc.city}, ${loc.country} (${loc.continent})",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _locations.remove(loc)),
            child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _addLocation() {
    if (_selectedContinentId == null || _selectedCountryId == null || _selectedCityId == null) {
      showTlSnack(context, "Select Continent, Country and a City first");
      return;
    }
    final continentName = _continentOptions.firstWhere((c) => c.id == _selectedContinentId).name;
    final countryName = _countryOptions.firstWhere((c) => c.id == _selectedCountryId).name;
    final cityName = _cityOptions.firstWhere((c) => c.id == _selectedCityId).name;
    setState(() {
      _locations.add(_JobLocation(
        continentId: _selectedContinentId!,
        continent: continentName,
        countryId: _selectedCountryId!,
        country: countryName,
        cityId: _selectedCityId!,
        city: cityName,
      ));
      _selectedCityId = null;
    });
  }

  // ----------------------------------------------------------
  // STEP 3 — DETAILS
  // ----------------------------------------------------------

  Widget _buildDetailsStep(BuildContext context) {
    final employmentTypeOptions = {for (final e in _employmentTypeOptions) e.id: e.name};
    final workModeOptions = {for (final w in _workModeOptions) w.id: w.name};
    final departmentOptions = {for (final d in _departmentOptions) d.id: d.name};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InlineDropdown<int>(
          label: "Employment Type",
          hint: "Select Employment Type",
          isRequired: true,
          value: _employmentTypeId,
          options: employmentTypeOptions,
          onChanged: (v) => setState(() => _employmentTypeId = v),
        ),
        Dimensions.verticalSpace(context, 20),
        _InlineDropdown<int>(
          label: "Work Mode",
          hint: "Select work mode",
          isRequired: true,
          value: _workModeId,
          options: workModeOptions,
          onChanged: (v) => setState(() => _workModeId = v),
        ),
        Dimensions.verticalSpace(context, 20),
        _InlineDropdown<int>(
          label: "Assigned Recruiter",
          hint: "Search and assign recruiter...",
          isRequired: true,
          value: _recruiterId,
          options: {for (final r in _recruiterOptions) r.id: r.username},
          onChanged: (v) => setState(() => _recruiterId = v),
        ),
        Dimensions.verticalSpace(context, 20),
        _InlineDropdown<int>(
          label: "Department",
          hint: "Search and assign department...",
          isRequired: true,
          value: _departmentId,
          options: departmentOptions,
          onChanged: (v) => setState(() => _departmentId = v),
        ),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(
          context,
          label: "TAT",
          hint: "mm/dd/yyyy",
          controller: _tatController,
          readOnly: true,
          suffixIcon: Icons.calendar_today_outlined,
          onTap: () => _pickTatDate(context),
        ),
        Dimensions.verticalSpace(context, 20),
        _buildTextField(
          context,
          label: "No. of Vacancy",
          hint: "Enter number of vacancies",
          controller: _vacancyController,
          isRequired: true,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Future<void> _pickTatDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tatDate ?? now,
      firstDate: now.isBefore(_tatDate ?? now) ? now : DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      setState(() {
        _tatDate = picked;
        _tatController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // ----------------------------------------------------------
  // SHARED FORM FIELD WIDGETS
  // ----------------------------------------------------------

  Widget _fieldLabel(String label, bool isRequired) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        children: [
          TextSpan(text: label),
          if (isRequired) const TextSpan(text: " *", style: TextStyle(color: AppColors.red600)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isRequired),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade400, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefineWithAiButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _refiningWithAi ? null : _refineWithAi,
      icon: _refiningWithAi
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            )
          : Image.asset('assets/png/ic_sparkle_badge.png', width: 18, height: 18),
      label: Text(_refiningWithAi ? "Refining..." : "Refine with AI",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFC7D2FE)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
      ),
    );
  }

  /// Calls POST /user/ai-refine/refine/ for module "JobPost" with just the
  /// job title, then fills the rest of the wizard from `refined_data`.
  /// The response only carries resolved ids (skills/qualification/employment
  /// type/work mode/salary unit) — those are applied directly against the
  /// already-loaded master option lists, same ones the dropdowns render from.
  Future<void> _refineWithAi() async {
    final jobTitle = _jobTitleController.text.trim();
    if (jobTitle.isEmpty) {
      showTlSnack(context, "Enter a job title first");
      return;
    }

    setState(() => _refiningWithAi = true);
    try {
      final repository = ref.read(tlJobRepositoryProvider);
      final refined = await repository.refineJobPostWithAi(jobTitle);
      if (!mounted) return;

      setState(() {
        if (refined['job_title'] is String && (refined['job_title'] as String).isNotEmpty) {
          _jobTitleController.text = refined['job_title'];
        }
        if (refined['job_description'] is String) {
          _jobDescriptionController.text = refined['job_description'];
        }
        if (refined['min_yoe'] != null) _minExperienceController.text = "${refined['min_yoe']}";
        if (refined['max_yoe'] != null) _maxExperienceController.text = "${refined['max_yoe']}";
        if (refined['budget'] != null) _budgetController.text = "${refined['budget']}";
        if (refined['number_of_vacancy'] != null) _vacancyController.text = "${refined['number_of_vacancy']}";
        if (refined['allow_relocation'] is bool) _candidateCanRelocate = refined['allow_relocation'];
        if (refined['employment_type'] is int) _employmentTypeId = refined['employment_type'];
        if (refined['work_mode'] is int) _workModeId = refined['work_mode'];
        if (refined['salary_unit'] is int) _salaryUnitId = refined['salary_unit'];
        if (refined['required_skills'] is List) {
          _selectedSkillIds
            ..clear()
            ..addAll((refined['required_skills'] as List).whereType<int>());
        }
        if (refined['qualification'] is List) {
          _selectedQualificationIds
            ..clear()
            ..addAll((refined['qualification'] as List).whereType<int>());
        }
      });

      if (!mounted) return;
      final creditsUsed = refined['blue_credits_debited'];
      showTlSnack(context, creditsUsed != null ? "Job post refined with AI ($creditsUsed credits used)" : "Job post refined with AI");
    } catch (e) {
      if (!mounted) return;
      showTlSnack(context, _aiRefineErrorMessage(e));
    } finally {
      if (mounted) setState(() => _refiningWithAi = false);
    }
  }

  String _aiRefineErrorMessage(Object error) {
    if (error is! ApiException) return "Failed to refine with AI. Please try again.";

    final data = error.data;
    if (data is Map) {
      final jobTitleErrors = data['data'] is Map ? (data['data'] as Map)['job_title'] : null;
      if (jobTitleErrors is List && jobTitleErrors.isNotEmpty) {
        return "Job title: ${jobTitleErrors.first}";
      }
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        final available = data['available_blue_credits'];
        return available != null ? "${data['message']} Available: $available credits." : data['message'];
      }
      if (data['error'] is String && (data['error'] as String).isNotEmpty) {
        return data['error'];
      }
      if (data['detail'] is String && (data['detail'] as String).isNotEmpty) {
        return data['detail'];
      }
    }

    switch (error.code) {
      case 404:
        return "Wallet not found.";
      case 429:
        return "Daily AI refine limit reached for this section. Please try again tomorrow.";
      case 500:
        return "AI service is currently unavailable. Please try again later.";
      default:
        return "Failed to refine with AI. Please try again.";
    }
  }

  // ----------------------------------------------------------
  // NAVIGATION BAR
  // ----------------------------------------------------------

  Widget _buildNavigationBar(BuildContext context) {
    final bool isLastStep = _currentStep == _steps.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.level3Margin(context) + 2,
        vertical: Dimensions.level3Margin(context),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentStep == 0 ? null : () => setState(() => _currentStep -= 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                disabledForegroundColor: Colors.grey.shade300,
                side: BorderSide(color: _currentStep == 0 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Previous", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitting || (_isLocked && isLastStep)
                  ? null
                  : (isLastStep ? _submitJobPost : () => setState(() => _currentStep += 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isLastStep ? "Post Job" : "Next", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  /// Editing an existing job always does a full PUT (every field on the
  /// wizard is present, so there's nothing to leave untouched). Creating a
  /// new job POSTs the same shape.
  Future<void> _submitJobPost() async {
    if (_jobTitleController.text.trim().isEmpty || _jobDescriptionController.text.trim().isEmpty) {
      showTlSnack(context, "Job title and description are required");
      return;
    }
    if (_employmentTypeId == null || _workModeId == null || _salaryUnitId == null || _departmentId == null) {
      showTlSnack(context, "Employment Type, Work Mode, Salary Unit and Department are required");
      return;
    }

    final job = widget.existingJob;
    final continentIds = _locations.map((l) => l.continentId).toSet().toList();
    final countryIds = _locations.map((l) => l.countryId).toSet().toList();
    final locationIds = _locations.map((l) => l.cityId).toSet().toList();
    final budget = num.tryParse(_budgetController.text) ?? 0;

    // POST /jobpost/post-jobs/ requires `org` on create too. There's no
    // logged-in-user org lookup yet, so fall back to the org on this TL's
    // own already-posted jobs (all posted by the same TL share one org).
    final orgId = job?.org ?? ref.read(tlJobsViewModelProvider).maybeWhen(
          data: (jobs) => jobs.isNotEmpty ? jobs.first.org : null,
          orElse: () => null,
        );

    final body = <String, dynamic>{
      "org": orgId,
      "job_title": _jobTitleController.text.trim(),
      "employment_type": _employmentTypeId,
      "work_mode": _workModeId,
      "job_description": _jobDescriptionController.text.trim(),
      "required_skills": _selectedSkillIds,
      "min_yoe": int.tryParse(_minExperienceController.text) ?? 0,
      "max_yoe": int.tryParse(_maxExperienceController.text) ?? 0,
      "salary_unit": _salaryUnitId,
      "budget": budget.toStringAsFixed(2),
      "continents": continentIds,
      "countries": countryIds,
      "available_location": locationIds,
      "allow_relocation": _candidateCanRelocate,
      "qualification": _selectedQualificationIds,
      "number_of_vacancy": int.tryParse(_vacancyController.text) ?? 1,
      "cv_criteria": job?.cvCriteria,
      "assigned_recruiter": _recruiterId,
      // No confirmed TL-list API yet — pass the existing assignment through untouched.
      "assigned_tl": job?.assignedTl,
      "department": _departmentId,
      if (_tatDate != null) "tat": _tatDate!.toIso8601String(),
    };

    final prettyBody = const JsonEncoder.withIndent('  ').convert(body);
    debugPrint("=== Job post ${job != null ? 'UPDATE (PUT)' : 'CREATE (POST)'} — jobId=${job?.id} — request body ===");
    for (final line in const LineSplitter().convert(prettyBody)) {
      debugPrint(line);
    }

    setState(() => _submitting = true);
    try {
      final repository = ref.read(tlJobRepositoryProvider);
      if (job != null) {
        await repository.updateJob(job.id, body);
        if (!mounted) return;
        showTlSnack(context, "Job updated successfully");
      } else {
        await repository.createJob(body);
        if (!mounted) return;
        showTlSnack(context, "Job posted successfully");
      }
      Navigator.of(context).maybePop(true);
    } catch (e) {
      if (!mounted) return;
      showTlSnack(context, _jobSaveErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _jobSaveErrorMessage(Object error) {
    if (error is ApiException) {
      final data = error.data;
      if (data is Map) {
        for (final key in ['error', 'detail', 'message']) {
          final value = data[key];
          if (value is String && value.isNotEmpty) return value;
        }
        if (data['data'] is Map) {
          final fieldErrors = data['data'] as Map;
          for (final entry in fieldErrors.entries) {
            if (entry.value is List && (entry.value as List).isNotEmpty) {
              return "${entry.key}: ${(entry.value as List).first}";
            }
          }
        }
      }
      return error.message;
    }
    return "Failed to save job. Please try again.";
  }

  // ----------------------------------------------------------
  // RESPONSIVE SIZES
  // ----------------------------------------------------------

  double _cardPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 16;
    if (width < 600) return 20;
    return Dimensions.level4Margin(context) - 8;
  }
}
