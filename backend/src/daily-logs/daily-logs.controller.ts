import {
  Controller,
  Get,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { DailyLogsService } from './daily-logs.service';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';
import { UpsertDailyLogDto } from './dto/upsert-daily-log.dto';

@Controller('daily-logs')
@UseGuards(AuthGuard)
export class DailyLogsController {
  constructor(private readonly dailyLogsService: DailyLogsService) {}

  @Put()
  async upsert(@CurrentUser() user: User, @Body() dto: UpsertDailyLogDto) {
    return this.dailyLogsService.upsert(user.id, dto);
  }

  @Get()
  async findAll(
    @CurrentUser() user: User,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDateParam?: string,
  ) {
    const endDate = endDateParam ? new Date(endDateParam + 'T00:00:00.000Z') : null;
    const end = endDate ? new Date(endDate.getTime() + 24 * 60 * 60 * 1000) : new Date();
    const start = startDate
      ? new Date(startDate + 'T00:00:00.000Z')
      : new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000);

    return this.dailyLogsService.findByDateRange(user.id, start, end);
  }

  @Get('today')
  async getToday(@CurrentUser() user: User) {
    return this.dailyLogsService.getToday(user.id);
  }

  @Get('latest')
  async getLatest(@CurrentUser() user: User) {
    return this.dailyLogsService.getLatest(user.id);
  }

  @Delete(':id')
  async delete(@CurrentUser() user: User, @Param('id') id: string) {
    return this.dailyLogsService.delete(user.id, id);
  }
}
