import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'news' })
export class NewsEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ type: 'varchar', length: 180 })
  titulo!: string;

  @Column({ type: 'longtext' })
  conteudo!: string;

  @Column({ name: 'imagem_url', type: 'text', nullable: true })
  imagemUrl!: string | null;

  @Column({ name: 'link_externo', type: 'text', nullable: true })
  linkExterno!: string | null;

  @Column({ type: 'tinyint', default: 1 })
  publico!: number;

  @Index()
  @Column({ name: 'data_publicacao', type: 'datetime' })
  dataPublicacao!: Date;

  @Index()
  @Column({ name: 'group_id', type: 'bigint', unsigned: true, nullable: true })
  groupId!: number | null;
}
