import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { env } from '../config/environment';
import { AppError } from '../utils/appError';

export interface TokenPayload {
  userId: string;
  email: string;
}

export interface RefreshTokenPayload {
  userId: string;
  tokenId: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: string;
}

export class TokenService {
  /**
   * Generates both access token and refresh token for a user.
   */
  static generateAuthTokens(userId: string, email: string): AuthTokens {
    const tokenId = crypto.randomBytes(32).toString('hex');

    const accessToken = jwt.sign(
      { userId, email },
      env.jwtSecret,
      { expiresIn: env.jwtExpiresIn as jwt.SignOptions['expiresIn'] }
    );

    const refreshToken = jwt.sign(
      { userId, tokenId },
      env.jwtRefreshSecret,
      { expiresIn: env.jwtRefreshExpiresIn as jwt.SignOptions['expiresIn'] }
    );

    return {
      accessToken,
      refreshToken,
      expiresIn: env.jwtExpiresIn,
    };
  }

  /**
   * Verifies an access token and returns payload.
   */
  static verifyAccessToken(token: string): TokenPayload {
    try {
      return jwt.verify(token, env.jwtSecret) as TokenPayload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw AppError.unauthorized('Access token has expired', 'TOKEN_EXPIRED');
      }
      throw AppError.unauthorized('Invalid access token', 'INVALID_TOKEN');
    }
  }

  /**
   * Verifies a refresh token and returns payload.
   */
  static verifyRefreshToken(token: string): RefreshTokenPayload {
    try {
      return jwt.verify(token, env.jwtRefreshSecret) as RefreshTokenPayload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw AppError.unauthorized('Refresh token has expired', 'REFRESH_TOKEN_EXPIRED');
      }
      throw AppError.unauthorized('Invalid refresh token', 'INVALID_REFRESH_TOKEN');
    }
  }

  /**
   * Securely hashes a refresh token for database storage.
   */
  static hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }
}
