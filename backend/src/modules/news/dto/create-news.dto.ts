import { Transform } from 'class-transformer';
import { IsBoolean, IsInt, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateNewsDto {
  @IsString()
  @MinLength(3)
  @MaxLength(180)
  @Transform(({ value }) => String(value ?? '').trim())
  titulo!: string;

  @IsString()
  @MinLength(3)
  @MaxLength(10000)
  @Transform(({ value }) => String(value ?? '').trim())
  conteudo!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2048)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  imagemUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2048)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  linkExterno?: string;

  @IsOptional()
  @IsInt()
  groupId?: number;

  @IsOptional()
  @IsBoolean()
  publico?: boolean;
}
