import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { AuthMailService } from './auth-mail.service';
import { SmtpSettingsService } from './smtp-settings.service';

jest.mock('nodemailer', () => ({
  createTransport: jest.fn(),
}));

describe('AuthMailService', () => {
  const mockedNodemailer = nodemailer as jest.Mocked<typeof nodemailer>;

  const makeConfig = (env: Record<string, string | undefined> = {}) =>
    ({
      get: jest.fn((key: string) => env[key]),
    }) as unknown as ConfigService;

  const makeSmtpSettings = (resolved: Awaited<ReturnType<SmtpSettingsService['getResolvedForSending']>>) =>
    ({
      getResolvedForSending: jest.fn().mockResolvedValue(resolved),
    }) as unknown as SmtpSettingsService;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('nao envia e-mail quando nao ha configuracao no banco nem no .env', async () => {
    const config = makeConfig();
    const smtpSettings = makeSmtpSettings(null);
    const service = new AuthMailService(config, smtpSettings);

    await service.sendResetPasswordEmail({
      to: 'gustavo12cristina@gmail.com',
      name: 'Usuario',
      token: 'abc123',
      expiresInMinutes: 60,
    });

    expect(mockedNodemailer.createTransport).not.toHaveBeenCalled();
  });

  it('envia usando configuracao do banco quando disponivel', async () => {
    const sendMail = jest.fn().mockResolvedValue(undefined);
    mockedNodemailer.createTransport.mockReturnValue({
      sendMail,
    } as unknown as nodemailer.Transporter);
    const config = makeConfig();
    const smtpSettings = makeSmtpSettings({
      host: 'smtp.db.local',
      port: 465,
      secure: true,
      username: 'mailer',
      password: 'secret',
      fromEmail: 'avisos@paroquia.local',
      fromName: 'Avisos Paroquia',
      resetBaseUrl: 'https://paroquia.local/reset-password',
    });
    const service = new AuthMailService(config, smtpSettings);

    await service.sendResetPasswordEmail({
      to: 'gustavo12cristina@gmail.com',
      name: 'Usuario',
      token: 'token-123',
      expiresInMinutes: 60,
    });

    expect(mockedNodemailer.createTransport).toHaveBeenCalledWith({
      host: 'smtp.db.local',
      port: 465,
      secure: true,
      auth: {
        user: 'mailer',
        pass: 'secret',
      },
    });
    expect(sendMail).toHaveBeenCalled();
    const args = (sendMail as jest.Mock).mock.calls[0][0] as { from: string; text: string };
    expect(args.from).toBe('"Avisos Paroquia" <avisos@paroquia.local>');
    expect(args.text).toContain('https://paroquia.local/reset-password?token=token-123');
  });

  it('usa fallback de variaveis de ambiente quando banco nao possui configuracao', async () => {
    const sendMail = jest.fn().mockResolvedValue(undefined);
    mockedNodemailer.createTransport.mockReturnValue({
      sendMail,
    } as unknown as nodemailer.Transporter);
    const config = makeConfig({
      SMTP_HOST: 'smtp.env.local',
      SMTP_PORT: '587',
      SMTP_SECURE: 'false',
      SMTP_USER: 'env-user',
      SMTP_PASS: 'env-pass',
      SMTP_FROM: 'env@paroquia.local',
      SMTP_FROM_NAME: 'Env Mailer',
      RESET_PASSWORD_BASE_URL: 'https://env.paroquia.local/reset',
    });
    const smtpSettings = makeSmtpSettings(null);
    const service = new AuthMailService(config, smtpSettings);

    await service.sendPasswordChangedEmail({
      to: 'gustavo12cristina@gmail.com',
      name: 'Usuario',
    });

    expect(mockedNodemailer.createTransport).toHaveBeenCalledWith({
      host: 'smtp.env.local',
      port: 587,
      secure: false,
      auth: {
        user: 'env-user',
        pass: 'env-pass',
      },
    });
    expect(sendMail).toHaveBeenCalled();
    const args = (sendMail as jest.Mock).mock.calls[0][0] as { from: string };
    expect(args.from).toBe('"Env Mailer" <env@paroquia.local>');
  });
});
