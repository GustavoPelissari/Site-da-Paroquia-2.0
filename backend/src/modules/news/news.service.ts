import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NewsEntity } from './news.entity';
import { CreateNewsDto } from './dto/create-news.dto';
import { UpdateNewsDto } from './dto/update-news.dto';

@Injectable()
export class NewsService {
  constructor(
    @InjectRepository(NewsEntity)
    private readonly repo: Repository<NewsEntity>,
  ) {}

  private toResponse(news: NewsEntity) {
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

  async findAll(groupId?: number, q?: string) {
    const qb = this.repo
      .createQueryBuilder('news')
      .where('news.publico = :publico', { publico: 1 })
      .orderBy('news.dataPublicacao', 'DESC');

    if (groupId) {
      qb.andWhere('news.groupId = :groupId', { groupId });
    }

    if (q?.trim()) {
      const query = `%${q.trim().toLowerCase()}%`;
      qb.andWhere('(LOWER(news.titulo) LIKE :query OR LOWER(news.conteudo) LIKE :query)', { query });
    }

    const items = await qb.getMany();

    return items.map((item) => this.toResponse(item));
  }

  async findOne(id: number) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Noticia nao encontrada.');
    return this.toResponse(item);
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
    return this.toResponse(news);
  }

  async update(id: number, dto: UpdateNewsDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Noticia nao encontrada.');

    if (dto.titulo !== undefined) item.titulo = dto.titulo;
    if (dto.conteudo !== undefined) item.conteudo = dto.conteudo;
    if (dto.imagemUrl !== undefined) item.imagemUrl = dto.imagemUrl || null;
    if (dto.linkExterno !== undefined) item.linkExterno = dto.linkExterno || null;
    if (dto.groupId !== undefined) item.groupId = dto.groupId ?? null;
    if (dto.publico !== undefined) item.publico = dto.publico ? 1 : 0;

    const updated = await this.repo.save(item);
    return this.toResponse(updated);
  }

  async remove(id: number) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Noticia nao encontrada.');
    await this.repo.delete({ id });
    return { message: 'Noticia excluida com sucesso.' };
  }
}
