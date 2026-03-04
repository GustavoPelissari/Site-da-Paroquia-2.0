import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'group_members' })
export class GroupMemberEntity {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id!: number;

  @Column({ name: 'group_id', type: 'bigint', unsigned: true })
  groupId!: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId!: number;

  @Column({ name: 'created_at', type: 'datetime' })
  createdAt!: Date;
}
