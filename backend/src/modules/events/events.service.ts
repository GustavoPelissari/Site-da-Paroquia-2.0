import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EventEntity, EventType } from './event.entity';

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
      imagemUrl: event.imagemUrl,
      linkExterno: event.linkExterno,
      publico: !!event.publico,
      groupId: event.groupId,
    }));
  }
}
