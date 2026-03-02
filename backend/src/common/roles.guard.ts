import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { MIN_ACCESS_LEVEL_KEY } from './roles.decorator';
import { AccessLevel } from './access-level';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const minLevel =
      this.reflector.getAllAndOverride<AccessLevel>(MIN_ACCESS_LEVEL_KEY, [
        ctx.getHandler(),
        ctx.getClass(),
      ]) ?? AccessLevel.USUARIO_PADRAO;

    const req = ctx.switchToHttp().getRequest();
    const user = req.user as { nivelAcesso?: number } | undefined;

    const current = user?.nivelAcesso ?? AccessLevel.USUARIO_PADRAO;
    return current >= minLevel;
  }
}
