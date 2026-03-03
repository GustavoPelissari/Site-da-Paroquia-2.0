import { Transform } from 'class-transformer';
import { IsEmail, IsInt, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';

export class CreateUserByAdminDto {
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  @Transform(({ value }) => String(value ?? '').trim())
  nome!: string;

  @IsEmail()
  @Transform(({ value }) => String(value ?? '').trim().toLowerCase())
  email!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  @Transform(({ value }) => String(value ?? ''))
  senha!: string;

  @IsInt()
  @Min(0)
  @Max(3)
  nivelAcesso!: number;
}
