import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'office_hours' })
export class OfficeHourEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Index()
  @Column({ type: 'tinyint', unsigned: true })
  weekday!: number;

  @Column({ name: 'open_time', type: 'time' })
  openTime!: string;

  @Column({ name: 'close_time', type: 'time', nullable: true })
  closeTime!: string | null;

  @Column({ type: 'varchar', length: 120, default: 'Secretaria' })
  label!: string;

  @Column({ name: 'is_active', type: 'tinyint', default: 1 })
  isActive!: number;

  @Column({ type: 'text', nullable: true })
  notes!: string | null;

  @Column({ name: 'created_at', type: 'datetime' })
  createdAt!: Date;

  @Column({ name: 'updated_at', type: 'datetime' })
  updatedAt!: Date;
}
