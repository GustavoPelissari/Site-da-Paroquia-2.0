import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RolesGuard } from '../../common/roles.guard';
import { NewsController } from './news.controller';
import { NewsEntity } from './news.entity';
import { NewsService } from './news.service';

@Module({
  imports: [TypeOrmModule.forFeature([NewsEntity])],
  controllers: [NewsController],
  providers: [NewsService, RolesGuard],
})
export class NewsModule {}
