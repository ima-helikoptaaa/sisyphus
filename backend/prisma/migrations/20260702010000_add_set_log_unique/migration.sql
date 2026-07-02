-- Add unique constraint to prevent duplicate set numbers within an exercise log
CREATE UNIQUE INDEX "set_logs_exercise_log_id_set_number_key" ON "set_logs"("exercise_log_id", "set_number");
