import { Transform } from 'class-transformer';
import { IsArray, IsBoolean, IsDateString, IsInt, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateNewsDto {
  @IsString()
  @MinLength(3)
  @MaxLength(180)
  @Transform(({ value }) => String(value ?? '').trim())
  titulo!: string;

  @IsOptional()
  @IsString()
  @MaxLength(220)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  subtitulo?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  categoria?: string;

  @IsString()
  @MinLength(3)
  @MaxLength(30000)
  @Transform(({ value }) => String(value ?? '').trim())
  conteudo!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2048)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  imagemUrl?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  galeriaUrls?: string[];

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

  @IsOptional()
  @IsBoolean()
  destaque?: boolean;

  @IsOptional()
  @IsBoolean()
  avisoParoquial?: boolean;

  @IsOptional()
  @IsDateString()
  agendamentoPublicacao?: string;

  @IsOptional()
  @IsDateString()
  dataExpiracao?: string;
}
