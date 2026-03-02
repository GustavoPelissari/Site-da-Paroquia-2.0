import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RolesGuard } from '../../common/roles.guard';
import { MassScheduleEntity } from './mass-schedule.entity';
import { MassSchedulesController } from './mass-schedules.controller';
import { MassSchedulesService } from './mass-schedules.service';
import { OfficeHourEntity } from './office-hour.entity';
import { PublicMassSchedulesController } from './public-mass-schedules.controller';

@Module({
  imports: [TypeOrmModule.forFeature([MassScheduleEntity, OfficeHourEntity])],
  controllers: [PublicMassSchedulesController, MassSchedulesController],
  providers: [MassSchedulesService, RolesGuard],
  exports: [MassSchedulesService],
})
export class MassSchedulesModule {}
