import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { ExtractJwt, Strategy } from 'passport-jwt';

type JwtPayload = {
  sub: number;
  user_id?: number;
  email: string;
  nivel_acesso: number;
  nome: string;
  type?: string;
};

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(cfg: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: cfg.get<string>('JWT_SECRET'),
    });
  }

  validate(payload: JwtPayload) {
    if (payload.type !== 'access') {
      throw new UnauthorizedException('Token de acesso invalido');
    }

    return {
      id: payload.user_id ?? payload.sub,
      email: payload.email,
      nome: payload.nome,
      nivelAcesso: payload.nivel_acesso,
    };
  }
}
