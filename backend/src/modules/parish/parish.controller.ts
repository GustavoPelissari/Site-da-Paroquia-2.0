import { Controller, Get } from '@nestjs/common';
import { ParishService } from './parish.service';

@Controller('parish')
export class ParishController {
  constructor(private readonly parish: ParishService) {}

  @Get('info')
  info() {
    return this.parish.getParishInfo();
  }
}
