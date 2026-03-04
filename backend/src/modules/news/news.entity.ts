import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'news' })
export class NewsEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ type: 'varchar', length: 180 })
  titulo!: string;

  @Column({ type: 'varchar', length: 220, nullable: true })
  subtitulo!: string | null;

  @Index()
  @Column({ type: 'varchar', length: 80, nullable: true })
  categoria!: string | null;

  @Column({ type: 'longtext' })
  conteudo!: string;

  @Column({ name: 'imagem_url', type: 'text', nullable: true })
  imagemUrl!: string | null;

  @Column({ name: 'galeria_json', type: 'json', nullable: true })
  galeriaJson!: string[] | null;

  @Column({ name: 'link_externo', type: 'text', nullable: true })
  linkExterno!: string | null;

  @Column({ type: 'tinyint', default: 1 })
  publico!: number;

  @Column({ name: 'destaque', type: 'tinyint', default: 0 })
  destaque!: number;

  @Column({ name: 'aviso_paroquial', type: 'tinyint', default: 0 })
  avisoParoquial!: number;

  @Index()
  @Column({ name: 'data_publicacao', type: 'datetime' })
  dataPublicacao!: Date;

  @Index()
  @Column({ name: 'agendamento_publicacao', type: 'datetime', nullable: true })
  agendamentoPublicacao!: Date | null;

  @Index()
  @Column({ name: 'data_expiracao', type: 'datetime', nullable: true })
  dataExpiracao!: Date | null;

  @Index()
  @Column({ name: 'group_id', type: 'bigint', unsigned: true, nullable: true })
  groupId!: number | null;

  @Column({ name: 'autor_nome', type: 'varchar', length: 120, nullable: true })
  autorNome!: string | null;
}
