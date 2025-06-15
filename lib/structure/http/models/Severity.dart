class Severity {
  int? id;
  String? description;
  int? weight;

  Severity({this.id, this.description, this.weight});

  factory Severity.fromJson(Map<String, dynamic> json) {
    return Severity(
      id: json['id'],
      description: json['description'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['weight'] = weight;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Severity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}