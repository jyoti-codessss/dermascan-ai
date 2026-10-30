import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { env } from '../config/environment';
import { validate } from '../middleware/validate.middleware';
import { authenticateToken } from '../middleware/auth.middleware';
import {
  RegisterSchema,
  LoginSchema,
  RefreshTokenSchema,
  ForgotPasswordSchema,
  ResetPasswordSchema,
  GoogleAuthSchema,
} from '../validators/auth.validators';
import {
  registerController,
  loginController,
  refreshController,
  logoutController,
  getMeController,
  forgotPasswordController,
  resetPasswordController,
  googleAuthController,
} from '../controllers/auth.controller';

const router = Router();

// Strict rate limit on auth write endpoints
const authRateLimit = rateLimit({
  windowMs: env.rateLimitWindowMs,
  max: env.authRateLimitMaxRequests,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many authentication attempts. Please try again later.',
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// POST /api/v1/auth/register
router.post('/register', authRateLimit, validate(RegisterSchema), registerController);

// POST /api/v1/auth/login
router.post('/login', authRateLimit, validate(LoginSchema), loginController);

// POST /api/v1/auth/google
router.post('/google', authRateLimit, validate(GoogleAuthSchema), googleAuthController);

// POST /api/v1/auth/refresh
router.post('/refresh', validate(RefreshTokenSchema), refreshController);

// POST /api/v1/auth/logout — requires valid access token
router.post('/logout', authenticateToken, logoutController);

// GET /api/v1/auth/me — returns authenticated user profile
router.get('/me', authenticateToken, getMeController);

// POST /api/v1/auth/forgot-password
router.post('/forgot-password', authRateLimit, validate(ForgotPasswordSchema), forgotPasswordController);

// POST /api/v1/auth/reset-password
router.post('/reset-password', authRateLimit, validate(ResetPasswordSchema), resetPasswordController);

export default router;
