import { IsArray, ValidateNested, IsString, IsInt } from 'class-validator';
import { Type } from 'class-transformer';

class SplitOrder {
  @IsString()
  id: string;

  @IsInt()
  sortOrder: number;
}

export class ReorderSplitsDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SplitOrder)
  splits: SplitOrder[];
}
