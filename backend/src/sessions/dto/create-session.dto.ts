import { IsString, IsOptional, IsDateString, MaxLength } from 'class-validator';

export class CreateSessionDto {
  @IsString()
  splitId: string;

  @IsOptional()
  @IsDateString()
  date?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}
