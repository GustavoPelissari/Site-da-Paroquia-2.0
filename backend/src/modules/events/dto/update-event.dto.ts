import { Transform } from 'class-transformer';
import { IsBoolean, IsDateString, IsEnum, IsInt, IsOptional, IsString, MaxLength, Min, MinLength } from 'class-validator';
import { EventType } from '../event.entity';

export class UpdateEventDto {
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(160)
  @Transform(({ value }) => String(value ?? '').trim())
  nome?: string;

  @IsOptional()
  @IsDateString()
  dataHora?: string;

  @IsOptional()
  @IsDateString()
  dataFinal?: string;

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(160)
  @Transform(({ value }) => String(value ?? '').trim())
  local?: string;

  @IsOptional()
  @IsEnum(EventType)
  tipo?: EventType;

  @IsOptional()
  @IsString()
  @MaxLength(12000)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  descricao?: string;

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
  @IsString()
  @MaxLength(2048)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  linkInscricao?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  limiteParticipantes?: number;

  @IsOptional()
  @IsBoolean()
  publico?: boolean;

  @IsOptional()
  @IsInt()
  groupId?: number;
}
