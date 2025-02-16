-- CreateTable
CREATE TABLE "Settings" (
    "id" SERIAL NOT NULL,
    "responseTimeThreshold" INTEGER NOT NULL,
    "testFrequency" INTEGER NOT NULL,
    "emailNotifications" BOOLEAN NOT NULL,
    "slackNotifications" BOOLEAN NOT NULL,
    "notificationEmail" TEXT NOT NULL,
    "slackWebhookUrl" TEXT,

    CONSTRAINT "Settings_pkey" PRIMARY KEY ("id")
);
