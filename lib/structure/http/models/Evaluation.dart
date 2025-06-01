import 'ApplicationType.dart';
import 'User.dart';

class Evaluation {
  int? id;
  String? description;
  String? startDate;
  String? finalDate;
  String? link;
  String? register;
  ApplicationType? applicationType;
  User? user;

  Evaluation(
      {this.id,
        this.description,
        this.startDate,
        this.finalDate,
        this.link,
        this.register,
        this.applicationType,
        this.user});

  Evaluation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    startDate = json['startDate'];
    finalDate = json['finalDate'];
    link = json['link'];
    register = json['register'];
    applicationType = json['applicationType'] != null
        ? new ApplicationType.fromJson(json['applicationType'])
        : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['startDate'] = this.startDate;
    data['finalDate'] = this.finalDate;
    data['link'] = this.link;
    data['register'] = this.register;
    if (this.applicationType != null) {
      data['applicationType'] = this.applicationType!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}