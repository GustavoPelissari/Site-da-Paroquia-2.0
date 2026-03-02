import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { EventType } from './event.entity';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';

@Controller('events')
export class EventsController {
  constructor(private readonly events: EventsService) {}

  @Get()
  findAll(@Query('tipo') tipo?: EventType) {
    return this.events.findAll(tipo);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
  @Post()
  create(@Body() dto: CreateEventDto) {
    return this.events.create(dto);
  }
}
