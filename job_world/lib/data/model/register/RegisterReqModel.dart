class RegisterReqModel {
  final String? username;
  final String? email;
  final String? password;
  final String? role;
  final String? orgName;
  final String? gstin;
  final String? country;
  final String? orgSize;

  RegisterReqModel({
    this.username,
    this.email,
    this.password,
    this.role,
    this.orgName,
    this.gstin,
    this.country,
    this.orgSize,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    if (orgName != null) data['org_name'] = orgName;
    if (gstin != null) data['gstin'] = gstin;
    if (country != null) data['country'] = country;
    if (orgSize != null) data['org_size'] = orgSize;
    return data;
  }
}
