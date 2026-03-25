import {
  IsInt,
  IsOptional,
  IsNumber,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';

export class LogSetDto {
  @IsInt()
  @Min(1)
  setNumber: number;

  @IsOptional()
  @IsNumber()
  weight?: number;

  @IsOptional()
  @IsInt()
  reps?: number;

  @IsOptional()
  @IsInt()
  durationSecs?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(10)
  rpe?: number;

  @IsOptional()
  @IsBoolean()
  isWarmup?: boolean;

  @IsOptional()
  @IsBoolean()
  isDropset?: boolean;

  @IsOptional()
  @IsNumber()
  bodyWeightModifier?: number;
}

export class UpdateSetDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  setNumber?: number;

  @IsOptional()
  @IsNumber()
  weight?: number;

  @IsOptional()
  @IsInt()
  reps?: number;

  @IsOptional()
  @IsInt()
  durationSecs?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(10)
  rpe?: number;

  @IsOptional()
  @IsBoolean()
  isWarmup?: boolean;

  @IsOptional()
  @IsBoolean()
  isDropset?: boolean;

  @IsOptional()
  @IsNumber()
  bodyWeightModifier?: number;
}
