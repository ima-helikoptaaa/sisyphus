import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';

export class UpsertDailyLogDto {
  @IsString()
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
  notes?: string;
}
