import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/register/DepartmentModel.dart';
import '../../data/model/register/OrganizationModel.dart';
import '../../data/model/register/OrgRegisterReqModel.dart';
import '../../data/model/register/RoleModel.dart';
import '../../data/model/register/UserRegisterReqModel.dart';
import '../../data/repositories/RegisterRepository.dart';

class RegisterState {
  final AsyncValue<dynamic> registrationStatus;
  final AsyncValue<dynamic> orgCreationStatus;
  final AsyncValue<dynamic> otpVerificationStatus;
  final AsyncValue<List<RoleModel>> roles;
  final AsyncValue<List<OrganizationModel>> organizations;
  final AsyncValue<List<DepartmentModel>> departments;
  final int? createdOrgId;
  final UserRegisterReqModel? pendingUserRegistration;

  RegisterState({
    required this.registrationStatus,
    required this.orgCreationStatus,
    required this.otpVerificationStatus,
    required this.roles,
    required this.organizations,
    required this.departments,
    this.createdOrgId,
    this.pendingUserRegistration,
  });

  factory RegisterState.initial() {
    return RegisterState(
      registrationStatus: const AsyncData(null),
      orgCreationStatus: const AsyncData(null),
      otpVerificationStatus: const AsyncData(null),
      roles: const AsyncLoading(),
      organizations: const AsyncLoading(),
      departments: const AsyncData([]),
      createdOrgId: null,
      pendingUserRegistration: null,
    );
  }

  RegisterState copyWith({
    AsyncValue<dynamic>? registrationStatus,
    AsyncValue<dynamic>? orgCreationStatus,
    AsyncValue<dynamic>? otpVerificationStatus,
    AsyncValue<List<RoleModel>>? roles,
    AsyncValue<List<OrganizationModel>>? organizations,
    AsyncValue<List<DepartmentModel>>? departments,
    int? createdOrgId,
    UserRegisterReqModel? pendingUserRegistration,
    bool clearOrgId = false,
  }) {
    return RegisterState(
      registrationStatus: registrationStatus ?? this.registrationStatus,
      orgCreationStatus: orgCreationStatus ?? this.orgCreationStatus,
      otpVerificationStatus: otpVerificationStatus ?? this.otpVerificationStatus,
      roles: roles ?? this.roles,
      organizations: organizations ?? this.organizations,
      departments: departments ?? this.departments,
      createdOrgId: clearOrgId ? null : (createdOrgId ?? this.createdOrgId),
      pendingUserRegistration: pendingUserRegistration ?? this.pendingUserRegistration,
    );
  }
}

final registerRepositoryProvider = Provider<RegisterApiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RegisterApiRepository(apiClient);
});

final registerViewModelProvider = StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
  final repository = ref.watch(registerRepositoryProvider);
  return RegisterViewModel(repository);
});

class RegisterViewModel extends StateNotifier<RegisterState> {
  final RegisterApiRepository _repository;

  RegisterViewModel(this._repository) : super(RegisterState.initial()) {
    fetchRoles();
    fetchOrganizations();
  }

  Future<void> fetchRoles() async {
    state = state.copyWith(roles: const AsyncLoading());
    try {
      final roles = await _repository.getRoles();
      state = state.copyWith(roles: AsyncData(roles));
    } catch (e, stack) {
      state = state.copyWith(roles: AsyncError(e, stack));
    }
  }

  Future<void> fetchOrganizations() async {
    state = state.copyWith(organizations: const AsyncLoading());
    try {
      final orgs = await _repository.getOrganizations();
      state = state.copyWith(organizations: AsyncData(orgs));
    } catch (e, stack) {
      state = state.copyWith(organizations: AsyncError(e, stack));
    }
  }

  Future<void> fetchDepartments(int organizationId) async {
    state = state.copyWith(departments: const AsyncLoading());
    try {
      final departments = await _repository.getDepartments(organizationId);
      state = state.copyWith(departments: AsyncData(departments));
    } catch (e, stack) {
      state = state.copyWith(departments: AsyncError(e, stack));
    }
  }

  Future<void> registerIndividual({
    required String username,
    required String email,
    required String password,
    required int roleId,
  }) async {
    state = state.copyWith(registrationStatus: const AsyncLoading());
    try {
      final request = UserRegisterReqModel(
        username: username,
        email: email,
        password: password,
        department: 1, 
        role: roleId,
        organization: "", 
        reportingManager: null,
      );
      await _repository.registerUser(request);
      state = state.copyWith(registrationStatus: const AsyncData(null));
    } catch (e, stack) {
      state = state.copyWith(registrationStatus: AsyncError(e, stack));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = state.copyWith(otpVerificationStatus: const AsyncLoading());
    try {
      await _repository.verifyOtp(email, otp);
      state = state.copyWith(otpVerificationStatus: const AsyncData(null));
    } catch (e, stack) {
      state = state.copyWith(otpVerificationStatus: AsyncError(e, stack));
    }
  }

  Future<void> createOrganization({
    required String name,
    required String gstin,
    required int organizationSize,
    required String country,
  }) async {
    state = state.copyWith(orgCreationStatus: const AsyncLoading());
    try {
      final request = OrgRegisterReqModel(name: name, gstin: gstin, organizationSize: organizationSize, country: country);
      final response = await _repository.createOrganization(request);
      int? orgId;
      if (response is Map<String, dynamic>) {
        orgId = response['id'];
      }
      state = state.copyWith(orgCreationStatus: const AsyncData(null), createdOrgId: orgId);
    } catch (e, stack) {
      state = state.copyWith(orgCreationStatus: AsyncError(e, stack));
    }
  }

  Future<void> registerOrganizationAdmin({
    required String username,
    required String email,
    required String password,
    required int roleId,
  }) async {
    state = state.copyWith(registrationStatus: const AsyncLoading());
    try {
      final orgId = state.createdOrgId;
      if (orgId == null) throw Exception("Organization ID not found.");

      final request = UserRegisterReqModel(
        username: username,
        email: email,
        password: password,
        department: 1, 
        role: roleId,
        organization: orgId,
        reportingManager: null,
      );
      await _repository.registerUser(request);
      state = state.copyWith(registrationStatus: const AsyncData(null));
    } catch (e, stack) {
      state = state.copyWith(registrationStatus: AsyncError(e, stack));
    }
  }

  Future<void> registerOrganizationNonAdmin({
    required String username,
    required String email,
    required String password,
    required int roleId,
    required String organizationName,
    required int departmentId,
  }) async {
    state = state.copyWith(registrationStatus: const AsyncLoading());
    try {
      final request = UserRegisterReqModel(
        username: username,
        email: email,
        password: password,
        department: departmentId,
        role: roleId,
        organization: organizationName,
        reportingManager: null,
      );
      await _repository.registerUser(request);
      state = state.copyWith(registrationStatus: const AsyncData(null));
    } catch (e, stack) {
      state = state.copyWith(registrationStatus: AsyncError(e, stack));
    }
  }
}