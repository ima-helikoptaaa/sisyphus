import { IsString, IsOptional, IsBoolean, IsInt, Min } from 'class-validator';

export class CreateExerciseLogDto {
  @IsString()
  exerciseId: string;

  @IsInt()
  @Min(0)
  sortOrder: number;
}

export class UpdateExerciseLogDto {
  @IsOptional()
  @IsBoolean()
  skipped?: boolean;

  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;
}
