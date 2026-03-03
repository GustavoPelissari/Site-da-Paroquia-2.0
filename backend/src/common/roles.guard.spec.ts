import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AccessLevel } from './access-level';
import { RolesGuard } from './roles.guard';

describe('RolesGuard', () => {
  const makeContext = (nivelAcesso?: number): ExecutionContext =>
    ({
      getHandler: jest.fn(),
      getClass: jest.fn(),
      switchToHttp: () => ({
        getRequest: () => ({
          user: nivelAcesso == null ? undefined : { nivelAcesso },
        }),
      }),
    }) as unknown as ExecutionContext;

  it('bloqueia quando usuario nao existe na request', () => {
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(AccessLevel.USUARIO_PADRAO),
    } as unknown as Reflector;
    const guard = new RolesGuard(reflector);

    expect(guard.canActivate(makeContext())).toBe(false);
  });

  it('permite quando nivel atual atende o minimo exigido', () => {
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(AccessLevel.COORDENADOR),
    } as unknown as Reflector;
    const guard = new RolesGuard(reflector);

    expect(guard.canActivate(makeContext(2))).toBe(true);
  });

  it('bloqueia quando nivel atual e menor que o minimo', () => {
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(AccessLevel.ADMINISTRATIVO),
    } as unknown as Reflector;
    const guard = new RolesGuard(reflector);

    expect(guard.canActivate(makeContext(2))).toBe(false);
  });

  it('usa nivel padrao quando metadata nao foi definido', () => {
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(undefined),
    } as unknown as Reflector;
    const guard = new RolesGuard(reflector);

    expect(guard.canActivate(makeContext(0))).toBe(true);
  });
});

