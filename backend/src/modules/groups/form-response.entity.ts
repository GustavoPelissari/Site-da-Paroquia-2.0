import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'form_responses' })
export class FormResponseEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ name: 'form_id', type: 'bigint', unsigned: true })
  formId!: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: true })
  userId!: number | null;

  @Column({ name: 'respostas_json', type: 'json' })
  respostasJson!: unknown;

  @Column({ name: 'created_at', type: 'datetime' })
  createdAt!: Date;
}
