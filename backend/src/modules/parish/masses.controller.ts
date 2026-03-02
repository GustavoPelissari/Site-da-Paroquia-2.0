import { Controller, Get } from '@nestjs/common';
import { ParishService } from './parish.service';

@Controller('masses')
export class MassesController {
  constructor(private readonly parish: ParishService) {}

  @Get('next')
  next() {
    return this.parish.getNextMass(new Date());
  }
}
