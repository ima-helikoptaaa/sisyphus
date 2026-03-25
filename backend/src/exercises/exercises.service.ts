import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateExerciseDto } from './dto/create-exercise.dto';
import { UpdateExerciseDto } from './dto/update-exercise.dto';
import { ReorderExercisesDto } from './dto/reorder-exercises.dto';

@Injectable()
export class ExercisesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAllBySplit(userId: string, splitId: string) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: splitId },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    return this.prisma.exercise.findMany({
      where: { splitId },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async create(userId: string, splitId: string, dto: CreateExerciseDto) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: splitId },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    const maxOrder = await this.prisma.exercise.aggregate({
      where: { splitId },
      _max: { sortOrder: true },
    });

    const nextOrder = (maxOrder._max.sortOrder ?? -1) + 1;

    return this.prisma.exercise.create({
      data: {
        splitId,
        name: dto.name,
        muscleGroup: dto.muscleGroup,
        exerciseType: dto.exerciseType || 'weighted',
        notes: dto.notes,
        isActive: dto.isActive,
        sortOrder: nextOrder,
      },
    });
  }

  async update(userId: string, splitId: string, exerciseId: string, dto: UpdateExerciseDto) {
    const exercise = await this.prisma.exercise.findUnique({
      where: { id: exerciseId },
      include: { split: true },
    });

    if (!exercise) {
      throw new NotFoundException('Exercise not found');
    }

    if (exercise.split.userId !== userId) {
      throw new ForbiddenException('You do not own this exercise');
    }

    if (exercise.splitId !== splitId) {
      throw new NotFoundException('Exercise not found in this split');
    }

    return this.prisma.exercise.update({
      where: { id: exerciseId },
      data: dto,
    });
  }

  async delete(userId: string, splitId: string, exerciseId: string) {
    const exercise = await this.prisma.exercise.findUnique({
      where: { id: exerciseId },
      include: { split: true },
    });

    if (!exercise) {
      throw new NotFoundException('Exercise not found');
    }

    if (exercise.split.userId !== userId) {
      throw new ForbiddenException('You do not own this exercise');
    }

    if (exercise.splitId !== splitId) {
      throw new NotFoundException('Exercise not found in this split');
    }

    await this.prisma.exercise.delete({
      where: { id: exerciseId },
    });

    return { deleted: true };
  }

  async reorder(
    userId: string,
    splitId: string,
    dto: ReorderExercisesDto,
  ) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: splitId },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    const updates = dto.exercises.map((item) =>
      this.prisma.exercise.updateMany({
        where: { id: item.id, splitId },
        data: { sortOrder: item.sortOrder },
      }),
    );

    await this.prisma.$transaction(updates);

    return this.findAllBySplit(userId, splitId);
  }
}
