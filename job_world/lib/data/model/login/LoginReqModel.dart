class LoginReqModel{
  final String username;
  final String password;

  LoginReqModel({
    required this.username,
    required this.password
  });

  Map<String, dynamic> toJson(){
    return {
      'username':username,
      'password':password
    };
  }
}