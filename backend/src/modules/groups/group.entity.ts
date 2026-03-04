import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'groups' })
export class GroupEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ type: 'varchar', length: 120 })
  nome!: string;

  @Column({ type: 'text', nullable: true })
  descricao!: string | null;

  @Column({ name: 'coordenador_id', type: 'bigint', unsigned: true, nullable: true })
  coordenadorId!: number | null;

  @Column({ name: 'permite_pdf_upload', type: 'tinyint', default: 1 })
  permitePdfUpload!: number;

  @Column({ name: 'permite_formularios', type: 'tinyint', default: 1 })
  permiteFormularios!: number;

  @Column({ name: 'permite_noticias', type: 'tinyint', default: 1 })
  permiteNoticias!: number;

  @Column({ name: 'permite_eventos', type: 'tinyint', default: 1 })
  permiteEventos!: number;
}
