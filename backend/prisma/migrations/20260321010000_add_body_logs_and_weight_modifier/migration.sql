-- CreateTable
CREATE TABLE "body_logs" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "weight_kg" DOUBLE PRECISION,
    "protein_g" DOUBLE PRECISION,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "body_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "body_logs_user_id_date_key" ON "body_logs"("user_id", "date");

-- AlterTable
ALTER TABLE "set_logs" ADD COLUMN "body_weight_modifier" DOUBLE PRECISION;

-- AddForeignKey
ALTER TABLE "body_logs" ADD CONSTRAINT "body_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
