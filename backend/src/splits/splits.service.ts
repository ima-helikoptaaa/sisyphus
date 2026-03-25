import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSplitDto } from './dto/create-split.dto';
import { UpdateSplitDto } from './dto/update-split.dto';
import { ReorderSplitsDto } from './dto/reorder-splits.dto';

@Injectable()
export class SplitsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.workoutSplit.findMany({
      where: { userId },
      include: {
        _count: {
          select: { exercises: true },
        },
      },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findOne(userId: string, splitId: string) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: splitId },
      include: {
        exercises: {
          orderBy: { sortOrder: 'asc' },
        },
        _count: {
          select: { exercises: true },
        },
      },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    return split;
  }

  async create(userId: string, dto: CreateSplitDto) {
    const maxOrder = await this.prisma.workoutSplit.aggregate({
      where: { userId },
      _max: { sortOrder: true },
    });

    const nextOrder = (maxOrder._max.sortOrder ?? -1) + 1;

    return this.prisma.workoutSplit.create({
      data: {
        userId,
        name: dto.name,
        emoji: dto.emoji,
        color: dto.color,
        isActive: dto.isActive,
        sortOrder: nextOrder,
      },
      include: {
        _count: {
          select: { exercises: true },
        },
      },
    });
  }

  async update(userId: string, splitId: string, dto: UpdateSplitDto) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: splitId },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    return this.prisma.workoutSplit.update({
      where: { id: splitId },
      data: dto,
      include: {
        _count: {
          select: { exercises: true },
        },
      },
    });
  }

  async delete(userId: string, splitId: string) {
    const split = await this.prisma.workoutSplit.findUnique({
      where: { id: splitId },
    });

    if (!split) {
      throw new NotFoundException('Split not found');
    }

    if (split.userId !== userId) {
      throw new ForbiddenException('You do not own this split');
    }

    await this.prisma.workoutSplit.delete({
      where: { id: splitId },
    });

    return { deleted: true };
  }

  async reorder(userId: string, dto: ReorderSplitsDto) {
    const updates = dto.splits.map((item) =>
      this.prisma.workoutSplit.updateMany({
        where: { id: item.id, userId },
        data: { sortOrder: item.sortOrder },
      }),
    );

    await this.prisma.$transaction(updates);

    return this.findAll(userId);
  }
}
