import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UsersModule } from '../users/users.module';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';
import { JwtAuthGuard } from './jwt-auth.guard';
import { LoginRateLimitGuard } from './login-rate-limit.guard';
import { PasswordResetTokenEntity } from './password-reset-token.entity';
import { AuthMailService } from './auth-mail.service';
import { ForgotPasswordRateLimitGuard } from './forgot-password-rate-limit.guard';
import { SmtpSettingsEntity } from './smtp-settings.entity';
import { AuthAdminController } from './auth-admin.controller';
import { SmtpSettingsService } from './smtp-settings.service';
import { RolesGuard } from '../../common/roles.guard';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    TypeOrmModule.forFeature([PasswordResetTokenEntity, SmtpSettingsEntity]),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        secret: cfg.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: cfg.get<string>('JWT_EXPIRES_IN') ?? '7d' },
      }),
    }),
  ],
  controllers: [AuthController, AuthAdminController],
  providers: [
    AuthService,
    AuthMailService,
    SmtpSettingsService,
    JwtStrategy,
    JwtAuthGuard,
    RolesGuard,
    LoginRateLimitGuard,
    ForgotPasswordRateLimitGuard,
  ],
})
export class AuthModule {}
