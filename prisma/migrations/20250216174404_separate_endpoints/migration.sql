/*
  Warnings:

  - You are about to drop the column `headers` on the `Settings` table. All the data in the column will be lost.
  - You are about to drop the column `method` on the `Settings` table. All the data in the column will be lost.
  - You are about to drop the column `name` on the `Settings` table. All the data in the column will be lost.
  - You are about to drop the column `requestBody` on the `Settings` table. All the data in the column will be lost.
  - You are about to drop the column `url` on the `Settings` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Settings" DROP COLUMN "headers",
DROP COLUMN "method",
DROP COLUMN "name",
DROP COLUMN "requestBody",
DROP COLUMN "url";

-- CreateTable
CREATE TABLE "Endpoint" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "method" TEXT NOT NULL,
    "headers" JSONB NOT NULL DEFAULT '[]',
    "requestBody" TEXT,
    "expectedResponseTime" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Endpoint_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Endpoint" ADD CONSTRAINT "Endpoint_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
