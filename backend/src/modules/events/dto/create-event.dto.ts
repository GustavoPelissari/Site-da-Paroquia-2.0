import { Transform } from 'class-transformer';
import { IsBoolean, IsDateString, IsEnum, IsInt, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { EventType } from '../event.entity';

export class CreateEventDto {
  @IsString()
  @MinLength(3)
  @MaxLength(160)
  @Transform(({ value }) => String(value ?? '').trim())
  nome!: string;

  @IsDateString()
  dataHora!: string;

  @IsString()
  @MinLength(2)
  @MaxLength(160)
  @Transform(({ value }) => String(value ?? '').trim())
  local!: string;

  @IsEnum(EventType)
  tipo!: EventType;

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
  @IsBoolean()
  publico?: boolean;

  @IsOptional()
  @IsInt()
  groupId?: number;
}
