import { Body, Controller, Param, ParseIntPipe, Patch, Post, UseGuards } from '@nestjs/common';
import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateMassScheduleDto } from './dto/create-mass-schedule.dto';
import { CreateOfficeHourDto } from './dto/create-office-hour.dto';
import { UpdateMassScheduleDto } from './dto/update-mass-schedule.dto';
import { UpdateOfficeHourDto } from './dto/update-office-hour.dto';
import { MassSchedulesService } from './mass-schedules.service';

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
@MinAccessLevel(AccessLevel.MEMBRO_PASTORAL)
export class MassSchedulesController {
  constructor(private readonly schedules: MassSchedulesService) {}

  @Post('mass-schedules')
  createMass(@Body() dto: CreateMassScheduleDto) {
    return this.schedules.createMassSchedule(dto);
  }

  @Patch('mass-schedules/:id')
  updateMass(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateMassScheduleDto,
  ) {
    return this.schedules.updateMassSchedule(id, dto);
  }

  @Patch('mass-schedules/:id/deactivate')
  deactivateMass(@Param('id', ParseIntPipe) id: number) {
    return this.schedules.deactivateMassSchedule(id);
  }

  @Post('office-hours')
  createOfficeHour(@Body() dto: CreateOfficeHourDto) {
    return this.schedules.createOfficeHour(dto);
  }

  @Patch('office-hours/:id')
  updateOfficeHour(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateOfficeHourDto,
  ) {
    return this.schedules.updateOfficeHour(id, dto);
  }

  @Patch('office-hours/:id/deactivate')
  deactivateOfficeHour(@Param('id', ParseIntPipe) id: number) {
    return this.schedules.deactivateOfficeHour(id);
  }
}
