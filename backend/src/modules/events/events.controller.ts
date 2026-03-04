import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { EventType } from './event.entity';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Controller('events')
export class EventsController {
  constructor(private readonly events: EventsService) {}

  @Get()
  findAll(@Query('tipo') tipo?: EventType, @Query('q') q?: string) {
    return this.events.findAll(tipo, q);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.events.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Post()
  create(@Body() dto: CreateEventDto) {
    return this.events.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateEventDto) {
    return this.events.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.events.remove(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Post(':id/duplicate')
  duplicate(@Param('id', ParseIntPipe) id: number) {
    return this.events.duplicate(id);
  }
}
