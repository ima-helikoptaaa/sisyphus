import { Module } from '@nestjs/common';
import { SplitsController } from './splits.controller';
import { SplitsService } from './splits.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [SplitsController],
  providers: [SplitsService],
  exports: [SplitsService],
})
export class SplitsModule {}
