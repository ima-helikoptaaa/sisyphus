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
import { SplitsService } from './splits.service';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';
import { CreateSplitDto } from './dto/create-split.dto';
import { UpdateSplitDto } from './dto/update-split.dto';
import { ReorderSplitsDto } from './dto/reorder-splits.dto';

@Controller('splits')
@UseGuards(AuthGuard)
export class SplitsController {
  constructor(private readonly splitsService: SplitsService) {}

  @Get()
  async findAll(@CurrentUser() user: User) {
    return this.splitsService.findAll(user.id);
  }

  @Post()
  async create(@CurrentUser() user: User, @Body() dto: CreateSplitDto) {
    return this.splitsService.create(user.id, dto);
  }

  @Get(':id')
  async findOne(@CurrentUser() user: User, @Param('id') id: string) {
    return this.splitsService.findOne(user.id, id);
  }

  @Patch('reorder')
  async reorder(@CurrentUser() user: User, @Body() dto: ReorderSplitsDto) {
    return this.splitsService.reorder(user.id, dto);
  }

  @Patch(':id')
  async update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateSplitDto,
  ) {
    return this.splitsService.update(user.id, id, dto);
  }

  @Delete(':id')
  async delete(@CurrentUser() user: User, @Param('id') id: string) {
    return this.splitsService.delete(user.id, id);
  }
}
