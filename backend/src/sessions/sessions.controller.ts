import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { SessionsService } from './sessions.service';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';
import { CreateSessionDto } from './dto/create-session.dto';
import { LogSetDto, UpdateSetDto } from './dto/log-exercise.dto';
import { CreateExerciseLogDto, UpdateExerciseLogDto } from './dto/exercise-log.dto';

@Controller('sessions')
@UseGuards(AuthGuard)
export class SessionsController {
  constructor(private readonly sessionsService: SessionsService) {}

  @Get('today')
  async findToday(@CurrentUser() user: User) {
    return this.sessionsService.findToday(user.id);
  }

  @Get('active')
  async findActive(@CurrentUser() user: User) {
    return this.sessionsService.findActive(user.id);
  }

  @Get('previous')
  async findPrevious(
    @CurrentUser() user: User,
    @Query('split_id') splitId: string,
    @Query('before_session_id') beforeSessionId: string,
  ) {
    return this.sessionsService.findPrevious(user.id, splitId, beforeSessionId);
  }

  @Get('last/:splitId')
  async getLastSession(
    @CurrentUser() user: User,
    @Param('splitId') splitId: string,
  ) {
    return this.sessionsService.getLastSessionForSplit(user.id, splitId);
  }

  @Get()
  async findAll(
    @CurrentUser() user: User,
    @Query('splitId') splitId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('limit') limit?: number,
  ) {
    return this.sessionsService.findAll(user.id, {
      splitId,
      startDate,
      endDate,
      limit,
    });
  }

  @Get(':id')
  async findOne(@CurrentUser() user: User, @Param('id') id: string) {
    return this.sessionsService.findOne(user.id, id);
  }

  @Post()
  async create(@CurrentUser() user: User, @Body() dto: CreateSessionDto) {
    return this.sessionsService.create(user.id, dto);
  }

  @Patch(':id/complete')
  async complete(@CurrentUser() user: User, @Param('id') id: string) {
    return this.sessionsService.complete(user.id, id);
  }

  @Delete(':id')
  async delete(@CurrentUser() user: User, @Param('id') id: string) {
    return this.sessionsService.deleteSession(user.id, id);
  }

  @Post(':sessionId/exercises')
  async createExerciseLog(
    @CurrentUser() user: User,
    @Param('sessionId') sessionId: string,
    @Body() dto: CreateExerciseLogDto,
  ) {
    return this.sessionsService.createExerciseLog(user.id, sessionId, dto);
  }

  @Patch(':sessionId/exercises/:logId')
  async updateExerciseLog(
    @CurrentUser() user: User,
    @Param('sessionId') sessionId: string,
    @Param('logId') logId: string,
    @Body() dto: UpdateExerciseLogDto,
  ) {
    return this.sessionsService.updateExerciseLog(user.id, sessionId, logId, dto);
  }

  @Post(':sessionId/exercises/:exerciseLogId/sets')
  async logSet(
    @CurrentUser() user: User,
    @Param('sessionId') sessionId: string,
    @Param('exerciseLogId') exerciseLogId: string,
    @Body() dto: LogSetDto,
  ) {
    return this.sessionsService.logSet(user.id, sessionId, exerciseLogId, dto);
  }

  @Patch(':sessionId/exercises/:exerciseLogId/sets/:setId')
  async updateSet(
    @CurrentUser() user: User,
    @Param('sessionId') sessionId: string,
    @Param('exerciseLogId') exerciseLogId: string,
    @Param('setId') setId: string,
    @Body() dto: UpdateSetDto,
  ) {
    return this.sessionsService.updateSet(user.id, setId, dto);
  }

  @Delete(':sessionId/exercises/:exerciseLogId/sets/:setId')
  async deleteSet(
    @CurrentUser() user: User,
    @Param('sessionId') sessionId: string,
    @Param('exerciseLogId') exerciseLogId: string,
    @Param('setId') setId: string,
  ) {
    return this.sessionsService.deleteSet(user.id, setId);
  }
}
