import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateMassScheduleDto } from './dto/create-mass-schedule.dto';
import { CreateOfficeHourDto } from './dto/create-office-hour.dto';
import { UpdateMassScheduleDto } from './dto/update-mass-schedule.dto';
import { UpdateOfficeHourDto } from './dto/update-office-hour.dto';
import { MassScheduleEntity } from './mass-schedule.entity';
import { OfficeHourEntity } from './office-hour.entity';

@Injectable()
export class MassSchedulesService {
  constructor(
    @InjectRepository(MassScheduleEntity)
    private readonly massRepo: Repository<MassScheduleEntity>,
    @InjectRepository(OfficeHourEntity)
    private readonly officeRepo: Repository<OfficeHourEntity>,
  ) {}

  async findActiveMassSchedules() {
    const items = await this.massRepo.find({
      where: { isActive: 1 },
      order: { weekday: 'ASC', time: 'ASC' },
    });
    return items.map((item) => this.toMassResponse(item));
  }

  async findActiveOfficeHours() {
    const items = await this.officeRepo.find({
      where: { isActive: 1 },
      order: { weekday: 'ASC', openTime: 'ASC' },
    });
    return items.map((item) => this.toOfficeResponse(item));
  }

  async findNextMass(now = new Date()) {
    const active = await this.massRepo.find({
      where: { isActive: 1 },
      order: { weekday: 'ASC', time: 'ASC' },
    });

    if (!active.length) {
      return {
        serverNow: now.toISOString(),
        nextMass: null,
      };
    }

    const next = active
      .map((mass) => ({
        mass,
        startsAt: this.resolveNextDate(mass.weekday, mass.time, now),
      }))
      .sort((a, b) => a.startsAt.getTime() - b.startsAt.getTime())[0];

    return {
      serverNow: now.toISOString(),
      nextMass: {
        id: next.mass.id,
        weekday: next.mass.weekday,
        weekdayLabel: this.weekdayLabel(next.mass.weekday),
        time: next.mass.time.slice(0, 5),
        locationName: next.mass.locationName,
        notes: next.mass.notes,
        startsAt: next.startsAt.toISOString(),
      },
    };
  }

  async createMassSchedule(dto: CreateMassScheduleDto) {
    const entity = this.massRepo.create({
      weekday: dto.weekday,
      time: `${dto.time}:00`,
      locationName: dto.locationName,
      isActive: dto.isActive ?? 1,
      notes: dto.notes ?? null,
    });
    return this.toMassResponse(await this.massRepo.save(entity));
  }

  async updateMassSchedule(id: number, dto: UpdateMassScheduleDto) {
    const found = await this.massRepo.findOne({ where: { id } });
    if (!found) throw new NotFoundException('Horário de missa não encontrado');

    await this.massRepo.update(
      { id },
      {
        weekday: dto.weekday ?? found.weekday,
        time: dto.time ? `${dto.time}:00` : found.time,
        locationName: dto.locationName ?? found.locationName,
        isActive: dto.isActive ?? found.isActive,
        notes: dto.notes ?? found.notes,
      },
    );
    const updated = await this.massRepo.findOne({ where: { id } });
    if (!updated) throw new NotFoundException('Horário de missa não encontrado');
    return this.toMassResponse(updated);
  }

  async deactivateMassSchedule(id: number) {
    const found = await this.massRepo.findOne({ where: { id } });
    if (!found) throw new NotFoundException('Horário de missa não encontrado');
    await this.massRepo.update({ id }, { isActive: 0 });
    return { success: true };
  }

  async createOfficeHour(dto: CreateOfficeHourDto) {
    const entity = this.officeRepo.create({
      weekday: dto.weekday,
      openTime: `${dto.openTime}:00`,
      closeTime: dto.closeTime ? `${dto.closeTime}:00` : null,
      label: dto.label ?? 'Secretaria',
      isActive: dto.isActive ?? 1,
      notes: dto.notes ?? null,
    });
    return this.toOfficeResponse(await this.officeRepo.save(entity));
  }

  async updateOfficeHour(id: number, dto: UpdateOfficeHourDto) {
    const found = await this.officeRepo.findOne({ where: { id } });
    if (!found) throw new NotFoundException('Horário da secretaria não encontrado');

    await this.officeRepo.update(
      { id },
      {
        weekday: dto.weekday ?? found.weekday,
        openTime: dto.openTime ? `${dto.openTime}:00` : found.openTime,
        closeTime:
          dto.closeTime === undefined
            ? found.closeTime
            : dto.closeTime === ''
              ? null
              : `${dto.closeTime}:00`,
        label: dto.label ?? found.label,
        isActive: dto.isActive ?? found.isActive,
        notes: dto.notes ?? found.notes,
      },
    );
    const updated = await this.officeRepo.findOne({ where: { id } });
    if (!updated) throw new NotFoundException('Horário da secretaria não encontrado');
    return this.toOfficeResponse(updated);
  }

  async deactivateOfficeHour(id: number) {
    const found = await this.officeRepo.findOne({ where: { id } });
    if (!found) throw new NotFoundException('Horário da secretaria não encontrado');
    await this.officeRepo.update({ id }, { isActive: 0 });
    return { success: true };
  }

  private resolveNextDate(targetDay: number, time: string, now: Date) {
    const [hh, mm] = time.slice(0, 5).split(':').map(Number);
    const candidate = new Date(now);
    const diff = (targetDay - now.getDay() + 7) % 7;
    candidate.setDate(now.getDate() + diff);
    candidate.setHours(hh, mm, 0, 0);
    if (candidate.getTime() <= now.getTime()) {
      candidate.setDate(candidate.getDate() + 7);
    }
    return candidate;
  }

  private weekdayLabel(weekday: number) {
    const labels = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    return labels[weekday] ?? 'Dia';
  }

  private toMassResponse(item: MassScheduleEntity) {
    return {
      id: item.id,
      weekday: item.weekday,
      weekdayLabel: this.weekdayLabel(item.weekday),
      time: item.time.slice(0, 5),
      locationName: item.locationName,
      isActive: !!item.isActive,
      notes: item.notes,
    };
  }

  private toOfficeResponse(item: OfficeHourEntity) {
    return {
      id: item.id,
      weekday: item.weekday,
      weekdayLabel: this.weekdayLabel(item.weekday),
      openTime: item.openTime.slice(0, 5),
      closeTime: item.closeTime ? item.closeTime.slice(0, 5) : null,
      label: item.label,
      isActive: !!item.isActive,
      notes: item.notes,
    };
  }
}
