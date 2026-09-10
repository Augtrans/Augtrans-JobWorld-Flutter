class RoleModel {
  final int id;
  final String name;
  final List<dynamic>? permissions;

  RoleModel({
    required this.id,
    required this.name,
    this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      permissions: json['permissions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions,
    };
  }
}
