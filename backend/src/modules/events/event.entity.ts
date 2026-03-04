import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

export enum EventType {
  MISSA = 'MISSA',
  REUNIAO = 'REUNIAO',
  FESTA = 'FESTA',
  RETIRO = 'RETIRO',
}

@Entity({ name: 'events' })
export class EventEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ type: 'varchar', length: 160 })
  nome!: string;

  @Index()
  @Column({ name: 'data_hora', type: 'datetime' })
  dataHora!: Date;

  @Column({ type: 'varchar', length: 160 })
  local!: string;

  @Index()
  @Column({ type: 'enum', enum: EventType })
  tipo!: EventType;

  @Column({ type: 'longtext', nullable: true })
  descricao!: string | null;

  @Index()
  @Column({ name: 'data_final', type: 'datetime', nullable: true })
  dataFinal!: Date | null;

  @Column({ name: 'imagem_url', type: 'text', nullable: true })
  imagemUrl!: string | null;

  @Column({ name: 'link_externo', type: 'text', nullable: true })
  linkExterno!: string | null;

  @Column({ name: 'link_inscricao', type: 'text', nullable: true })
  linkInscricao!: string | null;

  @Column({ name: 'limite_participantes', type: 'int', nullable: true })
  limiteParticipantes!: number | null;

  @Column({ type: 'tinyint', default: 1 })
  publico!: number;

  @Column({ name: 'group_id', type: 'bigint', unsigned: true, nullable: true })
  groupId!: number | null;
}
