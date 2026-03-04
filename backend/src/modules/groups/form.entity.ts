import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'forms' })
export class FormEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ type: 'varchar', length: 180 })
  titulo!: string;

  @Column({ name: 'config_json', type: 'json' })
  configJson!: unknown;

  @Column({ type: 'enum', enum: ['PUBLICO', 'GRUPO', 'ADMIN'], default: 'PUBLICO' })
  visibilidade!: 'PUBLICO' | 'GRUPO' | 'ADMIN';

  @Column({ name: 'consentimento_lgpd', type: 'tinyint', default: 0 })
  consentimentoLgpd!: number;

  @Column({ type: 'tinyint', default: 1 })
  ativo!: number;

  @Column({ name: 'group_id', type: 'bigint', unsigned: true, nullable: true })
  groupId!: number | null;
}
