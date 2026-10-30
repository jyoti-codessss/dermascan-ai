import { Request, Response, NextFunction } from 'express';
import { AnalysisService } from '../services/analysis.service';
import { AppError } from '../utils/appError';

const sendSuccess = (res: Response, data: unknown, statusCode = 200) => {
  res.status(statusCode).json({ success: true, data });
};

export const createAnalysisController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    let imageBuffer: Buffer;
    let mimeType = 'image/jpeg';
    let fileName = 'scan.jpg';

    if (req.file) {
      imageBuffer = req.file.buffer;
      mimeType = req.file.mimetype;
      fileName = req.file.originalname || fileName;
    } else if (req.body && req.body.imageBase64) {
      // Decode Base64 string
      const rawBase64 = req.body.imageBase64 as string;
      const matches = rawBase64.match(/^data:([A-Za-z-+/]+);base64,(.+)$/);
      if (matches && matches.length === 3) {
        mimeType = matches[1];
        imageBuffer = Buffer.from(matches[2], 'base64');
      } else {
        imageBuffer = Buffer.from(rawBase64, 'base64');
      }
      if (req.body.fileName) fileName = req.body.fileName;
    } else {
      throw AppError.badRequest('No image data provided', 'NO_IMAGE_PROVIDED');
    }

    const result = await AnalysisService.createAnalysis(userId, imageBuffer, mimeType, fileName);
    sendSuccess(res, result, 201);
  } catch (error) {
    next(error);
  }
};

export const getAnalysesController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const page = parseInt(req.query.page as string || '1', 10);
    const limit = parseInt(req.query.limit as string || '10', 10);

    const result = await AnalysisService.getUserAnalyses(userId, page, limit);
    sendSuccess(res, result);
  } catch (error) {
    next(error);
  }
};

export const getAnalysisByIdController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const analysisId = String(req.params.id);

    const analysis = await AnalysisService.getAnalysisById(userId, analysisId);
    sendSuccess(res, { analysis });
  } catch (error) {
    next(error);
  }
};

export const deleteAnalysisController = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const analysisId = String(req.params.id);

    await AnalysisService.deleteAnalysis(userId, analysisId);
    sendSuccess(res, { message: 'Analysis record deleted successfully' });
  } catch (error) {
    next(error);
  }
};
