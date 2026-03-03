import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UpdateSmtpSettingsDto } from './dto/update-smtp-settings.dto';
import { SmtpSettingsEntity } from './smtp-settings.entity';

export type SmtpSettingsView = {
  host: string;
  port: number;
  secure: boolean;
  username: string | null;
  hasPassword: boolean;
  fromEmail: string;
  fromName: string | null;
  resetBaseUrl: string | null;
  updatedAt: string;
};

@Injectable()
export class SmtpSettingsService {
  constructor(
    @InjectRepository(SmtpSettingsEntity)
    private readonly repo: Repository<SmtpSettingsEntity>,
  ) {}

  async getForAdmin(): Promise<SmtpSettingsView | null> {
    const current = await this.repo.findOne({
      order: { id: 'DESC' },
    });
    if (!current) return null;
    return this.toView(current);
  }

  async upsert(dto: UpdateSmtpSettingsDto): Promise<SmtpSettingsView> {
    const hasUsername = !!dto.username?.trim();
    if (hasUsername && dto.password === null) {
      throw new BadRequestException('Informe a senha SMTP ao definir um usuario SMTP.');
    }

    const current = await this.repo.findOne({ order: { id: 'DESC' } });
    const entity = current ?? this.repo.create();
    entity.host = dto.host.trim();
    entity.port = dto.port;
    entity.secure = dto.secure;
    entity.username = dto.username?.trim() || null;
    if (!entity.username) {
      entity.password = null;
    }
    if (typeof dto.password === 'string') {
      entity.password = dto.password;
    } else if (dto.password === null) {
      entity.password = null;
    } else if (!current) {
      entity.password = null;
    }
    entity.fromEmail = dto.fromEmail.trim().toLowerCase();
    entity.fromName = dto.fromName?.trim() || null;
    entity.resetBaseUrl = dto.resetBaseUrl?.trim() || null;

    const saved = await this.repo.save(entity);
    return this.toView(saved);
  }

  async getResolvedForSending(): Promise<{
    host: string;
    port: number;
    secure: boolean;
    username: string | null;
    password: string | null;
    fromEmail: string;
    fromName: string | null;
    resetBaseUrl: string | null;
  } | null> {
    const current = await this.repo.findOne({
      order: { id: 'DESC' },
    });
    if (!current) return null;
    return {
      host: current.host,
      port: current.port,
      secure: !!current.secure,
      username: current.username,
      password: current.password,
      fromEmail: current.fromEmail,
      fromName: current.fromName,
      resetBaseUrl: current.resetBaseUrl,
    };
  }

  private toView(item: SmtpSettingsEntity): SmtpSettingsView {
    return {
      host: item.host,
      port: item.port,
      secure: !!item.secure,
      username: item.username,
      hasPassword: !!item.password,
      fromEmail: item.fromEmail,
      fromName: item.fromName,
      resetBaseUrl: item.resetBaseUrl,
      updatedAt: item.updatedAt.toISOString(),
    };
  }
}
