import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'password_reset_tokens' })
export class PasswordResetTokenEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId!: number;

  @Index({ unique: true })
  @Column({ name: 'token_hash', type: 'varchar', length: 64 })
  tokenHash!: string;

  @Column({ name: 'expires_at', type: 'datetime' })
  expiresAt!: Date;

  @Column({ name: 'used_at', type: 'datetime', nullable: true })
  usedAt!: Date | null;

  @Column({ name: 'request_ip', type: 'varchar', length: 64, nullable: true })
  requestIp!: string | null;

  @Column({ name: 'request_user_agent', type: 'varchar', length: 255, nullable: true })
  requestUserAgent!: string | null;

  @Column({ name: 'created_at', type: 'datetime' })
  createdAt!: Date;
}
