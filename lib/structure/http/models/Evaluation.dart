import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

class Evaluation {
  int? id;
  String? description;
  String? startDate;
  String? finalDate;
  String? link;
  String? register;
  ApplicationType? applicationType;
  User? user;
  int? completedEvaluationsCount;

  // Campos que virão da sua API para controlar a UI
  bool isCurrentUserAnEvaluator;
  bool currentUserHasProblems;

  Evaluation({
    this.id,
    this.description,
    this.startDate,
    this.finalDate,
    this.link,
    this.register,
    this.applicationType,
    this.user,
    this.completedEvaluationsCount,
    this.isCurrentUserAnEvaluator = false, // Valor padrão
    this.currentUserHasProblems = false, // Valor padrão
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      description: json['description'],
      startDate: json['startDate'],
      finalDate: json['finalDate'],
      link: json['link'],
      register: json['register'],
      applicationType: json['applicationType'] != null
          ? ApplicationType.fromJson(json['applicationType'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      completedEvaluationsCount: json['completedEvaluationsCount'],
      // Lendo os novos campos do JSON da API
      isCurrentUserAnEvaluator: json['isCurrentUserAnEvaluator'] ?? false,
      currentUserHasProblems: json['currentUserHasProblems'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['description'] = this.description;
    data['startDate'] = this.startDate;
    data['finalDate'] = this.finalDate;
    data['link'] = this.link;
    data['register'] = this.register;
    if (applicationType != null) {
      data['applicationType'] = applicationType!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}