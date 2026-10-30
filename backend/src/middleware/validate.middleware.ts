import { Request, Response, NextFunction, RequestHandler } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { AppError } from '../utils/appError';

type ValidationTarget = 'body' | 'query' | 'params';

/**
 * Middleware factory that validates the request against a Zod schema.
 * Attaches the parsed (and coerced) data back to the request target.
 */
export const validate = (
  schema: ZodSchema,
  target: ValidationTarget = 'body'
): RequestHandler => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[target]);
    if (!result.success) {
      const details = (result.error as ZodError).errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      return next(
        AppError.badRequest('Request validation failed', 'VALIDATION_ERROR', details)
      );
    }
    // Replace the raw input with the parsed, coerced values
    (req as unknown as Record<string, unknown>)[target] = result.data;
    next();
  };
};
