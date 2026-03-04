import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../users/user.entity';
import { FormEntity } from './form.entity';
import { FormResponseEntity } from './form-response.entity';
import { GroupEntity } from './group.entity';
import { GroupMemberEntity } from './group-member.entity';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';
import { ScheduleEntity } from './schedule.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      GroupEntity,
      GroupMemberEntity,
      FormEntity,
      FormResponseEntity,
      ScheduleEntity,
      UserEntity,
    ]),
  ],
  controllers: [GroupsController],
  providers: [GroupsService],
  exports: [GroupsService],
})
export class GroupsModule {}
