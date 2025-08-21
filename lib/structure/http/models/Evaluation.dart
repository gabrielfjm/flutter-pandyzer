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
  bool isCurrentUserAnEvaluator;
  bool currentUserHasProblems;
  bool isPublic;
  int? evaluatorsLimit;

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
    this.isCurrentUserAnEvaluator = false,
    this.currentUserHasProblems = false,
    this.isPublic = false,
    this.evaluatorsLimit,
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
      isPublic: json['isPublic'] ?? false,
      evaluatorsLimit: json['evaluatorsLimit'],
      // Estes campos não vêm do JSON, serão populados no BLoC
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['startDate'] = startDate;
    data['finalDate'] = finalDate;
    data['link'] = link;
    data['register'] = register;
    if (applicationType != null) {
      data['applicationType'] = applicationType!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['isPublic'] = isPublic;
    data['evaluatorsLimit'] = evaluatorsLimit;
    return data;
  }
}