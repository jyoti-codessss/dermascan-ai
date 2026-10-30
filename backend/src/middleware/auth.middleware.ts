import { Request, Response, NextFunction } from 'express';
import { TokenService } from '../services/token.service';
import { User } from '../models/user.model';
import { AppError } from '../utils/appError';

// Extend Express Request to include authenticated user
declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: string;
        email: string;
      };
    }
  }
}

export const authenticateToken = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw AppError.unauthorized('Authorization header missing or invalid format', 'NO_TOKEN');
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      throw AppError.unauthorized('Bearer token is empty', 'NO_TOKEN');
    }

    const payload = TokenService.verifyAccessToken(token);

    // Verify user still exists in DB
    const user = await User.findById(payload.userId).select('_id email');
    if (!user) {
      throw AppError.unauthorized('The user belonging to this token no longer exists', 'USER_NOT_FOUND');
    }

    req.user = { userId: payload.userId, email: payload.email };
    next();
  } catch (error) {
    next(error);
  }
};
