class Heuristic {
  int? id;
  String? description;
  String? register;

  Heuristic({this.id, this.description, this.register});

  factory Heuristic.fromJson(Map<String, dynamic> json) {
    return Heuristic(
      id: json['id'],
      description: json['description'],
      register: json['register'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['register'] = register;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Heuristic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}