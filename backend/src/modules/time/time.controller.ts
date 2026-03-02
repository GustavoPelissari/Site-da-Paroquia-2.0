import { Controller, Get } from '@nestjs/common';

@Controller('time')
export class TimeController {
  @Get()
  now() {
    return {
      now: new Date().toISOString(),
    };
  }
}
