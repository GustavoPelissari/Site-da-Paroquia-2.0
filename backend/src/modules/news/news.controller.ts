import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { AccessLevel } from '../../common/access-level';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateNewsDto } from './dto/create-news.dto';
import { NewsService } from './news.service';

@Controller('news')
export class NewsController {
  constructor(private readonly news: NewsService) {}

  @Get()
  findAll(@Query('groupId') groupId?: string) {
    const parsedGroupId = groupId ? Number(groupId) : undefined;
    return this.news.findAll(parsedGroupId);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Post()
  create(@Body() dto: CreateNewsDto) {
    return this.news.create(dto);
  }
}
