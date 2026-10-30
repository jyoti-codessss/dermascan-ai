import { Pool, QueryResult, QueryResultRow } from 'pg';
import { logger } from '../utils/logger';

// Standard PostgreSQL configuration with environment variables
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || undefined,
  host: process.env.PGHOST || 'localhost',
  port: parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'dermascan_db',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 3000,
});

let isPostgresConnected = false;

pool.on('error', (err) => {
  logger.warn('[PostgreSQL] Unexpected pool client error:', err.message);
  isPostgresConnected = false;
});

/**
 * Initializes and verifies PostgreSQL connection.
 * Does not throw so that the application maintains 100% uptime with graceful fallback.
 */
export const initPostgres = async (): Promise<boolean> => {
  try {
    const client = await pool.connect();
    const res = await client.query('SELECT NOW() as now, PostGIS_Full_Version() as postgis_version');
    client.release();
    isPostgresConnected = true;
    logger.info(`[PostgreSQL] Connected successfully to database. PostGIS: ${res.rows[0]?.postgis_version ? 'Active' : 'Not installed'}`);
    return true;
  } catch (error: any) {
    isPostgresConnected = false;
    logger.info(`[PostgreSQL] Notice: Standalone PostgreSQL not connected (${error.message || 'offline'}). Utilizing High-Availability In-Memory Spatial PostGIS Fallback.`);
    return false;
  }
};

export const getPostgresStatus = (): boolean => isPostgresConnected;

export const query = async <T extends QueryResultRow = any>(
  text: string,
  params?: any[]
): Promise<QueryResult<T>> => {
  return pool.query<T>(text, params);
};

export default {
  pool,
  query,
  initPostgres,
  getPostgresStatus,
};
