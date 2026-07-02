import { IsString, IsOptional, IsNumber, IsDateString, Min, Max, MaxLength } from 'class-validator';

export class UpsertDailyLogDto {
  @IsDateString()
  date: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(500)
  weightKg?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1000)
  proteinG?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(20000)
  caloriesKcal?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(20000)
  waterMl?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(24)
  sleepHours?: number;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;
}
