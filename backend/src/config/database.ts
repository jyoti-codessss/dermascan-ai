import mongoose from 'mongoose';
import dns from 'dns';
import { env } from './environment';
import { logger } from '../utils/logger';

// Ensure Node resolves DNS reliably without overriding container resolvers
if (process.platform === 'win32') {
  try {
    dns.setServers(['8.8.8.8', '1.1.1.1']);
  } catch {
    // Ignore in restricted environments
  }
}

export const connectDatabase = async (customUri?: string): Promise<typeof mongoose> => {
  const uri = customUri || env.mongodbUri;

  try {
    mongoose.set('strictQuery', true);
    const connection = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 5000,
    });
    logger.info(`[MongoDB] Connected successfully to ${connection.connection.host}/${connection.connection.name}`);
    return connection;
  } catch (error) {
    logger.error(`[MongoDB] Connection error: ${(error as Error).message}`);
    throw error;
  }
};

export const disconnectDatabase = async (): Promise<void> => {
  try {
    await mongoose.disconnect();
    logger.info('[MongoDB] Disconnected successfully');
  } catch (error) {
    logger.error(`[MongoDB] Disconnection error: ${(error as Error).message}`);
    throw error;
  }
};
