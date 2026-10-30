import { createApp } from './app';
import { connectDatabase } from './config/database';
import { env } from './config/environment';
import { logger } from './utils/logger';

const bootstrap = async (): Promise<void> => {
  try {
    // Connect to MongoDB with graceful fallback (non-blocking)
    try {
      await connectDatabase();
    } catch (dbError: any) {
      logger.warn(`[MongoDB] Initial connection notice: ${dbError.message || dbError}. Server continuing in high-availability mode.`);
    }

    // Initialize PostgreSQL / PostGIS Spatial Database connection
    const { initPostgres } = await import('./config/postgres');
    await initPostgres();

    const app = createApp();
    const server = app.listen(env.port, () => {
      logger.info(`[Server] DermaScan AI backend running on port ${env.port} [${env.nodeEnv}]`);
    });

    // ─── Graceful Shutdown ───────────────────────────────────────────────────
    const shutdown = async (signal: string): Promise<void> => {
      logger.info(`[Server] ${signal} received — starting graceful shutdown`);
      server.close(async () => {
        const { disconnectDatabase } = await import('./config/database');
        await disconnectDatabase();
        logger.info('[Server] Shutdown complete');
        process.exit(0);
      });

      // Force shutdown after 10 seconds
      setTimeout(() => {
        logger.error('[Server] Forced shutdown after timeout');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => void shutdown('SIGTERM'));
    process.on('SIGINT', () => void shutdown('SIGINT'));

    process.on('unhandledRejection', (reason) => {
      logger.error('[Server] Unhandled rejection:', reason);
      void shutdown('UNHANDLED_REJECTION');
    });

    process.on('uncaughtException', (error) => {
      logger.error('[Server] Uncaught exception:', error);
      void shutdown('UNCAUGHT_EXCEPTION');
    });
  } catch (error) {
    logger.error('[Server] Failed to start:', error);
    process.exit(1);
  }
};

void bootstrap();
