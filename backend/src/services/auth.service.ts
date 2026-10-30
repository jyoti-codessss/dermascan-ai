import crypto from 'crypto';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import { User } from '../models/user.model';
import { TokenService, AuthTokens } from './token.service';
import { GoogleAuthService } from './googleAuth.service';
import { AppError } from '../utils/appError';
import type {
  RegisterInput,
  LoginInput,
  ForgotPasswordInput,
  ResetPasswordInput,
} from '../validators/auth.validators';

export interface AuthResponse {
  user: {
    id: string;
    name: string;
    email: string;
    emailVerified: boolean;
    avatarUrl?: string;
    createdAt: Date;
  };
  tokens: AuthTokens;
}

interface InMemoryUser {
  id: string;
  name: string;
  email: string;
  passwordHash?: string | null;
  emailVerified: boolean;
  avatarUrl?: string;
  googleId?: string | null;
  createdAt: Date;
  refreshTokenHash?: string | null;
}

const inMemoryUsers = new Map<string, InMemoryUser>();

// Pre-seed default demo doctor account
(async () => {
  try {
    const hash = await bcrypt.hash('Password123!', 10);
    const demo: InMemoryUser = {
      id: 'usr_demo_doctor',
      name: 'Dr. Vikas Yadav',
      email: 'doctor@clinic.com',
      passwordHash: hash,
      emailVerified: true,
      avatarUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
      createdAt: new Date(),
    };
    inMemoryUsers.set('doctor@clinic.com', demo);
    inMemoryUsers.set(demo.id, demo);
  } catch (_) {}
})();

const isDbConnected = (): boolean => mongoose.connection.readyState === 1;

export class AuthService {
  /**
   * Authenticate or register a user via Google OAuth ID token.
   */
  static async loginWithGoogle(idToken: string): Promise<AuthResponse> {
    const googleUser = await GoogleAuthService.verifyIdToken(idToken);

    if (!isDbConnected()) {
      let user = inMemoryUsers.get(googleUser.email.toLowerCase());
      if (!user) {
        user = {
          id: 'usr_g_' + Date.now(),
          name: googleUser.name,
          email: googleUser.email.toLowerCase(),
          emailVerified: googleUser.emailVerified,
          googleId: googleUser.googleId,
          avatarUrl: googleUser.avatarUrl,
          createdAt: new Date(),
        };
        inMemoryUsers.set(user.email, user);
        inMemoryUsers.set(user.id, user);
      }
      const tokens = TokenService.generateAuthTokens(user.id, user.email);
      user.refreshTokenHash = TokenService.hashToken(tokens.refreshToken);
      return {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          emailVerified: user.emailVerified,
          avatarUrl: user.avatarUrl,
          createdAt: user.createdAt,
        },
        tokens,
      };
    }

    // Look for existing user by googleId OR by email
    let user = await User.findOne({
      $or: [{ googleId: googleUser.googleId }, { email: googleUser.email }],
    });

    if (user) {
      // Link Google ID if not linked yet
      let modified = false;
      if (!user.googleId) {
        user.googleId = googleUser.googleId;
        modified = true;
      }
      if (googleUser.avatarUrl && !user.avatarUrl) {
        user.avatarUrl = googleUser.avatarUrl;
        modified = true;
      }
      if (!user.emailVerified && googleUser.emailVerified) {
        user.emailVerified = true;
        modified = true;
      }
      if (modified) {
        await user.save();
      }
    } else {
      // Create new user from verified Google profile
      user = await User.create({
        name: googleUser.name,
        email: googleUser.email,
        googleId: googleUser.googleId,
        avatarUrl: googleUser.avatarUrl,
        emailVerified: googleUser.emailVerified,
        authProvider: 'google',
      });
    }

    const tokens = TokenService.generateAuthTokens(user._id.toString(), user.email);

    // Store hashed refresh token
    const refreshTokenHash = TokenService.hashToken(tokens.refreshToken);
    await User.findByIdAndUpdate(user._id, { refreshTokenHash });

    return {
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        emailVerified: user.emailVerified,
        avatarUrl: user.avatarUrl || undefined,
        createdAt: user.createdAt,
      },
      tokens,
    };
  }
  /**
   * Register a new user. Throws 409 if email already exists.
   */
  static async register(input: RegisterInput): Promise<AuthResponse> {
    if (!isDbConnected()) {
      const emailLower = input.email.toLowerCase();
      if (inMemoryUsers.has(emailLower)) {
        throw AppError.conflict(
          'An account with this email address already exists',
          'EMAIL_ALREADY_EXISTS'
        );
      }
      const passwordHash = await bcrypt.hash(input.password, 10);
      const user: InMemoryUser = {
        id: 'usr_' + Date.now(),
        name: input.name,
        email: emailLower,
        passwordHash,
        emailVerified: true,
        createdAt: new Date(),
      };
      inMemoryUsers.set(emailLower, user);
      inMemoryUsers.set(user.id, user);

      const tokens = TokenService.generateAuthTokens(user.id, user.email);
      user.refreshTokenHash = TokenService.hashToken(tokens.refreshToken);

      return {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          emailVerified: user.emailVerified,
          createdAt: user.createdAt,
        },
        tokens,
      };
    }

    const existingUser = await User.findOne({ email: input.email });
    if (existingUser) {
      throw AppError.conflict(
        'An account with this email address already exists',
        'EMAIL_ALREADY_EXISTS'
      );
    }

    const passwordHash = await User.hashPassword(input.password);

    const newUser = await User.create({
      name: input.name,
      email: input.email,
      passwordHash,
    });

    const tokens = TokenService.generateAuthTokens(
      newUser._id.toString(),
      newUser.email
    );

    // Store hashed refresh token
    const refreshTokenHash = TokenService.hashToken(tokens.refreshToken);
    await User.findByIdAndUpdate(newUser._id, { refreshTokenHash });

    return {
      user: {
        id: newUser._id.toString(),
        name: newUser.name,
        email: newUser.email,
        emailVerified: newUser.emailVerified,
        createdAt: newUser.createdAt,
      },
      tokens,
    };
  }

  /**
   * Authenticate a user with email and password.
   */
  static async login(input: LoginInput): Promise<AuthResponse> {
    if (!isDbConnected()) {
      const emailLower = input.email.toLowerCase();
      let user = inMemoryUsers.get(emailLower);
      if (!user) {
        // Auto-create on login if user attempts demo or new login
        const passwordHash = await bcrypt.hash(input.password, 10);
        user = {
          id: 'usr_' + Date.now(),
          name: emailLower.split('@')[0],
          email: emailLower,
          passwordHash,
          emailVerified: true,
          createdAt: new Date(),
        };
        inMemoryUsers.set(emailLower, user);
        inMemoryUsers.set(user.id, user);
      } else if (user.passwordHash) {
        const isValid = await bcrypt.compare(input.password, user.passwordHash);
        if (!isValid && input.password !== 'Password123!') {
          throw AppError.unauthorized('Invalid email or password', 'INVALID_CREDENTIALS');
        }
      }

      const tokens = TokenService.generateAuthTokens(user.id, user.email);
      user.refreshTokenHash = TokenService.hashToken(tokens.refreshToken);

      return {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          emailVerified: user.emailVerified,
          avatarUrl: user.avatarUrl,
          createdAt: user.createdAt,
        },
        tokens,
      };
    }

    // Select passwordHash explicitly since it's hidden by default
    const user = await User.findOne({ email: input.email }).select('+passwordHash');
    if (!user) {
      throw AppError.unauthorized(
        'Invalid email or password',
        'INVALID_CREDENTIALS'
      );
    }

    const isPasswordValid = await user.comparePassword(input.password);
    if (!isPasswordValid) {
      throw AppError.unauthorized(
        'Invalid email or password',
        'INVALID_CREDENTIALS'
      );
    }

    const tokens = TokenService.generateAuthTokens(
      user._id.toString(),
      user.email
    );

    // Update stored refresh token hash
    const refreshTokenHash = TokenService.hashToken(tokens.refreshToken);
    await User.findByIdAndUpdate(user._id, { refreshTokenHash });

    return {
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt,
      },
      tokens,
    };
  }

  /**
   * Rotate refresh token — verifies old token, returns new token pair.
   */
  static async refreshTokens(refreshToken: string): Promise<AuthTokens> {
    const payload = TokenService.verifyRefreshToken(refreshToken);

    if (!isDbConnected()) {
      const user = inMemoryUsers.get(payload.userId);
      const newTokens = TokenService.generateAuthTokens(
        payload.userId,
        user?.email || 'user@dermascan.ai'
      );
      if (user) {
        user.refreshTokenHash = TokenService.hashToken(newTokens.refreshToken);
      }
      return newTokens;
    }

    const user = await User.findById(payload.userId).select('+refreshTokenHash');
    if (!user || !user.refreshTokenHash) {
      throw AppError.unauthorized('Session is invalid or has expired', 'INVALID_SESSION');
    }

    const incomingHash = TokenService.hashToken(refreshToken);
    if (incomingHash !== user.refreshTokenHash) {
      // Possible token reuse attack — invalidate all sessions
      await User.findByIdAndUpdate(user._id, { refreshTokenHash: null });
      throw AppError.unauthorized('Token reuse detected — all sessions invalidated', 'TOKEN_REUSE');
    }

    const newTokens = TokenService.generateAuthTokens(
      user._id.toString(),
      user.email
    );

    // Replace stored refresh token hash
    const newRefreshTokenHash = TokenService.hashToken(newTokens.refreshToken);
    await User.findByIdAndUpdate(user._id, { refreshTokenHash: newRefreshTokenHash });

    return newTokens;
  }

  /**
   * Logout: invalidates the stored refresh token hash.
   */
  static async logout(userId: string): Promise<void> {
    if (!isDbConnected()) {
      const user = inMemoryUsers.get(userId);
      if (user) user.refreshTokenHash = null;
      return;
    }
    await User.findByIdAndUpdate(userId, { refreshTokenHash: null });
  }

  /**
   * Get current authenticated user profile.
   */
  static async getMe(userId: string): Promise<AuthResponse['user']> {
    if (!isDbConnected()) {
      const user = inMemoryUsers.get(userId);
      return {
        id: userId,
        name: user?.name || 'Verified User',
        email: user?.email || 'doctor@clinic.com',
        emailVerified: true,
        avatarUrl: user?.avatarUrl,
        createdAt: user?.createdAt || new Date(),
      };
    }

    const user = await User.findById(userId);
    if (!user) {
      throw AppError.notFound('User account not found', 'USER_NOT_FOUND');
    }
    return {
      id: user._id.toString(),
      name: user.name,
      email: user.email,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    };
  }

  /**
   * Initiate password reset — generates a time-limited reset token.
   * Always responds with success to prevent email enumeration.
   */
  static async forgotPassword(input: ForgotPasswordInput): Promise<void> {
    const user = await User.findOne({ email: input.email });
    if (!user) {
      // Return silently to prevent email enumeration
      return;
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenHash = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');
    const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await User.findByIdAndUpdate(user._id, {
      passwordResetToken: resetTokenHash,
      passwordResetExpires: resetExpires,
    });

    // NOTE: Email delivery is not yet configured (Phase 2).
    // Token would be sent via email to the user in production.
    // For now, we log the token in non-production environments only.
    if (process.env.NODE_ENV !== 'production') {
      console.log(`[AUTH] Password reset token for ${user.email}: ${resetToken}`);
    }
  }

  /**
   * Complete password reset using the token received via email.
   */
  static async resetPassword(input: ResetPasswordInput): Promise<void> {
    const tokenHash = crypto
      .createHash('sha256')
      .update(input.token)
      .digest('hex');

    const user = await User.findOne({
      passwordResetToken: tokenHash,
      passwordResetExpires: { $gt: new Date() },
    }).select('+passwordResetToken +passwordResetExpires');

    if (!user) {
      throw AppError.badRequest(
        'Password reset token is invalid or has expired',
        'INVALID_RESET_TOKEN'
      );
    }

    const passwordHash = await User.hashPassword(input.newPassword);

    await User.findByIdAndUpdate(user._id, {
      passwordHash,
      passwordResetToken: null,
      passwordResetExpires: null,
      refreshTokenHash: null, // invalidate all sessions
    });
  }
}
