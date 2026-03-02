import { Controller, Get } from '@nestjs/common';
import { MassSchedulesService } from './mass-schedules.service';

@Controller('public')
export class PublicMassSchedulesController {
  constructor(private readonly schedules: MassSchedulesService) {}

  @Get('mass-schedules')
  findMassSchedules() {
    return this.schedules.findActiveMassSchedules();
  }

  @Get('office-hours')
  findOfficeHours() {
    return this.schedules.findActiveOfficeHours();
  }

  @Get('masses/next')
  findNextMass() {
    return this.schedules.findNextMass(new Date());
  }
}
