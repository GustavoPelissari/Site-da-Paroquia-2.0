import { Module } from '@nestjs/common';
import { MassesController } from './masses.controller';
import { ParishController } from './parish.controller';
import { ParishService } from './parish.service';

@Module({
  controllers: [ParishController, MassesController],
  providers: [ParishService],
  exports: [ParishService],
})
export class ParishModule {}
