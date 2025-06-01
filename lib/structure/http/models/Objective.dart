import 'Evaluation.dart';

class Objective {
  int? id;
  String? description;
  String? register;
  Evaluation? evaluation;

  Objective({this.id, this.description, this.register, this.evaluation});

  Objective.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    register = json['register'];
    evaluation = json['evaluation'] != null
        ? new Evaluation.fromJson(json['evaluation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['register'] = this.register;
    if (this.evaluation != null) {
      data['evaluation'] = this.evaluation!.toJson();
    }
    return data;
  }
}