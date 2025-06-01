class Severity {
  int? id;
  String? description;
  int? weight;

  Severity({this.id, this.description, this.weight});

  Severity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    weight = json['weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['weight'] = this.weight;
    return data;
  }
}