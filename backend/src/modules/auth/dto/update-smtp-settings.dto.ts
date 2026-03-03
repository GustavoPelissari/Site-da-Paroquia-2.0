import { Transform } from 'class-transformer';
import { IsBoolean, IsEmail, IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

export class UpdateSmtpSettingsDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MaxLength(190)
  host!: string;

  @IsInt()
  @Min(1)
  @Max(65535)
  port!: number;

  @IsBoolean()
  secure!: boolean;

  @Transform(({ value }) => {
    if (typeof value !== 'string') return null;
    const normalized = value.trim();
    return normalized.length === 0 ? null : normalized;
  })
  @IsOptional()
  @IsString()
  @MaxLength(190)
  username?: string | null;

  @Transform(({ value }) => {
    if (value == null) return undefined;
    if (typeof value !== 'string') return value;
    const normalized = value.trim();
    return normalized.length === 0 ? null : normalized;
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  password?: string | null;

  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsEmail()
  @MaxLength(190)
  fromEmail!: string;

  @Transform(({ value }) => {
    if (typeof value !== 'string') return null;
    const normalized = value.trim();
    return normalized.length === 0 ? null : normalized;
  })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  fromName?: string | null;

  @Transform(({ value }) => {
    if (typeof value !== 'string') return null;
    const normalized = value.trim();
    return normalized.length === 0 ? null : normalized;
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  resetBaseUrl?: string | null;
}
