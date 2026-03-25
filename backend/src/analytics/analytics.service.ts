import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(userId: string) {
    const totalWorkouts = await this.prisma.workoutSession.count({
      where: { userId, completedAt: { not: null } },
    });

    const now = new Date();
    const startOfWeek = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    startOfWeek.setUTCDate(startOfWeek.getUTCDate() - startOfWeek.getUTCDay());

    const thisWeekWorkouts = await this.prisma.workoutSession.count({
      where: {
        userId,
        completedAt: { not: null },
        date: { gte: startOfWeek },
      },
    });

    const startOfMonth = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1));

    const thisMonthWorkouts = await this.prisma.workoutSession.count({
      where: {
        userId,
        completedAt: { not: null },
        date: { gte: startOfMonth },
      },
    });

    const { currentStreak, longestStreak } = await this.calculateStreak(userId);

    const allSets = await this.prisma.setLog.findMany({
      where: {
        exerciseLog: {
          session: {
            userId,
            completedAt: { not: null },
          },
        },
        isWarmup: false,
        weight: { not: null },
        reps: { not: null },
      },
      select: {
        weight: true,
        reps: true,
      },
    });

    const totalVolume = allSets.reduce((sum, set) => {
      return sum + (set.weight || 0) * (set.reps || 0);
    }, 0);

    const totalSets = await this.prisma.setLog.count({
      where: {
        exerciseLog: {
          session: {
            userId,
            completedAt: { not: null },
          },
        },
        isWarmup: false,
      },
    });

    const totalRepsResult = await this.prisma.setLog.aggregate({
      where: {
        exerciseLog: {
          session: {
            userId,
            completedAt: { not: null },
          },
        },
        isWarmup: false,
      },
      _sum: {
        reps: true,
      },
    });

    const totalReps = totalRepsResult._sum.reps || 0;

    // Calculate average workout duration from startedAt -> completedAt
    const completedSessions = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
      },
      select: {
        startedAt: true,
        completedAt: true,
      },
    });

    let averageWorkoutDuration = 0;
    if (completedSessions.length > 0) {
      const totalMinutes = completedSessions.reduce((sum, s) => {
        const durationMs = new Date(s.completedAt!).getTime() - new Date(s.startedAt).getTime();
        return sum + durationMs / (1000 * 60);
      }, 0);
      averageWorkoutDuration = Math.round(totalMinutes / completedSessions.length);
    }

    return {
      totalWorkouts,
      currentStreak,
      longestStreak,
      thisWeekWorkouts,
      thisMonthWorkouts,
      totalVolume,
      totalSets,
      totalReps,
      averageWorkoutDuration,
    };
  }

  private async calculateStreak(
    userId: string,
  ): Promise<{ currentStreak: number; longestStreak: number }> {
    const sessions = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
      },
      orderBy: { date: 'desc' },
      select: { date: true },
      distinct: ['date'],
    });

    if (sessions.length === 0)
      return { currentStreak: 0, longestStreak: 0 };

    const sessionDates = new Set(
      sessions.map((s) => {
        const d = new Date(s.date);
        d.setHours(0, 0, 0, 0);
        return d.getTime();
      }),
    );

    const sortedDates = Array.from(sessionDates).sort((a, b) => b - a);

    // Calculate longest streak
    let longestStreak = 1;
    let tempStreak = 1;
    for (let i = 1; i < sortedDates.length; i++) {
      const diff = (sortedDates[i - 1] - sortedDates[i]) / (1000 * 60 * 60 * 24);
      if (diff === 1) {
        tempStreak++;
        longestStreak = Math.max(longestStreak, tempStreak);
      } else {
        tempStreak = 1;
      }
    }

    // Calculate current streak
    let currentStreak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let checkDate = new Date(today);

    const mostRecentDate = sortedDates[0];
    const diffFromToday = Math.floor(
      (today.getTime() - mostRecentDate) / (1000 * 60 * 60 * 24),
    );

    if (diffFromToday > 1) {
      return { currentStreak: 0, longestStreak };
    }

    if (diffFromToday === 1) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    while (sessionDates.has(checkDate.getTime())) {
      currentStreak++;
      checkDate.setDate(checkDate.getDate() - 1);
    }

    longestStreak = Math.max(longestStreak, currentStreak);

    return { currentStreak, longestStreak };
  }

  async getExerciseProgress(userId: string, exerciseId: string, days?: number) {
    const sessionFilter: { userId: string; completedAt: { not: null }; date?: { gte: Date } } = {
      userId,
      completedAt: { not: null },
    };

    if (days) {
      const sinceDate = new Date();
      sinceDate.setDate(sinceDate.getDate() - days);
      sessionFilter.date = { gte: sinceDate };
    }

    const where = {
      exerciseId,
      session: sessionFilter,
    };

    const logs = await this.prisma.exerciseLog.findMany({
      where,
      include: {
        session: {
          select: { date: true },
        },
        sets: {
          where: { isWarmup: false },
          orderBy: { setNumber: 'asc' },
        },
      },
      orderBy: {
        session: { date: 'asc' },
      },
    });

    return logs.map((log) => {
      const bestSet = log.sets.reduce(
        (best, set) => {
          const weight = set.weight || 0;
          if (weight > (best.weight || 0)) {
            return set;
          }
          return best;
        },
        log.sets[0] || null,
      );

      const totalVolume = log.sets.reduce((sum, set) => {
        return sum + (set.weight || 0) * (set.reps || 0);
      }, 0);

      return {
        date: log.session.date,
        sets: log.sets,
        bestSet,
        totalVolume,
        totalSets: log.sets.length,
      };
    });
  }

  async getVolumeByDay(userId: string, days: number) {
    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - days);
    sinceDate.setHours(0, 0, 0, 0);

    const sessions = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
        date: { gte: sinceDate },
      },
      select: {
        date: true,
      },
      orderBy: { date: 'asc' },
    });

    const countByDay: Record<string, number> = {};

    for (const session of sessions) {
      const dateKey = new Date(session.date).toISOString().split('T')[0];
      countByDay[dateKey] = (countByDay[dateKey] || 0) + 1;
    }

    return Object.entries(countByDay).map(([date, count]) => ({
      date,
      count,
    }));
  }

  async getVolumeBySplit(userId: string) {
    const sessions = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
      },
      include: {
        split: {
          select: { id: true, name: true, emoji: true, color: true },
        },
        exerciseLogs: {
          include: {
            sets: {
              where: { isWarmup: false },
            },
          },
        },
      },
      orderBy: { date: 'asc' },
    });

    const volumeBySplit: Record<
      string,
      {
        split: { id: string; name: string; emoji: string; color: string };
        data: { date: Date; volume: number }[];
      }
    > = {};

    for (const session of sessions) {
      const splitId = session.split.id;

      if (!volumeBySplit[splitId]) {
        volumeBySplit[splitId] = {
          split: session.split,
          data: [],
        };
      }

      const sessionVolume = session.exerciseLogs.reduce((total, log) => {
        return (
          total +
          log.sets.reduce(
            (setTotal, set) =>
              setTotal + (set.weight || 0) * (set.reps || 0),
            0,
          )
        );
      }, 0);

      volumeBySplit[splitId].data.push({
        date: session.date,
        volume: sessionVolume,
      });
    }

    return Object.values(volumeBySplit);
  }

  async getFrequency(
    userId: string,
    groupBy: 'week' | 'month' = 'week',
  ) {
    const sessions = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
      },
      select: {
        date: true,
        splitId: true,
      },
      orderBy: { date: 'asc' },
    });

    const grouped: Record<string, number> = {};

    for (const session of sessions) {
      const date = new Date(session.date);
      let key: string;

      if (groupBy === 'week') {
        const startOfWeek = new Date(date);
        startOfWeek.setDate(date.getDate() - date.getDay());
        key = startOfWeek.toISOString().split('T')[0];
      } else {
        key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      }

      grouped[key] = (grouped[key] || 0) + 1;
    }

    return Object.entries(grouped).map(([period, count]) => ({
      period,
      count,
    }));
  }

  async getPersonalRecords(userId: string) {
    // Get all exercises the user has logged sets for
    const exerciseLogs = await this.prisma.exerciseLog.findMany({
      where: {
        session: {
          userId,
          completedAt: { not: null },
        },
      },
      select: {
        exerciseId: true,
      },
      distinct: ['exerciseId'],
    });

    const exerciseIds = exerciseLogs.map((l) => l.exerciseId);

    if (exerciseIds.length === 0) {
      return [];
    }

    const exercises = await this.prisma.exercise.findMany({
      where: { id: { in: exerciseIds } },
      select: { id: true, name: true },
    });

    const exerciseMap = new Map(exercises.map((e) => [e.id, e.name]));

    const allSets = await this.prisma.setLog.findMany({
      where: {
        exerciseLog: {
          exerciseId: { in: exerciseIds },
          session: {
            userId,
            completedAt: { not: null },
          },
        },
        isWarmup: false,
      },
      include: {
        exerciseLog: {
          select: {
            exerciseId: true,
            session: {
              select: { date: true },
            },
          },
        },
      },
    });

    const byExercise = new Map<
      string,
      {
        bestWeight: { value: number; date: Date } | null;
        bestVolume: { value: number; date: Date } | null;
        bestReps: { value: number; date: Date } | null;
      }
    >();

    for (const set of allSets) {
      const exId = set.exerciseLog.exerciseId;
      const date = set.exerciseLog.session.date;
      const weight = set.weight || 0;
      const reps = set.reps || 0;
      const volume = weight * reps;

      if (!byExercise.has(exId)) {
        byExercise.set(exId, { bestWeight: null, bestVolume: null, bestReps: null });
      }
      const rec = byExercise.get(exId)!;

      if (!rec.bestWeight || weight > rec.bestWeight.value) {
        rec.bestWeight = { value: weight, date };
      }
      if (!rec.bestVolume || volume > rec.bestVolume.value) {
        rec.bestVolume = { value: volume, date };
      }
      if (!rec.bestReps || reps > rec.bestReps.value) {
        rec.bestReps = { value: reps, date };
      }
    }

    return Array.from(byExercise.entries()).map(([exerciseId, rec]) => ({
      exerciseId,
      exerciseName: exerciseMap.get(exerciseId) || null,
      bestWeight: rec.bestWeight?.value ?? null,
      bestWeightDate: rec.bestWeight?.date ?? null,
      bestVolume: rec.bestVolume?.value ?? null,
      bestVolumeDate: rec.bestVolume?.date ?? null,
      bestReps: rec.bestReps?.value ?? null,
      bestRepsDate: rec.bestReps?.date ?? null,
    }));
  }
}
