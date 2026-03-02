import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NewsEntity } from './news.entity';
import { CreateNewsDto } from './dto/create-news.dto';

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

  async create(dto: CreateNewsDto) {
    const isPublic = dto.publico ?? dto.groupId == null;
    const entity = this.repo.create({
      titulo: dto.titulo,
      conteudo: dto.conteudo,
      imagemUrl: dto.imagemUrl ?? null,
      linkExterno: dto.linkExterno ?? null,
      publico: isPublic ? 1 : 0,
      groupId: dto.groupId ?? null,
      dataPublicacao: new Date(),
    });

    const news = await this.repo.save(entity);
    return {
      id: news.id,
      titulo: news.titulo,
      conteudo: news.conteudo,
      imagemUrl: news.imagemUrl,
      linkExterno: news.linkExterno,
      publico: !!news.publico,
      dataPublicacao: news.dataPublicacao.toISOString(),
      groupId: news.groupId,
    };
  }
}
