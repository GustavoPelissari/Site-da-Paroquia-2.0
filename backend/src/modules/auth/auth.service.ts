import { Injectable, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
  ) {}

  async login(email: string, senha: string) {
    const user = await this.users.findByEmail(email);
    if (!user) throw new UnauthorizedException('Credenciais inválidas');

    const ok = await bcrypt.compare(senha, user.senhaHash);
    if (!ok) throw new UnauthorizedException('Credenciais inválidas');

    const payload = {
      sub: user.id,
      email: user.email,
      nivelAcesso: user.nivelAcesso,
      nome: user.nome,
    };

    return {
      token: await this.jwt.signAsync(payload),
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
        nivelAcesso: user.nivelAcesso,
      },
    };
  }
}