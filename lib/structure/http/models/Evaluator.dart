import 'package:flutter_pandyzer/structure/http/models/Status.dart';

import 'Evaluation.dart';
import 'User.dart';

class Evaluator {
  int? id;
  String? register;
  User? user;
  Evaluation? evaluation;
  Status? status;

  Evaluator({this.id, this.register, this.user, this.evaluation, this.status});

  Evaluator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    register = json['register'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    evaluation = json['evaluation'] != null
        ? new Evaluation.fromJson(json['evaluation'])
        : null;
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['register'] = this.register;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.evaluation != null) {
      data['evaluation'] = this.evaluation!.toJson();
    }
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}