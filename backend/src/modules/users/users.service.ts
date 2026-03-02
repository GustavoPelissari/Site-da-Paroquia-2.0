import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from './user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repo: Repository<UserEntity>,
  ) {}

  findByEmail(email: string) {
    return this.repo.findOne({ where: { email } });
  }

  createUser(data: { nome: string; email: string; senhaHash: string; nivelAcesso: number }) {
    const user = this.repo.create(data);
    return this.repo.save(user);
  }

  findById(id: number) {
    return this.repo.findOne({ where: { id } });
  }

  findByIdWithRefreshToken(id: number) {
    return this.repo
      .createQueryBuilder('user')
      .addSelect('user.refreshTokenHash')
      .where('user.id = :id', { id })
      .getOne();
  }

  async updateRefreshTokenHash(userId: number, refreshTokenHash: string) {
    await this.repo.update({ id: userId }, { refreshTokenHash });
  }

  async clearRefreshTokenHash(userId: number) {
    await this.repo.update({ id: userId }, { refreshTokenHash: null });
  }
}
