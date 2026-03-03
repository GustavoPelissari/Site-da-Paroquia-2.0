import { BadRequestException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { UpdateSmtpSettingsDto } from './dto/update-smtp-settings.dto';
import { SmtpSettingsEntity } from './smtp-settings.entity';
import { SmtpSettingsService } from './smtp-settings.service';

describe('SmtpSettingsService', () => {
  const makeRepo = () =>
    ({
      findOne: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
    }) as unknown as Repository<SmtpSettingsEntity>;

  it('retorna null quando nao ha configuracao para admin', async () => {
    const repo = makeRepo();
    (repo.findOne as jest.Mock).mockResolvedValue(null);
    const service = new SmtpSettingsService(repo);

    await expect(service.getForAdmin()).resolves.toBeNull();
  });

  it('rejeita quando usuario SMTP e informado sem senha', async () => {
    const repo = makeRepo();
    const service = new SmtpSettingsService(repo);
    const dto: UpdateSmtpSettingsDto = {
      host: 'smtp.test.local',
      port: 587,
      secure: false,
      username: 'mailer',
      password: null,
      fromEmail: 'admin@paroquia.local',
      fromName: null,
      resetBaseUrl: null,
    };

    await expect(service.upsert(dto)).rejects.toBeInstanceOf(BadRequestException);
  });

  it('cria configuracao nova e normaliza email remetente', async () => {
    const repo = makeRepo();
    (repo.findOne as jest.Mock).mockResolvedValue(null);
    const created = {
      id: 1,
      host: '',
      port: 0,
      secure: false,
      username: null,
      password: null,
      fromEmail: '',
      fromName: null,
      resetBaseUrl: null,
      createdAt: new Date('2026-03-03T12:00:00.000Z'),
      updatedAt: new Date('2026-03-03T12:00:00.000Z'),
    } as SmtpSettingsEntity;
    (repo.create as jest.Mock).mockReturnValue(created);
    (repo.save as jest.Mock).mockImplementation(async (value: SmtpSettingsEntity) => value);
    const service = new SmtpSettingsService(repo);

    const dto: UpdateSmtpSettingsDto = {
      host: 'smtp.test.local',
      port: 465,
      secure: true,
      username: 'mailer',
      password: 'secret',
      fromEmail: 'Avisos@Paroquia.Local',
      fromName: 'Sistema',
      resetBaseUrl: 'https://paroquia.local/reset',
    };

    const saved = await service.upsert(dto);

    expect(saved.host).toBe('smtp.test.local');
    expect(saved.port).toBe(465);
    expect(saved.secure).toBe(true);
    expect(saved.username).toBe('mailer');
    expect(saved.hasPassword).toBe(true);
    expect(saved.fromEmail).toBe('avisos@paroquia.local');
    expect(saved.fromName).toBe('Sistema');
    expect(saved.resetBaseUrl).toBe('https://paroquia.local/reset');
  });

  it('retorna config resolvida para envio', async () => {
    const repo = makeRepo();
    (repo.findOne as jest.Mock).mockResolvedValue({
      host: 'smtp.mail.local',
      port: 587,
      secure: false,
      username: 'mailer',
      password: 'secret',
      fromEmail: 'mailer@paroquia.local',
      fromName: 'Paroquia',
      resetBaseUrl: 'https://paroquia.local/reset',
    } as SmtpSettingsEntity);
    const service = new SmtpSettingsService(repo);

    const config = await service.getResolvedForSending();
    expect(config).toEqual({
      host: 'smtp.mail.local',
      port: 587,
      secure: false,
      username: 'mailer',
      password: 'secret',
      fromEmail: 'mailer@paroquia.local',
      fromName: 'Paroquia',
      resetBaseUrl: 'https://paroquia.local/reset',
    });
  });
});

