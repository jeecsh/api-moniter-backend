/*
  Warnings:

  - You are about to drop the column `endpoint` on the `ApiTest` table. All the data in the column will be lost.
  - Added the required column `endpointId` to the `ApiTest` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ApiTest" DROP COLUMN "endpoint",
ADD COLUMN     "endpointId" TEXT NOT NULL;

-- CreateTable
CREATE TABLE "Endpoint" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "method" TEXT NOT NULL,
    "headers" JSONB,
    "requestBody" TEXT,
    "expectedResponseTime" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Endpoint_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Endpoint" ADD CONSTRAINT "Endpoint_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiTest" ADD CONSTRAINT "ApiTest_endpointId_fkey" FOREIGN KEY ("endpointId") REFERENCES "Endpoint"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
