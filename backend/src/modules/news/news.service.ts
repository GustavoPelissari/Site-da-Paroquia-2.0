import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NewsEntity } from './news.entity';

@Injectable()
export class NewsService {
  constructor(
    @InjectRepository(NewsEntity)
    private readonly repo: Repository<NewsEntity>,
  ) {}

  async findAll(groupId?: number) {
    const qb = this.repo
      .createQueryBuilder('news')
      .where('news.publico = :publico', { publico: 1 })
      .orderBy('news.dataPublicacao', 'DESC');

    if (groupId) {
      qb.andWhere('news.groupId = :groupId', { groupId });
    }

    const items = await qb.getMany();

    return items.map((news) => ({
      id: news.id,
      titulo: news.titulo,
      conteudo: news.conteudo,
      imagemUrl: news.imagemUrl,
      linkExterno: news.linkExterno,
      publico: !!news.publico,
      dataPublicacao: news.dataPublicacao.toISOString(),
      groupId: news.groupId,
    }));
  }
}
