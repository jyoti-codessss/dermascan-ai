import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file if present
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

export interface EnvironmentConfig {
  port: number;
  nodeEnv: string;
  mongodbUri: string;
  jwtSecret: string;
  jwtRefreshSecret: string;
  jwtExpiresIn: string;
  jwtRefreshExpiresIn: string;
  corsOrigin: string;
  rateLimitWindowMs: number;
  rateLimitMaxRequests: number;
  authRateLimitMaxRequests: number;
  googleClientId?: string;
  googlePlacesApiKey?: string;
  geminiApiKey?: string;
  uploadMaxSizeBytes: number;
}

/**
 * Validates that required secrets are present.
 * The server will refuse to start if critical environment variables are missing.
 * Tests skip this validation by using mongodb-memory-server (no real MONGODB_URI needed).
 */
const requireEnv = (key: string, fallback?: string): string => {
  const value = process.env[key] || fallback;
  if (!value) {
    console.error(`[Config] FATAL: Required environment variable "${key}" is not set.`);
    console.error(`[Config] Copy backend/.env.example to backend/.env and fill in all required values.`);
    process.exit(1);
  }
  return value;
};

// Only enforce strict validation outside of Jest test runs
const isTest = process.env.NODE_ENV === 'test' || process.env.JEST_WORKER_ID !== undefined;

export const env: EnvironmentConfig = {
  port: parseInt(process.env.PORT || '5001', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  mongodbUri: isTest
    ? (process.env.MONGODB_URI || 'mongodb://localhost:27017/dermascan_test')
    : requireEnv('MONGODB_URI'),
  // JWT secrets — required in production, safe defaults only for testing
  jwtSecret: isTest
    ? (process.env.JWT_SECRET || 'test_access_secret_key_for_jest_only_not_production')
    : requireEnv('JWT_SECRET'),
  jwtRefreshSecret: isTest
    ? (process.env.JWT_REFRESH_SECRET || 'test_refresh_secret_key_for_jest_only_not_production')
    : requireEnv('JWT_REFRESH_SECRET'),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '15m',
  jwtRefreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  corsOrigin: process.env.CORS_ORIGIN || '*',
  rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
  rateLimitMaxRequests: isTest ? 10000 : parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  authRateLimitMaxRequests: isTest ? 10000 : parseInt(process.env.AUTH_RATE_LIMIT_MAX_REQUESTS || '20', 10),
  googleClientId: process.env.GOOGLE_CLIENT_ID || undefined,
  googlePlacesApiKey: process.env.GOOGLE_PLACES_API_KEY || process.env.GOOGLE_MAPS_API_KEY || undefined,
  geminiApiKey: process.env.GEMINI_API_KEY || undefined,
  uploadMaxSizeBytes: parseInt(process.env.UPLOAD_MAX_SIZE_BYTES || '26214400', 10), // 25MB default
};

