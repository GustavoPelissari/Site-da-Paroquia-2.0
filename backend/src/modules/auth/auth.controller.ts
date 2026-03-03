import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { RegisterDto } from './dto/register.dto';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';
import { LoginRateLimitGuard } from './login-rate-limit.guard';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { ForgotPasswordRateLimitGuard } from './forgot-password-rate-limit.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @UseGuards(LoginRateLimitGuard)
  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto.email, dto.senha);
  }

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register({
      name: dto.name,
      email: dto.email,
      password: dto.password,
    });
  }

  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @UseGuards(ForgotPasswordRateLimitGuard)
  @Post('forgot-password')
  forgotPassword(
    @Body() dto: ForgotPasswordDto,
    @Req() req: { ip?: string; headers?: { ['user-agent']?: string } },
  ) {
    return this.auth.forgotPassword({
      email: dto.email,
      requestIp: req.ip ?? null,
      requestUserAgent: req.headers?.['user-agent'] ?? null,
    });
  }

  @Get('reset-password/validate')
  validateResetToken(@Query('token') token?: string) {
    return this.auth.validateResetToken(token);
  }

  @Post('reset-password')
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.auth.resetPassword(dto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@Req() req: { user: unknown }) {
    return req.user;
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  logout(@Req() req: { user: { id: number } }) {
    return this.auth.logout(req.user.id);
  }
}
