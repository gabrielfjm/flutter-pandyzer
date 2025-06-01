class Heuristic {
  int? id;
  String? description;
  String? register;

  Heuristic({this.id, this.description, this.register});

  Heuristic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    register = json['register'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['register'] = this.register;
    return data;
  }
}