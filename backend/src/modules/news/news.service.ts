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
      subtitulo: news.subtitulo,
      categoria: news.categoria,
      conteudo: news.conteudo,
      imagemUrl: news.imagemUrl,
      galeriaUrls: news.galeriaJson ?? [],
      linkExterno: news.linkExterno,
      publico: !!news.publico,
      destaque: !!news.destaque,
      avisoParoquial: !!news.avisoParoquial,
      dataPublicacao: news.dataPublicacao.toISOString(),
      agendamentoPublicacao: news.agendamentoPublicacao?.toISOString() ?? null,
      dataExpiracao: news.dataExpiracao?.toISOString() ?? null,
      groupId: news.groupId,
      autorNome: news.autorNome,
    };
  }

  async findAll(groupId?: number, q?: string, categoria?: string) {
    const now = new Date();
    const qb = this.repo
      .createQueryBuilder('news')
      .where('news.publico = :publico', { publico: 1 })
      .andWhere('(news.agendamentoPublicacao IS NULL OR news.agendamentoPublicacao <= :now)', { now })
      .andWhere('(news.dataExpiracao IS NULL OR news.dataExpiracao >= :now)', { now })
      .orderBy('news.dataPublicacao', 'DESC');

    if (groupId) {
      qb.andWhere('news.groupId = :groupId', { groupId });
    }

    if (q?.trim()) {
      const query = `%${q.trim().toLowerCase()}%`;
      qb.andWhere(
        '(LOWER(news.titulo) LIKE :query OR LOWER(news.subtitulo) LIKE :query OR LOWER(news.conteudo) LIKE :query OR LOWER(news.categoria) LIKE :query)',
        { query },
      );
    }

    if (categoria?.trim()) {
      qb.andWhere('LOWER(news.categoria) = :categoria', { categoria: categoria.trim().toLowerCase() });
    }

    const items = await qb.getMany();

    return items.map((item) => this.toResponse(item));
  }

  async findOne(id: number) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Noticia nao encontrada.');
    return this.toResponse(item);
  }

  async create(dto: CreateNewsDto, authorName?: string) {
    const isPublic = dto.publico ?? dto.groupId == null;
    const agendada = dto.agendamentoPublicacao ? new Date(dto.agendamentoPublicacao) : null;
    const expiracao = dto.dataExpiracao ? new Date(dto.dataExpiracao) : null;
    const entity = this.repo.create({
      titulo: dto.titulo,
      subtitulo: dto.subtitulo ?? null,
      categoria: dto.categoria ?? null,
      conteudo: dto.conteudo,
      imagemUrl: dto.imagemUrl ?? null,
      galeriaJson: dto.galeriaUrls ?? [],
      linkExterno: dto.linkExterno ?? null,
      publico: isPublic ? 1 : 0,
      destaque: dto.destaque ? 1 : 0,
      avisoParoquial: dto.avisoParoquial ? 1 : 0,
      groupId: dto.groupId ?? null,
      dataPublicacao: agendada ?? new Date(),
      agendamentoPublicacao: agendada,
      dataExpiracao: expiracao,
      autorNome: authorName ?? null,
    });

    const news = await this.repo.save(entity);
    return this.toResponse(news);
  }

  async update(id: number, dto: UpdateNewsDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Noticia nao encontrada.');

    if (dto.titulo !== undefined) item.titulo = dto.titulo;
    if (dto.subtitulo !== undefined) item.subtitulo = dto.subtitulo || null;
    if (dto.categoria !== undefined) item.categoria = dto.categoria || null;
    if (dto.conteudo !== undefined) item.conteudo = dto.conteudo;
    if (dto.imagemUrl !== undefined) item.imagemUrl = dto.imagemUrl || null;
    if (dto.galeriaUrls !== undefined) item.galeriaJson = dto.galeriaUrls;
    if (dto.linkExterno !== undefined) item.linkExterno = dto.linkExterno || null;
    if (dto.groupId !== undefined) item.groupId = dto.groupId ?? null;
    if (dto.publico !== undefined) item.publico = dto.publico ? 1 : 0;
    if (dto.destaque !== undefined) item.destaque = dto.destaque ? 1 : 0;
    if (dto.avisoParoquial !== undefined) item.avisoParoquial = dto.avisoParoquial ? 1 : 0;
    if (dto.agendamentoPublicacao !== undefined) {
      item.agendamentoPublicacao = dto.agendamentoPublicacao ? new Date(dto.agendamentoPublicacao) : null;
      if (item.agendamentoPublicacao != null) {
        item.dataPublicacao = item.agendamentoPublicacao;
      }
    }
    if (dto.dataExpiracao !== undefined) {
      item.dataExpiracao = dto.dataExpiracao ? new Date(dto.dataExpiracao) : null;
    }

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
