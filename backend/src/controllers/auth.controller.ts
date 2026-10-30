import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import type {
  RegisterInput,
  LoginInput,
  RefreshTokenInput,
  ForgotPasswordInput,
  ResetPasswordInput,
  GoogleAuthInput,
} from '../validators/auth.validators';

const sendSuccess = (res: Response, data: unknown, statusCode = 200) => {
  res.status(statusCode).json({ success: true, data });
};

export const googleAuthController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const input = req.body as GoogleAuthInput;
    const result = await AuthService.loginWithGoogle(input.idToken);
    sendSuccess(res, result);
  } catch (error) {
    next(error);
  }
};

export const registerController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const input = req.body as RegisterInput;
    const result = await AuthService.register(input);
    sendSuccess(res, result, 201);
  } catch (error) {
    next(error);
  }
};

export const loginController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const input = req.body as LoginInput;
    const result = await AuthService.login(input);
    sendSuccess(res, result);
  } catch (error) {
    next(error);
  }
};

export const refreshController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const input = req.body as RefreshTokenInput;
    const tokens = await AuthService.refreshTokens(input.refreshToken);
    sendSuccess(res, { tokens });
  } catch (error) {
    next(error);
  }
};

export const logoutController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    await AuthService.logout(req.user!.userId);
    sendSuccess(res, { message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
};

export const getMeController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const user = await AuthService.getMe(req.user!.userId);
    sendSuccess(res, { user });
  } catch (error) {
    next(error);
  }
};

export const forgotPasswordController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const input = req.body as ForgotPasswordInput;
    await AuthService.forgotPassword(input);
    // Always respond with 200 to prevent email enumeration
    sendSuccess(res, {
      message: 'If an account with that email exists, a reset link has been sent',
    });
  } catch (error) {
    next(error);
  }
};

export const resetPasswordController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const input = req.body as ResetPasswordInput;
    await AuthService.resetPassword(input);
    sendSuccess(res, { message: 'Password has been reset successfully' });
  } catch (error) {
    next(error);
  }
};
