import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'users' })
export class UserEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ type: 'varchar', length: 120 })
  nome!: string;

  @Index({ unique: true })
  @Column({ type: 'varchar', length: 190 })
  email!: string;

  @Column({ name: 'senha_hash', type: 'varchar', length: 255 })
  senhaHash!: string;

  @Column({ name: 'nivel_acesso', type: 'tinyint', default: 0 })
  nivelAcesso!: number;
}