class OrgRegisterReqModel {
  final String name;
  final String gstin;
  final int organizationSize;
  final String country;

  OrgRegisterReqModel({
    required this.name,
    required this.gstin,
    required this.organizationSize,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gstin': gstin,
      'organization_size': organizationSize,
      'country': country,
    };
  }
}
