class ActivityLog {
  final String userName;
  final String action;
  final String evaluationTitle;
  final String timestamp;
  final String? userImageUrl;

  ActivityLog({
    required this.userName,
    required this.action,
    required this.evaluationTitle,
    required this.timestamp,
    this.userImageUrl,
  });
}