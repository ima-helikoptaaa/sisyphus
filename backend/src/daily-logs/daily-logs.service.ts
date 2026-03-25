import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpsertDailyLogDto } from './dto/upsert-daily-log.dto';

@Injectable()
export class DailyLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async upsert(userId: string, dto: UpsertDailyLogDto) {
    const date = new Date(dto.date + 'T00:00:00.000Z');

    return this.prisma.dailyLog.upsert({
      where: {
        userId_date: { userId, date },
      },
      create: {
        userId,
        date,
        weightKg: dto.weightKg,
        proteinG: dto.proteinG,
        caloriesKcal: dto.caloriesKcal,
        waterMl: dto.waterMl,
        sleepHours: dto.sleepHours,
        notes: dto.notes,
      },
      update: {
        ...(dto.weightKg !== undefined && { weightKg: dto.weightKg }),
        ...(dto.proteinG !== undefined && { proteinG: dto.proteinG }),
        ...(dto.caloriesKcal !== undefined && { caloriesKcal: dto.caloriesKcal }),
        ...(dto.waterMl !== undefined && { waterMl: dto.waterMl }),
        ...(dto.sleepHours !== undefined && { sleepHours: dto.sleepHours }),
        ...(dto.notes !== undefined && { notes: dto.notes }),
      },
    });
  }

  async findByDateRange(userId: string, startDate: Date, endDate: Date) {
    return this.prisma.dailyLog.findMany({
      where: {
        userId,
        date: { gte: startDate, lte: endDate },
      },
      orderBy: { date: 'desc' },
    });
  }

  async getToday(userId: string) {
    const today = new Date();
    const date = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()));

    return this.prisma.dailyLog.findUnique({
      where: {
        userId_date: { userId, date },
      },
    });
  }

  async getLatest(userId: string) {
    return this.prisma.dailyLog.findFirst({
      where: { userId },
      orderBy: { date: 'desc' },
    });
  }

  async delete(userId: string, id: string) {
    return this.prisma.dailyLog.deleteMany({
      where: { id, userId },
    });
  }
}
