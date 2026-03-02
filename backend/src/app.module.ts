import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuthModule } from './modules/auth/auth.module';
import { EventsModule } from './modules/events/events.module';
import { NewsModule } from './modules/news/news.module';
import { TimeModule } from './modules/time/time.module';
import { UsersModule } from './modules/users/users.module';
import { EventEntity } from './modules/events/event.entity';
import { NewsEntity } from './modules/news/news.entity';
import { UserEntity } from './modules/users/user.entity';

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
        entities: [UserEntity, EventEntity, NewsEntity],
        synchronize: false,
        charset: 'utf8mb4',
      }),
    }),

    UsersModule,
    AuthModule,
    EventsModule,
    NewsModule,
    TimeModule,
  ],
})
export class AppModule {}
