import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';

@Controller('analytics')
@UseGuards(AuthGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('summary')
  async getSummary(@CurrentUser() user: User) {
    return this.analyticsService.getSummary(user.id);
  }

  @Get('exercises/:exerciseId/progress')
  async getExerciseProgress(
    @CurrentUser() user: User,
    @Param('exerciseId') exerciseId: string,
    @Query('days') days?: string,
  ) {
    const daysNum = days ? parseInt(days, 10) : undefined;
    if (daysNum !== undefined && (isNaN(daysNum) || daysNum < 1 || daysNum > 365)) {
      return this.analyticsService.getExerciseProgress(user.id, exerciseId, undefined);
    }
    return this.analyticsService.getExerciseProgress(user.id, exerciseId, daysNum);
  }

  @Get('volume-by-day')
  async getVolumeByDay(
    @CurrentUser() user: User,
    @Query('days') days?: string,
  ) {
    const parsed = days ? parseInt(days, 10) : 30;
    const daysNum = isNaN(parsed) || parsed < 1 || parsed > 365 ? 30 : parsed;
    return this.analyticsService.getVolumeByDay(user.id, daysNum);
  }

  @Get('volume-by-split')
  async getVolumeBySplit(@CurrentUser() user: User) {
    return this.analyticsService.getVolumeBySplit(user.id);
  }

  @Get('frequency')
  async getFrequency(
    @CurrentUser() user: User,
    @Query('groupBy') groupBy?: 'week' | 'month',
  ) {
    return this.analyticsService.getFrequency(user.id, groupBy || 'week');
  }

  @Get('personal-records')
  async getPersonalRecords(@CurrentUser() user: User) {
    return this.analyticsService.getPersonalRecords(user.id);
  }
}
