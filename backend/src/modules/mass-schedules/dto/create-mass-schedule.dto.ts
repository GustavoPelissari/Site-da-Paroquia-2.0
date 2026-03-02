import { Transform } from 'class-transformer';
import { IsInt, IsOptional, IsString, Matches, Max, MaxLength, Min, MinLength } from 'class-validator';

export class CreateMassScheduleDto {
  @IsInt()
  @Min(0)
  @Max(6)
  weekday!: number;

  @IsString()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
  time!: string;

  @IsString()
  @MinLength(2)
  @MaxLength(160)
  @Transform(({ value }) => String(value ?? '').trim())
  locationName!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(1)
  isActive?: number;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  @Transform(({ value }) => (value ? String(value).trim() : undefined))
  notes?: string;
}
