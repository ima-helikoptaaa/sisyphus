import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSessionDto } from './dto/create-session.dto';
import { LogSetDto, UpdateSetDto } from './dto/log-exercise.dto';
import { CreateExerciseLogDto, UpdateExerciseLogDto } from './dto/exercise-log.dto';

@Injectable()
export class SessionsService {
  constructor(private readonly prisma: PrismaService) {}

  private readonly sessionInclude = {
    split: {
      select: { id: true, name: true, emoji: true, color: true },
    },
    exerciseLogs: {
      orderBy: { sortOrder: 'asc' as const },
      include: {
        exercise: {
          select: { id: true, name: true, muscleGroup: true, exerciseType: true },
        },
        sets: {
          orderBy: { setNumber: 'asc' as const },
        },
      },
    },
  };

  private readonly exerciseLogInclude = {
    exercise: {
      select: { id: true, name: true, muscleGroup: true, exerciseType: true },
    },
    sets: {
      orderBy: { setNumber: 'asc' as const },
    },
  };

  async findAll(
    userId: string,
    filters: {
      splitId?: string;
      startDate?: string;
      endDate?: string;
      limit?: number;
    },
  ) {
    const where: { userId: string; splitId?: string; date?: { gte?: Date; lte?: Date } } = { userId };

    if (filters.splitId) {
      where.splitId = filters.splitId;
    }

    if (filters.startDate || filters.endDate) {
      where.date = {};
      if (filters.startDate) {
        const startDate = new Date(filters.startDate);
        if (!isNaN(startDate.getTime())) {
          where.date.gte = startDate;
        }
      }
      if (filters.endDate) {
        const endDate = new Date(filters.endDate);
        if (!isNaN(endDate.getTime())) {
          where.date.lte = endDate;
        }
      }
    }

    return this.prisma.workoutSession.findMany({
      where,
      include: {
        split: {
          select: { id: true, name: true, emoji: true, color: true },
        },
        _count: {
          select: { exerciseLogs: true },
        },
      },
      orderBy: { date: 'desc' },
      take: filters.limit || undefined,
    });
  }

  async findToday(userId: string) {
    const now = new Date();
    const startOfDay = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    const endOfDay = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1));

    return this.prisma.workoutSession.findMany({
      where: {
        userId,
        date: {
          gte: startOfDay,
          lt: endOfDay,
        },
      },
      include: this.sessionInclude,
      orderBy: { date: 'desc' },
    });
  }

  async findActive(userId: string) {
    return this.prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: null,
      },
      include: this.sessionInclude,
      orderBy: { date: 'desc' },
    });
  }

  async findPrevious(userId: string, splitId: string, beforeSessionId: string) {
    const beforeSession = await this.prisma.workoutSession.findUnique({
      where: { id: beforeSessionId },
      select: { date: true, userId: true },
    });

    if (beforeSession && beforeSession.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    return this.prisma.workoutSession.findMany({
      where: {
        userId,
        splitId,
        completedAt: { not: null },
        ...(beforeSession
          ? { date: { lt: beforeSession.date } }
          : {}),
      },
      include: this.sessionInclude,
      orderBy: { date: 'desc' },
      take: 10,
    });
  }

  async findOne(userId: string, sessionId: string) {
    const session = await this.prisma.workoutSession.findUnique({
      where: { id: sessionId },
      include: this.sessionInclude,
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    return session;
  }

  async create(userId: string, dto: CreateSessionDto) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: dto.splitId },
      include: {
        exercises: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
      },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    const sessionDate = dto.date ? new Date(dto.date) : new Date();

    return this.prisma.workoutSession.create({
      data: {
        userId,
        splitId: dto.splitId,
        date: sessionDate,
        notes: dto.notes,
        exerciseLogs: {
          create: split.exercises.map((exercise, index) => ({
            exerciseId: exercise.id,
            sortOrder: index,
          })),
        },
      },
      include: this.sessionInclude,
    });
  }

  async complete(userId: string, sessionId: string) {
    const session = await this.prisma.workoutSession.findUnique({
      where: { id: sessionId },
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    return this.prisma.workoutSession.update({
      where: { id: sessionId },
      data: { completedAt: new Date() },
      include: this.sessionInclude,
    });
  }

  async deleteSession(userId: string, sessionId: string) {
    const session = await this.prisma.workoutSession.findUnique({
      where: { id: sessionId },
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    await this.prisma.workoutSession.delete({
      where: { id: sessionId },
    });

    return { deleted: true };
  }

  async createExerciseLog(
    userId: string,
    sessionId: string,
    dto: CreateExerciseLogDto,
  ) {
    const session = await this.prisma.workoutSession.findUnique({
      where: { id: sessionId },
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    return this.prisma.exerciseLog.create({
      data: {
        sessionId,
        exerciseId: dto.exercise_id,
        sortOrder: dto.sort_order,
      },
      include: this.exerciseLogInclude,
    });
  }

  async updateExerciseLog(
    userId: string,
    sessionId: string,
    logId: string,
    dto: UpdateExerciseLogDto,
  ) {
    const session = await this.prisma.workoutSession.findUnique({
      where: { id: sessionId },
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    const exerciseLog = await this.prisma.exerciseLog.findUnique({
      where: { id: logId },
    });

    if (!exerciseLog || exerciseLog.sessionId !== sessionId) {
      throw new NotFoundException('Exercise log not found in this session');
    }

    const data: { skipped?: boolean; sortOrder?: number } = {};
    if (dto.skipped !== undefined) {
      data.skipped = dto.skipped;
    }
    if (dto.sort_order !== undefined) {
      data.sortOrder = dto.sort_order;
    }

    return this.prisma.exerciseLog.update({
      where: { id: logId },
      data,
      include: this.exerciseLogInclude,
    });
  }

  async logSet(
    userId: string,
    sessionId: string,
    exerciseLogId: string,
    dto: LogSetDto,
  ) {
    const session = await this.prisma.workoutSession.findUnique({
      where: { id: sessionId },
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.userId !== userId) {
      throw new ForbiddenException('You do not own this session');
    }

    const exerciseLog = await this.prisma.exerciseLog.findUnique({
      where: { id: exerciseLogId },
    });

    if (!exerciseLog || exerciseLog.sessionId !== sessionId) {
      throw new NotFoundException('Exercise log not found in this session');
    }

    return this.prisma.setLog.create({
      data: {
        exerciseLogId,
        setNumber: dto.setNumber,
        weight: dto.weight,
        reps: dto.reps,
        durationSecs: dto.durationSecs,
        rpe: dto.rpe,
        isWarmup: dto.isWarmup,
        isDropset: dto.isDropset,
        bodyWeightModifier: dto.bodyWeightModifier,
      },
    });
  }

  async updateSet(userId: string, setId: string, dto: UpdateSetDto) {
    const set = await this.prisma.setLog.findUnique({
      where: { id: setId },
      include: {
        exerciseLog: {
          include: {
            session: true,
          },
        },
      },
    });

    if (!set) {
      throw new NotFoundException('Set not found');
    }

    if (set.exerciseLog.session.userId !== userId) {
      throw new ForbiddenException('You do not own this set');
    }

    const data: Partial<{
      setNumber: number; weight: number; reps: number; durationSecs: number;
      rpe: number; isWarmup: boolean; isDropset: boolean; bodyWeightModifier: number;
    }> = {};
    if (dto.setNumber !== undefined) data.setNumber = dto.setNumber;
    if (dto.weight !== undefined) data.weight = dto.weight;
    if (dto.reps !== undefined) data.reps = dto.reps;
    if (dto.durationSecs !== undefined) data.durationSecs = dto.durationSecs;
    if (dto.rpe !== undefined) data.rpe = dto.rpe;
    if (dto.isWarmup !== undefined) data.isWarmup = dto.isWarmup;
    if (dto.isDropset !== undefined) data.isDropset = dto.isDropset;
    if (dto.bodyWeightModifier !== undefined) data.bodyWeightModifier = dto.bodyWeightModifier;

    return this.prisma.setLog.update({
      where: { id: setId },
      data,
    });
  }

  async deleteSet(userId: string, setId: string) {
    const set = await this.prisma.setLog.findUnique({
      where: { id: setId },
      include: {
        exerciseLog: {
          include: {
            session: true,
          },
        },
      },
    });

    if (!set) {
      throw new NotFoundException('Set not found');
    }

    if (set.exerciseLog.session.userId !== userId) {
      throw new ForbiddenException('You do not own this set');
    }

    await this.prisma.setLog.delete({
      where: { id: setId },
    });

    return { deleted: true };
  }

  async getLastSessionForSplit(userId: string, splitId: string) {
    const session = await this.prisma.workoutSession.findFirst({
      where: {
        userId,
        splitId,
        completedAt: { not: null },
      },
      orderBy: { date: 'desc' },
      include: this.sessionInclude,
    });

    if (!session) {
      throw new NotFoundException('No completed sessions found for this split');
    }

    return session;
  }
}
