import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'smtp_settings' })
export class SmtpSettingsEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ name: 'host', type: 'varchar', length: 190 })
  host!: string;

  @Column({ name: 'port', type: 'int', unsigned: true, default: 587 })
  port!: number;

  @Column({ name: 'secure', type: 'tinyint', default: 0 })
  secure!: boolean;

  @Column({ name: 'username', type: 'varchar', length: 190, nullable: true })
  username!: string | null;

  @Column({ name: 'password', type: 'varchar', length: 255, nullable: true })
  password!: string | null;

  @Column({ name: 'from_email', type: 'varchar', length: 190 })
  fromEmail!: string;

  @Column({ name: 'from_name', type: 'varchar', length: 120, nullable: true })
  fromName!: string | null;

  @Column({ name: 'reset_base_url', type: 'varchar', length: 255, nullable: true })
  resetBaseUrl!: string | null;

  @Column({ name: 'created_at', type: 'datetime' })
  createdAt!: Date;

  @Column({ name: 'updated_at', type: 'datetime' })
  updatedAt!: Date;
}

