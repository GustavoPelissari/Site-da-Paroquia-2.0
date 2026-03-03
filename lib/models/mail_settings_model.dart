class MailSettingsModel {
  const MailSettingsModel({
    required this.configured,
    this.host,
    this.port = 587,
    this.secure = false,
    this.username,
    this.hasPassword = false,
    this.fromEmail,
    this.fromName,
    this.resetBaseUrl,
    this.updatedAt,
  });

  final bool configured;
  final String? host;
  final int port;
  final bool secure;
  final String? username;
  final bool hasPassword;
  final String? fromEmail;
  final String? fromName;
  final String? resetBaseUrl;
  final DateTime? updatedAt;
}

