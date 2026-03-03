import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { SmtpSettingsService } from './smtp-settings.service';

@Injectable()
export class AuthMailService {
  private readonly logger = new Logger(AuthMailService.name);
  private readonly envHost: string | null;
  private readonly envPort: number;
  private readonly envSecure: boolean;
  private readonly envUser: string | null;
  private readonly envPass: string | null;
  private readonly envFromEmail: string | null;
  private readonly envFromName: string | null;
  private readonly envResetBaseUrl: string;

  constructor(
    private readonly config: ConfigService,
    private readonly smtpSettings: SmtpSettingsService,
  ) {
    this.envHost = this.config.get<string>('SMTP_HOST')?.trim() ?? null;
    this.envPort = Number(this.config.get<string>('SMTP_PORT') ?? 587);
    this.envSecure = String(this.config.get<string>('SMTP_SECURE') ?? 'false') === 'true';
    this.envUser = this.config.get<string>('SMTP_USER')?.trim() ?? null;
    this.envPass = this.config.get<string>('SMTP_PASS')?.trim() ?? null;
    this.envFromEmail = this.config.get<string>('SMTP_FROM')?.trim() ?? null;
    this.envFromName = this.config.get<string>('SMTP_FROM_NAME')?.trim() ?? null;
    this.envResetBaseUrl =
      this.config.get<string>('RESET_PASSWORD_BASE_URL')?.trim() ??
      'http://localhost:3000/reset-password';
  }

  async sendResetPasswordEmail(params: {
    to: string;
    name: string;
    token: string;
    expiresInMinutes: number;
  }) {
    const transport = await this.resolveTransportConfig();
    if (!transport) {
      this.logger.warn(`SMTP nao configurado. Email nao enviado para ${params.to}.`);
      return;
    }

    const resetBaseUrl = transport.resetBaseUrl ?? this.envResetBaseUrl;
    const resetUrl = `${resetBaseUrl}?token=${encodeURIComponent(params.token)}`;
    const subject = 'Redefinicao de senha - Paroquia Sao Paulo Apostolo';
    const text =
      `Ola, ${params.name}.\n\n` +
      `Recebemos um pedido para redefinir sua senha.\n` +
      `Use este link para continuar: ${resetUrl}\n\n` +
      `O link expira em ${params.expiresInMinutes} minutos e pode ser usado uma unica vez.\n` +
      `Se voce nao solicitou essa alteracao, ignore este e-mail.\n`;

    await this.send({
      transport,
      to: params.to,
      subject,
      text,
    });
  }

  async sendPasswordChangedEmail(params: { to: string; name: string }) {
    const subject = 'Senha alterada com sucesso - Paroquia Sao Paulo Apostolo';
    const text =
      `Ola, ${params.name}.\n\n` +
      'Sua senha foi alterada com sucesso.\n' +
      'Se voce nao reconhece essa acao, entre em contato com a secretaria imediatamente.\n';

    const transport = await this.resolveTransportConfig();
    if (!transport) {
      this.logger.warn(`SMTP nao configurado. Email de confirmacao nao enviado para ${params.to}.`);
      return;
    }

    await this.send({
      transport,
      to: params.to,
      subject,
      text,
    });
  }

  private async resolveTransportConfig(): Promise<{
    host: string;
    port: number;
    secure: boolean;
    username: string | null;
    password: string | null;
    fromEmail: string;
    fromName: string | null;
    resetBaseUrl: string | null;
  } | null> {
    const dbConfig = await this.smtpSettings.getResolvedForSending();
    if (dbConfig?.host && dbConfig?.fromEmail) {
      return dbConfig;
    }

    if (!this.envHost || !this.envFromEmail) {
      return null;
    }

    return {
      host: this.envHost,
      port: this.envPort,
      secure: this.envSecure,
      username: this.envUser,
      password: this.envPass,
      fromEmail: this.envFromEmail,
      fromName: this.envFromName,
      resetBaseUrl: this.envResetBaseUrl,
    };
  }

  private async send(params: {
    transport: {
      host: string;
      port: number;
      secure: boolean;
      username: string | null;
      password: string | null;
      fromEmail: string;
      fromName: string | null;
    };
    to: string;
    subject: string;
    text: string;
  }) {
    const transporter = nodemailer.createTransport({
      host: params.transport.host,
      port: params.transport.port,
      secure: params.transport.secure,
      auth:
        params.transport.username != null && params.transport.password != null
          ? {
              user: params.transport.username,
              pass: params.transport.password,
            }
          : undefined,
    });

    const from = params.transport.fromName
      ? `"${params.transport.fromName}" <${params.transport.fromEmail}>`
      : params.transport.fromEmail;

    await transporter.sendMail({
      from,
      to: params.to,
      subject: params.subject,
      text: params.text,
    });
  }
}
