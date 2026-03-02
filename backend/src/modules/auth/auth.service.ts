import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

import { AccessLevel } from '../../common/access-level';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
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
}
