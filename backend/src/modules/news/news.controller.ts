import { Controller, Get, Query } from '@nestjs/common';
import { NewsService } from './news.service';

@Controller('news')
export class NewsController {
  constructor(private readonly news: NewsService) {}

  @Get()
  findAll(@Query('groupId') groupId?: string) {
    const parsedGroupId = groupId ? Number(groupId) : undefined;
    return this.news.findAll(parsedGroupId);
  }
}
