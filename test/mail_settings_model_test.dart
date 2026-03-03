import 'package:flutter_test/flutter_test.dart';
import 'package:paroquia_mvp/models/mail_settings_model.dart';

void main() {
  group('MailSettingsModel', () {
    test('config padrao desabilitada', () {
      const model = MailSettingsModel(configured: false);

      expect(model.configured, false);
      expect(model.port, 587);
      expect(model.secure, false);
      expect(model.hasPassword, false);
      expect(model.host, isNull);
      expect(model.fromEmail, isNull);
    });

    test('aceita configuracao completa', () {
      final updatedAt = DateTime.parse('2026-03-03T12:00:00.000Z');
      final model = MailSettingsModel(
        configured: true,
        host: 'smtp.paroquia.local',
        port: 465,
        secure: true,
        username: 'mailer',
        hasPassword: true,
        fromEmail: 'avisos@paroquia.local',
        fromName: 'Avisos',
        resetBaseUrl: 'https://paroquia.local/reset',
        updatedAt: updatedAt,
      );

      expect(model.configured, true);
      expect(model.host, 'smtp.paroquia.local');
      expect(model.port, 465);
      expect(model.secure, true);
      expect(model.username, 'mailer');
      expect(model.hasPassword, true);
      expect(model.fromEmail, 'avisos@paroquia.local');
      expect(model.fromName, 'Avisos');
      expect(model.resetBaseUrl, 'https://paroquia.local/reset');
      expect(model.updatedAt, updatedAt);
    });
  });
}

