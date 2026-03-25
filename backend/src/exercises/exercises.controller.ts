import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { ExercisesService } from './exercises.service';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';
import { CreateExerciseDto } from './dto/create-exercise.dto';
import { UpdateExerciseDto } from './dto/update-exercise.dto';
import { ReorderExercisesDto } from './dto/reorder-exercises.dto';

@Controller()
@UseGuards(AuthGuard)
export class ExercisesController {
  constructor(private readonly exercisesService: ExercisesService) {}

  @Get('splits/:splitId/exercises')
  async findAllBySplit(
    @CurrentUser() user: User,
    @Param('splitId') splitId: string,
  ) {
    return this.exercisesService.findAllBySplit(user.id, splitId);
  }

  @Post('splits/:splitId/exercises')
  async create(
    @CurrentUser() user: User,
    @Param('splitId') splitId: string,
    @Body() dto: CreateExerciseDto,
  ) {
    return this.exercisesService.create(user.id, splitId, dto);
  }

  @Patch('splits/:splitId/exercises/reorder')
  async reorder(
    @CurrentUser() user: User,
    @Param('splitId') splitId: string,
    @Body() dto: ReorderExercisesDto,
  ) {
    return this.exercisesService.reorder(user.id, splitId, dto);
  }

  @Patch('splits/:splitId/exercises/:id')
  async update(
    @CurrentUser() user: User,
    @Param('splitId') splitId: string,
    @Param('id') id: string,
    @Body() dto: UpdateExerciseDto,
  ) {
    return this.exercisesService.update(user.id, splitId, id, dto);
  }

  @Delete('splits/:splitId/exercises/:id')
  async delete(
    @CurrentUser() user: User,
    @Param('splitId') splitId: string,
    @Param('id') id: string,
  ) {
    return this.exercisesService.delete(user.id, splitId, id);
  }
}
