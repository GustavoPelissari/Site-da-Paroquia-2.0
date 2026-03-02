import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { RegisterDto } from './dto/register.dto';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';
import { LoginRateLimitGuard } from './login-rate-limit.guard';

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
