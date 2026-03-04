import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EventEntity, EventType } from './event.entity';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(EventEntity)
    private readonly repo: Repository<EventEntity>,
  ) {}

  private toResponse(event: EventEntity) {
    return {
      id: event.id,
      nome: event.nome,
      dataHora: event.dataHora.toISOString(),
      local: event.local,
      tipo: event.tipo,
      descricao: event.descricao,
      imagemUrl: event.imagemUrl,
      linkExterno: event.linkExterno,
      publico: !!event.publico,
      groupId: event.groupId,
    };
  }

  async findAll(tipo?: EventType, q?: string) {
    const qb = this.repo
      .createQueryBuilder('event')
      .where('event.publico = :publico', { publico: 1 })
      .orderBy('event.dataHora', 'ASC');

    if (tipo) {
      qb.andWhere('event.tipo = :tipo', { tipo });
    }

    if (q?.trim()) {
      const query = `%${q.trim().toLowerCase()}%`;
      qb.andWhere(
        '(LOWER(event.nome) LIKE :query OR LOWER(event.local) LIKE :query OR LOWER(event.descricao) LIKE :query)',
        { query },
      );
    }

    const items = await qb.getMany();
    return items.map((item) => this.toResponse(item));
  }

  async findOne(id: number) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Evento nao encontrado.');
    return this.toResponse(item);
  }

  async create(dto: CreateEventDto) {
    const isPublic = dto.publico ?? dto.groupId == null;
    const entity = this.repo.create({
      nome: dto.nome,
      dataHora: new Date(dto.dataHora),
      local: dto.local,
      tipo: dto.tipo,
      descricao: dto.descricao ?? null,
      imagemUrl: dto.imagemUrl ?? null,
      linkExterno: dto.linkExterno ?? null,
      publico: isPublic ? 1 : 0,
      groupId: dto.groupId ?? null,
    });

    const event = await this.repo.save(entity);
    return this.toResponse(event);
  }

  async update(id: number, dto: UpdateEventDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Evento nao encontrado.');

    if (dto.nome !== undefined) item.nome = dto.nome;
    if (dto.dataHora !== undefined) item.dataHora = new Date(dto.dataHora);
    if (dto.local !== undefined) item.local = dto.local;
    if (dto.tipo !== undefined) item.tipo = dto.tipo;
    if (dto.descricao !== undefined) item.descricao = dto.descricao || null;
    if (dto.imagemUrl !== undefined) item.imagemUrl = dto.imagemUrl || null;
    if (dto.linkExterno !== undefined) item.linkExterno = dto.linkExterno || null;
    if (dto.groupId !== undefined) item.groupId = dto.groupId ?? null;
    if (dto.publico !== undefined) item.publico = dto.publico ? 1 : 0;

    const updated = await this.repo.save(item);
    return this.toResponse(updated);
  }

  async remove(id: number) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Evento nao encontrado.');
    await this.repo.delete({ id });
    return { message: 'Evento excluido com sucesso.' };
  }
}
