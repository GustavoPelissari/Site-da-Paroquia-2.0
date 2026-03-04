import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '../users/user.entity';
import { AddGroupMemberDto } from './dto/add-group-member.dto';
import { CreateFormResponseDto } from './dto/create-form-response.dto';
import { FormEntity } from './form.entity';
import { FormResponseEntity } from './form-response.entity';
import { GroupEntity } from './group.entity';
import { GroupMemberEntity } from './group-member.entity';
import { ScheduleEntity } from './schedule.entity';

@Injectable()
export class GroupsService {
  constructor(
    @InjectRepository(GroupEntity)
    private readonly groups: Repository<GroupEntity>,
    @InjectRepository(GroupMemberEntity)
    private readonly members: Repository<GroupMemberEntity>,
    @InjectRepository(FormEntity)
    private readonly forms: Repository<FormEntity>,
    @InjectRepository(FormResponseEntity)
    private readonly formResponses: Repository<FormResponseEntity>,
    @InjectRepository(ScheduleEntity)
    private readonly schedules: Repository<ScheduleEntity>,
    @InjectRepository(UserEntity)
    private readonly users: Repository<UserEntity>,
  ) {}

  async listGroups(params: { q?: string; memberUserId?: number }) {
    const qb = this.groups.createQueryBuilder('g').orderBy('g.nome', 'ASC');
    if (params.q?.trim()) {
      const query = `%${params.q.trim().toLowerCase()}%`;
      qb.where('(LOWER(g.nome) LIKE :query OR LOWER(g.descricao) LIKE :query)', { query });
    }
    if (params.memberUserId) {
      qb.innerJoin(GroupMemberEntity, 'gm', 'gm.groupId = g.id AND gm.userId = :memberUserId', {
        memberUserId: params.memberUserId,
      });
    }
    const rows = await qb.getMany();
    return rows.map((item) => ({
      id: item.id,
      nome: item.nome,
      descricao: item.descricao ?? '',
      coordenadorUserId: item.coordenadorId,
      permitePdfUpload: !!item.permitePdfUpload,
      permiteFormularios: !!item.permiteFormularios,
      permiteNoticias: !!item.permiteNoticias,
      permiteEventos: !!item.permiteEventos,
    }));
  }

  async findGroup(id: number) {
    const item = await this.groups.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Grupo nao encontrado.');
    return {
      id: item.id,
      nome: item.nome,
      descricao: item.descricao ?? '',
      coordenadorUserId: item.coordenadorId,
      permitePdfUpload: !!item.permitePdfUpload,
      permiteFormularios: !!item.permiteFormularios,
      permiteNoticias: !!item.permiteNoticias,
      permiteEventos: !!item.permiteEventos,
    };
  }

  async listMembers(groupId: number) {
    const group = await this.groups.findOne({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Grupo nao encontrado.');

    const rows = await this.members
      .createQueryBuilder('gm')
      .innerJoin(UserEntity, 'u', 'u.id = gm.userId')
      .where('gm.groupId = :groupId', { groupId })
      .select(['u.id as id', 'u.nome as nome', 'u.email as email', 'u.nivelAcesso as nivelAcesso'])
      .orderBy('u.nome', 'ASC')
      .getRawMany<{ id: number; nome: string; email: string; nivelAcesso: number }>();

    return rows.map((row) => ({
      id: row.id,
      nome: row.nome,
      email: row.email,
      nivelAcesso: row.nivelAcesso,
    }));
  }

  async listForms(groupId: number) {
    const group = await this.groups.findOne({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Grupo nao encontrado.');
    const rows = await this.forms.find({
      where: { groupId },
      order: { id: 'DESC' },
    });
    return rows.map((item) => ({
      id: item.id,
      titulo: item.titulo,
      groupId: item.groupId,
      publico: item.visibilidade === 'PUBLICO',
      ativo: !!item.ativo,
    }));
  }

  async listSchedules(groupId: number) {
    const group = await this.groups.findOne({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Grupo nao encontrado.');
    const rows = await this.schedules.find({
      where: { groupId },
      order: { dataUpload: 'DESC' },
    });
    return rows.map((item) => ({
      id: item.id,
      groupId: item.groupId,
      pdfLabel: item.descricao?.trim() || `Escala ${item.id}`,
      pdfUrl: item.pdfUrl,
      descricao: item.descricao,
      dataUpload: item.dataUpload.toISOString(),
    }));
  }

  async addMember(groupId: number, dto: AddGroupMemberDto) {
    const group = await this.groups.findOne({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Grupo nao encontrado.');
    const user = await this.users.findOne({ where: { id: dto.userId } });
    if (!user) throw new NotFoundException('Usuario nao encontrado.');

    const exists = await this.members.findOne({ where: { groupId, userId: dto.userId } });
    if (!exists) {
      await this.members.save(this.members.create({ groupId, userId: dto.userId }));
    }
    return { message: 'Membro adicionado com sucesso.' };
  }

  async removeMember(groupId: number, userId: number) {
    const group = await this.groups.findOne({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Grupo nao encontrado.');
    await this.members.delete({ groupId, userId });
    return { message: 'Membro removido com sucesso.' };
  }

  async createFormResponse(formId: number, userId: number, dto: CreateFormResponseDto) {
    const form = await this.forms.findOne({ where: { id: formId } });
    if (!form) throw new NotFoundException('Formulario nao encontrado.');
    const created = await this.formResponses.save(
      this.formResponses.create({
        formId,
        userId,
        respostasJson: { resposta: dto.resposta },
      }),
    );
    return {
      id: created.id,
      formId: created.formId,
      userId: created.userId,
      resposta: dto.resposta,
      createdAt: created.createdAt.toISOString(),
    };
  }
}
