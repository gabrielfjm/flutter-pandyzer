import 'UserType.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? password;
  int? active;
  String? register;
  UserType? userType;

  User(
      {this.id,
        this.name,
        this.email,
        this.password,
        this.active,
        this.register,
        this.userType});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    active = json['active'];
    register = json['register'];
    userType = json['userType'] != null
        ? new UserType.fromJson(json['userType'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['active'] = this.active;
    data['register'] = this.register;
    if (this.userType != null) {
      data['userType'] = this.userType!.toJson();
    }
    return data;
  }
}