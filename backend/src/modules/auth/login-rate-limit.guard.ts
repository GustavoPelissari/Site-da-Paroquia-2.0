import { CanActivate, ExecutionContext, HttpException, HttpStatus, Injectable } from '@nestjs/common';

type Attempt = {
  count: number;
  firstAt: number;
};

@Injectable()
export class LoginRateLimitGuard implements CanActivate {
  private readonly attempts = new Map<string, Attempt>();
  private readonly windowMs = 60_000;
  private readonly maxAttempts = 5;

  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<{
      ip?: string;
      body?: { email?: string };
    }>();

    const ip = req.ip ?? 'unknown-ip';
    const email = (req.body?.email ?? 'unknown-email').toLowerCase();
    const key = `${ip}:${email}`;
    const now = Date.now();
    const current = this.attempts.get(key);

    if (!current || now - current.firstAt > this.windowMs) {
      this.attempts.set(key, { count: 1, firstAt: now });
      return true;
    }

    if (current.count >= this.maxAttempts) {
      throw new HttpException(
        'Muitas tentativas de login. Tente novamente em 1 minuto.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    current.count += 1;
    this.attempts.set(key, current);
    return true;
  }
}
