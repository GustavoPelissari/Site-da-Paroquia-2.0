import { Controller, Get, Query } from '@nestjs/common';
import { EventType } from './event.entity';
import { EventsService } from './events.service';

@Controller('events')
export class EventsController {
  constructor(private readonly events: EventsService) {}

  @Get()
  findAll(@Query('tipo') tipo?: EventType) {
    return this.events.findAll(tipo);
  }
}
