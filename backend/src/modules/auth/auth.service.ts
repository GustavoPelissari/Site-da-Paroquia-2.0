import { BadRequestException, ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { Repository } from 'typeorm';

import { AccessLevel } from '../../common/access-level';
import { UsersService } from '../users/users.service';
import { PasswordResetTokenEntity } from './password-reset-token.entity';
import { AuthMailService } from './auth-mail.service';

@Injectable()
export class AuthService {
  private static readonly forgotPasswordResponse = {
    message:
      'Se o e-mail estiver cadastrado, voce recebera instrucoes para redefinir sua senha.',
  };
  private static readonly resetTokenTtlMinutes = 60;

  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly mailService: AuthMailService,
    @InjectRepository(PasswordResetTokenEntity)
    private readonly resetTokens: Repository<PasswordResetTokenEntity>,
  ) {}

  async login(email: string, senha: string) {
    const user = await this.validateUser(email, senha);
    return this.issueSessionTokens(user);
  }

  async register(input: { name: string; email: string; password: string }) {
    const normalizedEmail = input.email.trim().toLowerCase();
    const existing = await this.users.findByEmail(normalizedEmail);
    if (existing) {
      throw new ConflictException('Email ja cadastrado');
    }

    const senhaHash = await bcrypt.hash(input.password, 10);
    const created = await this.users.createUser({
      nome: input.name.trim(),
      email: normalizedEmail,
      senhaHash,
      nivelAcesso: AccessLevel.USUARIO_PADRAO,
    });

    return this.issueSessionTokens(created);
  }

  async refresh(refreshToken: string) {
    const payload = await this.jwt.verifyAsync<{
      sub: number;
      type?: string;
    }>(refreshToken);

    if (payload.type !== 'refresh') {
      throw new UnauthorizedException('Refresh token invalido');
    }

    const user = await this.users.findByIdWithRefreshToken(payload.sub);
    if (!user || !user.refreshTokenHash) {
      throw new UnauthorizedException('Sessao invalida');
    }

    const refreshMatches = await bcrypt.compare(refreshToken, user.refreshTokenHash);
    if (!refreshMatches) {
      throw new UnauthorizedException('Sessao invalida');
    }

    return this.issueSessionTokens(user);
  }

  async logout(userId: number) {
    await this.users.clearRefreshTokenHash(userId);
  }

  async forgotPassword(input: {
    email: string;
    requestIp: string | null;
    requestUserAgent: string | null;
  }) {
    const normalizedEmail = input.email.trim().toLowerCase();
    const user = await this.users.findByEmail(normalizedEmail);
    if (!user) {
      return AuthService.forgotPasswordResponse;
    }

    const rawToken = randomBytes(32).toString('hex');
    const tokenHash = this.hashToken(rawToken);
    const expiresAt = new Date(Date.now() + AuthService.resetTokenTtlMinutes * 60_000);

    const token = this.resetTokens.create({
      userId: user.id,
      tokenHash,
      expiresAt,
      usedAt: null,
      requestIp: input.requestIp?.slice(0, 64) ?? null,
      requestUserAgent: input.requestUserAgent?.slice(0, 255) ?? null,
    });
    await this.resetTokens.save(token);

    await this.mailService.sendResetPasswordEmail({
      to: user.email,
      name: user.nome,
      token: rawToken,
      expiresInMinutes: AuthService.resetTokenTtlMinutes,
    });

    return AuthService.forgotPasswordResponse;
  }

  async validateResetToken(token?: string) {
    if (!token) {
      return { valid: false };
    }
    const hash = this.hashToken(token);
    const entity = await this.resetTokens.findOne({
      where: {
        tokenHash: hash,
      },
    });
    if (!entity || entity.usedAt || entity.expiresAt.getTime() < Date.now()) {
      return { valid: false };
    }
    return { valid: true };
  }

  async resetPassword(input: { token: string; password: string; confirmPassword: string }) {
    if (input.password !== input.confirmPassword) {
      throw new BadRequestException('Senha e confirmacao precisam ser iguais.');
    }

    const tokenHash = this.hashToken(input.token);
    const token = await this.resetTokens.findOne({
      where: { tokenHash },
    });

    if (!token || token.usedAt || token.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException('Token de redefinicao invalido ou expirado.');
    }

    const user = await this.users.findById(token.userId);
    if (!user) {
      throw new UnauthorizedException('Token de redefinicao invalido ou expirado.');
    }

    const senhaHash = await bcrypt.hash(input.password, 10);
    await this.users.updatePasswordHash(user.id, senhaHash);
    await this.users.clearRefreshTokenHash(user.id);

    token.usedAt = new Date();
    await this.resetTokens.save(token);

    await this.resetTokens
      .createQueryBuilder()
      .delete()
      .from(PasswordResetTokenEntity)
      .where('user_id = :userId', { userId: user.id })
      .andWhere('used_at IS NULL')
      .andWhere('expires_at < :now', { now: new Date() })
      .execute();

    await this.mailService.sendPasswordChangedEmail({
      to: user.email,
      name: user.nome,
    });

    return { message: 'Senha redefinida com sucesso. Faca login novamente.' };
  }

  private async validateUser(email: string, senha: string) {
    const normalizedEmail = email.trim().toLowerCase();
    const user = await this.users.findByEmail(normalizedEmail);
    if (!user) throw new UnauthorizedException('Credenciais invalidas');

    const ok = await bcrypt.compare(senha, user.senhaHash);
    if (!ok) throw new UnauthorizedException('Credenciais invalidas');

    if (
      user.nivelAcesso < AccessLevel.USUARIO_PADRAO ||
      user.nivelAcesso > AccessLevel.ADMINISTRATIVO
    ) {
      throw new UnauthorizedException('Nivel de acesso invalido');
    }

    return user;
  }

  private async issueSessionTokens(user: {
    id: number;
    nome: string;
    email: string;
    nivelAcesso: number;
  }) {
    const accessPayload = {
      sub: user.id,
      user_id: user.id,
      email: user.email,
      nivel_acesso: user.nivelAcesso,
      nome: user.nome,
      type: 'access',
    };

    const refreshPayload = {
      sub: user.id,
      type: 'refresh',
    };

    const token = await this.jwt.signAsync(accessPayload);
    const refreshToken = await this.jwt.signAsync(refreshPayload, {
      expiresIn: '30d',
    });

    const refreshTokenHash = await bcrypt.hash(refreshToken, 10);
    try {
      await this.users.updateRefreshTokenHash(user.id, refreshTokenHash);
    } catch (_) {
      // Compatibilidade com bancos legados sem coluna refresh_token_hash.
    }

    return {
      token,
      refreshToken,
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
        nivelAcesso: user.nivelAcesso,
      },
    };
  }

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }
}
