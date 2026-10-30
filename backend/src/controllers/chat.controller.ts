import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { generateChatResponse } from '../services/gemini.service';
import { AppError } from '../utils/appError';

const chatRequestSchema = z.object({
  message: z.string({ required_error: 'Message is required' }).trim().min(1, 'Message cannot be empty'),
  history: z
    .array(
      z.object({
        role: z.enum(['user', 'model', 'assistant']),
        parts: z.any().optional(),
        text: z.string().optional(),
        content: z.string().optional(),
        message: z.string().optional(),
      }).passthrough()
    )
    .optional(),
});

const sendSuccess = (res: Response, data: unknown, statusCode = 200) => {
  res.status(statusCode).json({ success: true, data });
};

/**
 * Controller for handling AI Chat conversations with Gemini 2.5 Flash.
 * POST /api/v1/chat
 */
export const chatController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const parseResult = chatRequestSchema.safeParse(req.body);
    if (!parseResult.success) {
      const errorMsg = parseResult.error.errors.map((e) => e.message).join(', ');
      throw AppError.badRequest(errorMsg, 'INVALID_CHAT_REQUEST');
    }

    const { message, history } = parseResult.data;
    const aiResponse = await generateChatResponse(message, history);

    sendSuccess(res, {
      response: aiResponse,
      timestamp: new Date().toISOString(),
      model: 'gemini-2.5-flash',
    });
  } catch (error: any) {
    if (error instanceof AppError) {
      next(error);
    } else {
      next(
        new AppError(
          error.message || 'Failed to process AI chat message',
          500,
          'GEMINI_CHAT_ERROR'
        )
      );
    }
  }
};
