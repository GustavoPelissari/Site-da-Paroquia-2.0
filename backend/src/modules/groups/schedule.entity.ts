import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'schedules' })
export class ScheduleEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ name: 'group_id', type: 'bigint', unsigned: true })
  groupId!: number;

  @Column({ name: 'pdf_url', type: 'text' })
  pdfUrl!: string;

  @Column({ type: 'text', nullable: true })
  descricao!: string | null;

  @Column({ name: 'data_upload', type: 'datetime' })
  dataUpload!: Date;
}
