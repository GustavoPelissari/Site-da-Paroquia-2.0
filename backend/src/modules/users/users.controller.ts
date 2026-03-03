import {
  BadRequestException,
  Body,
  ConflictException,
  Controller,
  Delete,
  Get,
  NotFoundException,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';

import { AccessLevel } from '../../common/access-level';
import { MinAccessLevel } from '../../common/roles.decorator';
import { RolesGuard } from '../../common/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateUserByAdminDto } from './dto/create-user-by-admin.dto';
import { UpdateAccessLevelDto } from './dto/update-access-level.dto';
import { UsersService } from './users.service';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
@MinAccessLevel(AccessLevel.ADMINISTRATIVO)
export class UsersController {
  private static readonly selfAccessAllowedEmails = ['usuario.teste@paroquia.local'];

  constructor(private readonly users: UsersService) {}

  @Get()
  async list() {
    const users = await this.users.listUsers();
    return users.map((user) => ({
      id: user.id,
      nome: user.nome,
      email: user.email,
      nivelAcesso: user.nivelAcesso,
    }));
  }

  @Post()
  async create(@Body() dto: CreateUserByAdminDto) {
    const existing = await this.users.findByEmail(dto.email);
    if (existing) {
      throw new ConflictException('Email ja cadastrado.');
    }

    const senhaHash = await bcrypt.hash(dto.senha, 10);
    const created = await this.users.createUser({
      nome: dto.nome,
      email: dto.email,
      senhaHash,
      nivelAcesso: dto.nivelAcesso,
    });

    return {
      id: created.id,
      nome: created.nome,
      email: created.email,
      nivelAcesso: created.nivelAcesso,
    };
  }

  @Patch(':id/access-level')
  async updateAccessLevel(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAccessLevelDto,
    @Req() req: { user: { id: number | string; email?: string } },
  ) {
    const requesterId = Number(req.user.id);
    const requesterEmail = req.user.email?.trim().toLowerCase();
    const canSelfChange =
      requesterEmail != null &&
      UsersController.selfAccessAllowedEmails.includes(requesterEmail);

    if (requesterId === id && !canSelfChange) {
      throw new BadRequestException('Nao e permitido alterar o proprio nivel de acesso.');
    }

    const updated = await this.users.updateAccessLevel(id, dto.nivelAcesso);
    if (!updated) {
      throw new NotFoundException('Usuario nao encontrado.');
    }

    return {
      id: updated.id,
      nome: updated.nome,
      email: updated.email,
      nivelAcesso: updated.nivelAcesso,
    };
  }

  @Delete(':id')
  async delete(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: { user: { id: number | string } },
  ) {
    const requesterId = Number(req.user.id);
    if (requesterId === id) {
      throw new BadRequestException('Nao e permitido excluir o proprio usuario.');
    }

    const deleted = await this.users.deleteUser(id);
    if (!deleted) {
      throw new NotFoundException('Usuario nao encontrado.');
    }

    return { message: 'Usuario excluido com sucesso.' };
  }
}
