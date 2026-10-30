import multer from 'multer';
import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/appError';
import { env } from '../config/environment';

// Configure in-memory storage for high-performance direct processing
const storage = multer.memoryStorage();

const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];

const upload = multer({
  storage,
  limits: {
    fileSize: env.uploadMaxSizeBytes, // 25MB
    files: 1,
  },
  fileFilter: (_req, file, cb) => {
    if (allowedMimeTypes.includes(file.mimetype.toLowerCase())) {
      cb(null, true);
    } else {
      cb(
        AppError.badRequest(
          `Invalid file type '${file.mimetype}'. Only JPEG, PNG, and WebP images are supported.`,
          'INVALID_IMAGE_TYPE'
        )
      );
    }
  },
}).single('image');

export const handleImageUpload = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  upload(req, res, (err: unknown) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return next(
            AppError.badRequest(
              `Uploaded image exceeds the 25MB size limit.`,
              'FILE_TOO_LARGE'
            )
          );
        }
        return next(AppError.badRequest(err.message, 'UPLOAD_ERROR'));
      }
      return next(err);
    }

    if (!req.file && (!req.body || !req.body.imageBase64)) {
      return next(
        AppError.badRequest(
          'Please provide an image file (multipart field "image") or a base64 encoded image string.',
          'NO_IMAGE_PROVIDED'
        )
      );
    }

    next();
  });
};
