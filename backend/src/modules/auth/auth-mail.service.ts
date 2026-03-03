import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class AuthMailService {
  private readonly logger = new Logger(AuthMailService.name);
  private readonly fromEmail: string | null;
  private readonly resetBaseUrl: string;
  private readonly transport: nodemailer.Transporter | null;

  constructor(private readonly config: ConfigService) {
    const host = this.config.get<string>('SMTP_HOST')?.trim();
    const port = Number(this.config.get<string>('SMTP_PORT') ?? 587);
    const secure = String(this.config.get<string>('SMTP_SECURE') ?? 'false') === 'true';
    const user = this.config.get<string>('SMTP_USER')?.trim();
    const pass = this.config.get<string>('SMTP_PASS')?.trim();
    this.fromEmail = this.config.get<string>('SMTP_FROM')?.trim() ?? null;
    this.resetBaseUrl =
      this.config.get<string>('RESET_PASSWORD_BASE_URL')?.trim() ??
      'http://localhost:3000/reset-password';

    if (!host || !this.fromEmail) {
      this.transport = null;
      return;
    }

    this.transport = nodemailer.createTransport({
      host,
      port,
      secure,
      auth: user && pass ? { user, pass } : undefined,
    });
  }

  async sendResetPasswordEmail(params: {
    to: string;
    name: string;
    token: string;
    expiresInMinutes: number;
  }) {
    const resetUrl = `${this.resetBaseUrl}?token=${encodeURIComponent(params.token)}`;
    const subject = 'Redefinicao de senha - Paroquia Sao Paulo Apostolo';
    const text =
      `Ola, ${params.name}.\n\n` +
      `Recebemos um pedido para redefinir sua senha.\n` +
      `Use este link para continuar: ${resetUrl}\n\n` +
      `O link expira em ${params.expiresInMinutes} minutos e pode ser usado uma unica vez.\n` +
      `Se voce nao solicitou essa alteracao, ignore este e-mail.\n`;

    await this.sendOrLog({
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

    await this.sendOrLog({
      to: params.to,
      subject,
      text,
    });
  }

  private async sendOrLog(params: { to: string; subject: string; text: string }) {
    if (!this.transport || !this.fromEmail) {
      this.logger.warn(
        `SMTP nao configurado. Email nao enviado para ${params.to}. Assunto: ${params.subject}`,
      );
      this.logger.debug(params.text);
      return;
    }

    await this.transport.sendMail({
      from: this.fromEmail,
      to: params.to,
      subject: params.subject,
      text: params.text,
    });
  }
}
