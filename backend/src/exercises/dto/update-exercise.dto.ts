import { IsString, IsOptional, IsBoolean, IsIn, IsInt, Min, MaxLength, MinLength } from 'class-validator';

export class UpdateExerciseDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  muscleGroup?: string;

  @IsOptional()
  @IsString()
  @IsIn(['weighted', 'bodyweight', 'timed'])
  exerciseType?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
