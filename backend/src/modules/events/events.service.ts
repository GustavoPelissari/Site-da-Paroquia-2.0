import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EventEntity, EventType } from './event.entity';
import { CreateEventDto } from './dto/create-event.dto';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(EventEntity)
    private readonly repo: Repository<EventEntity>,
  ) {}

  async findAll(tipo?: EventType) {
    const qb = this.repo
      .createQueryBuilder('event')
      .where('event.publico = :publico', { publico: 1 })
      .orderBy('event.dataHora', 'ASC');

    if (tipo) {
      qb.andWhere('event.tipo = :tipo', { tipo });
    }

    const items = await qb.getMany();

    return items.map((event) => ({
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
    }));
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
}
