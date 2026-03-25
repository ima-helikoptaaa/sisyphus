import { Module, Controller, Get } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { SplitsModule } from './splits/splits.module';
import { ExercisesModule } from './exercises/exercises.module';
import { SessionsModule } from './sessions/sessions.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { DailyLogsModule } from './daily-logs/daily-logs.module';

@Controller()
class HealthController {
  @Get()
  health() {
    return { status: 'ok' };
  }
}

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    SplitsModule,
    ExercisesModule,
    SessionsModule,
    AnalyticsModule,
    DailyLogsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
