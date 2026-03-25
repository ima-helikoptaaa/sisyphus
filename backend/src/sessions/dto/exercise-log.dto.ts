import { IsString, IsOptional, IsBoolean, IsInt } from 'class-validator';

export class CreateExerciseLogDto {
  @IsString()
  exercise_id: string;

  @IsInt()
  sort_order: number;
}

export class UpdateExerciseLogDto {
  @IsOptional()
  @IsBoolean()
  skipped?: boolean;

  @IsOptional()
  @IsInt()
  sort_order?: number;
}
