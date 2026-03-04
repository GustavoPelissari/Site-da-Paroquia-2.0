import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { AccessLevel } from '../../common/access-level';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateNewsDto } from './dto/create-news.dto';
import { UpdateNewsDto } from './dto/update-news.dto';
import { NewsService } from './news.service';

@Controller('news')
export class NewsController {
  constructor(private readonly news: NewsService) {}

  @Get()
  findAll(@Query('groupId') groupId?: string, @Query('q') q?: string) {
    const parsedGroupId = groupId ? Number(groupId) : undefined;
    return this.news.findAll(parsedGroupId, q);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.news.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Post()
  create(@Body() dto: CreateNewsDto) {
    return this.news.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateNewsDto) {
    return this.news.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.news.remove(id);
  }
}
