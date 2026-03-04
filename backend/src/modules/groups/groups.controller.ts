import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AddGroupMemberDto } from './dto/add-group-member.dto';
import { CreateFormResponseDto } from './dto/create-form-response.dto';
import { GroupsService } from './groups.service';

@Controller()
export class GroupsController {
  constructor(private readonly groups: GroupsService) {}

  @Get('groups')
  listGroups(@Query('q') q?: string, @Query('memberUserId') memberUserId?: string) {
    const parsed = memberUserId ? Number(memberUserId) : undefined;
    return this.groups.listGroups({
      q,
      memberUserId: Number.isFinite(parsed) ? parsed : undefined,
    });
  }

  @Get('groups/:id')
  findGroup(@Param('id', ParseIntPipe) id: number) {
    return this.groups.findGroup(id);
  }

  @Get('groups/:id/members')
  listMembers(@Param('id', ParseIntPipe) id: number) {
    return this.groups.listMembers(id);
  }

  @Get('groups/:id/forms')
  listForms(@Param('id', ParseIntPipe) id: number) {
    return this.groups.listForms(id);
  }

  @Get('groups/:id/schedules')
  listSchedules(@Param('id', ParseIntPipe) id: number) {
    return this.groups.listSchedules(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.COORDENADOR)
  @Post('groups/:id/members')
  addMember(@Param('id', ParseIntPipe) id: number, @Body() dto: AddGroupMemberDto) {
    return this.groups.addMember(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @MinAccessLevel(AccessLevel.COORDENADOR)
  @Delete('groups/:id/members/:userId')
  removeMember(
    @Param('id', ParseIntPipe) id: number,
    @Param('userId', ParseIntPipe) userId: number,
  ) {
    return this.groups.removeMember(id, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('forms/:id/responses')
  createFormResponse(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: { user: { id: number | string } },
    @Body() dto: CreateFormResponseDto,
  ) {
    return this.groups.createFormResponse(id, Number(req.user.id), dto);
  }
}
