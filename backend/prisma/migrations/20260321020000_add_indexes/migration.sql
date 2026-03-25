-- CreateIndex
CREATE INDEX "workout_splits_user_id_idx" ON "workout_splits"("user_id");

-- CreateIndex
CREATE INDEX "exercises_split_id_idx" ON "exercises"("split_id");

-- CreateIndex
CREATE INDEX "workout_sessions_user_id_idx" ON "workout_sessions"("user_id");

-- CreateIndex
CREATE INDEX "workout_sessions_user_id_completed_at_idx" ON "workout_sessions"("user_id", "completed_at");

-- CreateIndex
CREATE INDEX "workout_sessions_split_id_idx" ON "workout_sessions"("split_id");

-- CreateIndex
CREATE INDEX "exercise_logs_session_id_idx" ON "exercise_logs"("session_id");

-- CreateIndex
CREATE INDEX "exercise_logs_exercise_id_idx" ON "exercise_logs"("exercise_id");

-- CreateIndex
CREATE INDEX "set_logs_exercise_log_id_idx" ON "set_logs"("exercise_log_id");
