import { IsArray, ValidateNested, IsString, IsInt } from 'class-validator';
import { Type } from 'class-transformer';

class ExerciseOrder {
  @IsString()
  id: string;

  @IsInt()
  sortOrder: number;
}

export class ReorderExercisesDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ExerciseOrder)
  exercises: ExerciseOrder[];
}
