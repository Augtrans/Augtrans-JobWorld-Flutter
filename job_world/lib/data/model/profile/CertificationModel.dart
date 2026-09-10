class CertificationModel {
  final int? id;
  final String name;
  final String issuingOrganization;
  final String issueDate;
  final String? expiryDate;
  final String credentialId;
  final String? credentialUrl;
  final int? user;

  CertificationModel({
    this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expiryDate,
    required this.credentialId,
    this.credentialUrl,
    this.user,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'],
      name: json['name'] ?? '',
      issuingOrganization: json['issuing_organization'] ?? '',
      issueDate: json['issue_date'] ?? '',
      expiryDate: json['expiry_date'],
      credentialId: json['credential_id'] ?? '',
      credentialUrl: json['credential_url'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'issuing_organization': issuingOrganization,
      'issue_date': issueDate,
      'expiry_date': expiryDate,
      'credential_id': credentialId,
      'credential_url': credentialUrl,
      'user': user,
    };
  }
}
