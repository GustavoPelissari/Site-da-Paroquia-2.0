import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuthModule } from './modules/auth/auth.module';
import { EventsModule } from './modules/events/events.module';
import { NewsModule } from './modules/news/news.module';
import { TimeModule } from './modules/time/time.module';
import { UsersModule } from './modules/users/users.module';
import { MassSchedulesModule } from './modules/mass-schedules/mass-schedules.module';
import { UploadsModule } from './modules/uploads/uploads.module';
import { EventEntity } from './modules/events/event.entity';
import { MassScheduleEntity } from './modules/mass-schedules/mass-schedule.entity';
import { NewsEntity } from './modules/news/news.entity';
import { OfficeHourEntity } from './modules/mass-schedules/office-hour.entity';
import { UserEntity } from './modules/users/user.entity';
import { PasswordResetTokenEntity } from './modules/auth/password-reset-token.entity';
import { SmtpSettingsEntity } from './modules/auth/smtp-settings.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'mysql',
        host: cfg.get<string>('DB_HOST'),
        port: Number(cfg.get<string>('DB_PORT') ?? 3306),
        username: cfg.get<string>('DB_USER'),
        password: cfg.get<string>('DB_PASS'),
        database: cfg.get<string>('DB_NAME'),
        entities: [
          UserEntity,
          EventEntity,
          NewsEntity,
          MassScheduleEntity,
          OfficeHourEntity,
          PasswordResetTokenEntity,
          SmtpSettingsEntity,
        ],
        synchronize: false,
        charset: 'utf8mb4',
      }),
    }),

    UsersModule,
    AuthModule,
    EventsModule,
    NewsModule,
    TimeModule,
    MassSchedulesModule,
    UploadsModule,
  ],
})
export class AppModule {}
