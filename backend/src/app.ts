import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { env } from './config/environment';
import authRoutes from './routes/auth.routes';
import analysisRoutes from './routes/analysis.routes';
import nearbyRoutes from './routes/nearby.routes';
import chatRoutes from './routes/chat.routes';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';

export const createApp = (): Application => {
  const app = express();

  // ─── Security Headers ───────────────────────────────────────────────────────
  app.use(helmet());

  // ─── CORS ───────────────────────────────────────────────────────────────────
  app.use(
    cors({
      origin: env.corsOrigin === '*' ? '*' : env.corsOrigin.split(',').map((o) => o.trim()),
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: env.corsOrigin !== '*',
    })
  );

  // ─── Body Parsing ────────────────────────────────────────────────────────────
  app.use(express.json({ limit: '35mb' }));
  app.use(express.urlencoded({ extended: true, limit: '35mb' }));

  // ─── Global Rate Limit ───────────────────────────────────────────────────────
  app.use(
    rateLimit({
      windowMs: env.rateLimitWindowMs,
      max: env.rateLimitMaxRequests,
      message: {
        success: false,
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'Too many requests. Please try again later.',
        },
      },
      standardHeaders: true,
      legacyHeaders: false,
    })
  );

  // ─── Root & Health Check ───────────────────────────────────────────────────
  app.get('/', (_req: Request, res: Response) => {
    res.status(200).json({
      success: true,
      data: {
        name: 'DermaScan AI Backend API',
        status: 'online',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        environment: env.nodeEnv,
        webAppUrl: 'http://localhost:8080',
      },
    });
  });

  app.get('/health', (_req: Request, res: Response) => {
    res.status(200).json({
      success: true,
      data: {
        status: 'ok',
        timestamp: new Date().toISOString(),
        environment: env.nodeEnv,
      },
    });
  });

  // ─── API Routes ──────────────────────────────────────────────────────────────
  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/analyses', analysisRoutes);
  app.use('/api/v1/nearby', nearbyRoutes);
  app.use('/api/v1/chat', chatRoutes);

  // ─── 404 Handler ─────────────────────────────────────────────────────────────
  app.use(notFoundHandler);

  // ─── Global Error Handler ─────────────────────────────────────────────────────
  app.use(errorHandler);

  return app;
};
