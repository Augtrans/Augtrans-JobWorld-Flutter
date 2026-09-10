class RegisterResModel {
  final bool? status;
  final String? message;
  final RegistrationData? data;

  RegisterResModel({
    this.status,
    this.message,
    this.data,
  });

  factory RegisterResModel.fromJson(Map<String, dynamic> json) {
    return RegisterResModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? RegistrationData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class RegistrationData {
  final int? id;
  final String? username;
  final String? email;

  RegistrationData({
    this.id,
    this.username,
    this.email,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}
