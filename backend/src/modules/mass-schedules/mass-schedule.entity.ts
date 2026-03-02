import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'mass_schedules' })
export class MassScheduleEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Index()
  @Column({ type: 'tinyint', unsigned: true })
  weekday!: number;

  @Index()
  @Column({ type: 'time' })
  time!: string;

  @Column({ name: 'location_name', type: 'varchar', length: 160 })
  locationName!: string;

  @Column({ name: 'is_active', type: 'tinyint', default: 1 })
  isActive!: number;

  @Column({ type: 'text', nullable: true })
  notes!: string | null;

  @Column({ name: 'created_at', type: 'datetime' })
  createdAt!: Date;

  @Column({ name: 'updated_at', type: 'datetime' })
  updatedAt!: Date;
}
