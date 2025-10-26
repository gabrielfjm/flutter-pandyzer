  import 'User.dart';

  class Log {
    final int id;
    final String description;
    final User user;
    final String logTimestamp;

    Log({
      required this.id,
      required this.description,
      required this.user,
      required this.logTimestamp,
    });

    factory Log.fromJson(Map<String, dynamic> json) {
      return Log(
        id: json['id'],
        description: json['description'],
        user: User.fromJson(json['user']),
        logTimestamp: json['logTimestamp'],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'description': description,
        'user': user.toJson(),
        'logTimestamp': logTimestamp,
      };
    }
  }