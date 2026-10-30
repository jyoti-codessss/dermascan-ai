import mongoose, { Document, Model, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser {
  name: string;
  email: string;
  passwordHash?: string | null;
  emailVerified: boolean;
  googleId?: string | null;
  avatarUrl?: string | null;
  authProvider: 'local' | 'google';
  refreshTokenHash?: string | null;
  passwordResetToken?: string | null;
  passwordResetExpires?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface IUserDocument extends IUser, Document {
  comparePassword(candidatePassword: string): Promise<boolean>;
}

export interface IUserModel extends Model<IUserDocument> {
  hashPassword(password: string): Promise<string>;
}

const UserSchema = new Schema<IUserDocument, IUserModel>(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [2, 'Name must be at least 2 characters long'],
      maxlength: [100, 'Name cannot exceed 100 characters'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Please enter a valid email address'],
      index: true,
    },
    passwordHash: {
      type: String,
      default: null,
      select: false,
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
    googleId: {
      type: String,
      default: null,
      sparse: true,
      index: true,
    },
    avatarUrl: {
      type: String,
      default: null,
      trim: true,
    },
    authProvider: {
      type: String,
      enum: ['local', 'google'],
      default: 'local',
    },
    refreshTokenHash: {
      type: String,
      default: null,
      select: false,
    },
    passwordResetToken: {
      type: String,
      default: null,
      select: false,
    },
    passwordResetExpires: {
      type: Date,
      default: null,
      select: false,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_, ret: Record<string, unknown>) => {
        delete ret['passwordHash'];
        delete ret['refreshTokenHash'];
        delete ret['passwordResetToken'];
        delete ret['passwordResetExpires'];
        delete ret['__v'];
        return ret;
      },
    },
  }
);

// Method to verify passwords
UserSchema.methods.comparePassword = async function (candidatePassword: string): Promise<boolean> {
  if (!this.passwordHash) {
    return false;
  }
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

// Static helper to hash passwords
UserSchema.statics.hashPassword = async function (password: string): Promise<string> {
  const salt = await bcrypt.genSalt(12);
  return bcrypt.hash(password, salt);
};

export const User = mongoose.model<IUserDocument, IUserModel>('User', UserSchema);
