import { Module } from '@nestjs/common';
import { DailyLogsController } from './daily-logs.controller';
import { DailyLogsService } from './daily-logs.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [DailyLogsController],
  providers: [DailyLogsService],
  exports: [DailyLogsService],
})
export class DailyLogsModule {}
