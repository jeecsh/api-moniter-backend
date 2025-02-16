/*
  Warnings:

  - You are about to drop the column `endpointId` on the `ApiTest` table. All the data in the column will be lost.
  - You are about to drop the `Endpoint` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[userId]` on the table `Settings` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `updatedAt` to the `Settings` table without a default value. This is not possible if the table is not empty.
  - Added the required column `userId` to the `Settings` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "ApiTest" DROP CONSTRAINT "ApiTest_endpointId_fkey";

-- DropForeignKey
ALTER TABLE "Endpoint" DROP CONSTRAINT "Endpoint_userId_fkey";

-- AlterTable
ALTER TABLE "ApiTest" DROP COLUMN "endpointId";

-- AlterTable
ALTER TABLE "Settings" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "headers" JSONB,
ADD COLUMN     "method" TEXT NOT NULL DEFAULT 'GET',
ADD COLUMN     "name" TEXT NOT NULL DEFAULT 'Default API',
ADD COLUMN     "requestBody" TEXT,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "url" TEXT NOT NULL DEFAULT 'https://api.example.com',
ADD COLUMN     "userId" TEXT NOT NULL,
ALTER COLUMN "responseTimeThreshold" SET DEFAULT 200,
ALTER COLUMN "testFrequency" SET DEFAULT 5,
ALTER COLUMN "emailNotifications" SET DEFAULT true,
ALTER COLUMN "slackNotifications" SET DEFAULT false,
ALTER COLUMN "notificationEmail" SET DEFAULT '';

-- DropTable
DROP TABLE "Endpoint";

-- CreateIndex
CREATE UNIQUE INDEX "Settings_userId_key" ON "Settings"("userId");

-- AddForeignKey
ALTER TABLE "Settings" ADD CONSTRAINT "Settings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
