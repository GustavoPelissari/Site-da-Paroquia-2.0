import { IsInt, Max, Min } from 'class-validator';

export class UpdateAccessLevelDto {
  @IsInt()
  @Min(0)
  @Max(3)
  nivelAcesso!: number;
}
