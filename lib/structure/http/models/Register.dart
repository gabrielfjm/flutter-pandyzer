import 'Heuristic.dart';
import 'Objective.dart';
import 'Severity.dart';
import 'User.dart';

class Problem {
  int? id;
  String? description;
  String? recomendation;
  String? register;
  Objective? objective;
  Heuristic? heuristic;
  Severity? severity;
  User? user;

  Problem(
      {this.id,
        this.description,
        this.recomendation,
        this.register,
        this.objective,
        this.heuristic,
        this.severity,
        this.user});

  Problem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    recomendation = json['recomendation'];
    register = json['register'];
    objective = json['objective'] != null
        ? new Objective.fromJson(json['objective'])
        : null;
    heuristic = json['heuristic'] != null
        ? new Heuristic.fromJson(json['heuristic'])
        : null;
    severity = json['severity'] != null
        ? new Severity.fromJson(json['severity'])
        : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['recomendation'] = this.recomendation;
    data['register'] = this.register;
    if (this.objective != null) {
      data['objective'] = this.objective!.toJson();
    }
    if (this.heuristic != null) {
      data['heuristic'] = this.heuristic!.toJson();
    }
    if (this.severity != null) {
      data['severity'] = this.severity!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}