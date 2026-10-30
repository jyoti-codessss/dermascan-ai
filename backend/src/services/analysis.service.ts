import { Types } from 'mongoose';
import { Analysis, IAnalysisDocument } from '../models/analysis.model';
import { InferenceService, InferenceResult } from './inference.service';
import { AppError } from '../utils/appError';

export interface PaginatedAnalyses {
  analyses: IAnalysisDocument[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export class AnalysisService {
  /**
   * Processes an uploaded image buffer, performs real HAM10000 inference,
   * and persists the real analysis document in MongoDB Atlas associated with the user.
   */
  static async createAnalysis(
    userId: string,
    imageBuffer: Buffer,
    mimeType = 'image/jpeg',
    fileName = 'scan_image.jpg'
  ): Promise<{ analysis: IAnalysisDocument; inference: InferenceResult }> {
    if (!Types.ObjectId.isValid(userId)) {
      throw AppError.badRequest('Invalid user identifier', 'INVALID_USER_ID');
    }

    // 1. Run Real HAM10000 ML Inference
    const inference = await InferenceService.analyzeImage(imageBuffer, mimeType, fileName);

    // 2. Generate optimized base64 data URI for instant client rendering
    const maxThumbnailBytes = 1024 * 100; // 100KB thumbnail
    let imageUrl: string | null = null;
    if (imageBuffer.length <= maxThumbnailBytes) {
      imageUrl = `data:${mimeType};base64,${imageBuffer.toString('base64')}`;
    } else {
      // In production Phase 4, presigned S3 URL will be stored
      imageUrl = `data:${mimeType};base64,${imageBuffer.subarray(0, 1024 * 64).toString('base64')}`;
    }

    // 3. Persist Analysis Record in MongoDB Atlas
    const analysis = await Analysis.create({
      userId: new Types.ObjectId(userId),
      imageUrl,
      imageFileName: fileName,
      imageSizeBytes: imageBuffer.length,
      imageMimeType: mimeType,
      modelVersion: inference.modelVersion,
      predictedClass: inference.predictedClass,
      conditionName: inference.conditionName,
      confidence: inference.confidence,
      lowConfidence: inference.lowConfidence,
      riskLevel: inference.riskLevel,
      probabilities: inference.probabilities,
      summary: inference.summary,
      clinicalRecommendations: inference.clinicalRecommendations,
      dimensions: inference.dimensions,
      imageMetrics: inference.imageMetrics,
    });

    return { analysis, inference };
  }

  /**
   * Retrieves paginated real analysis history for an authenticated user.
   */
  static async getUserAnalyses(
    userId: string,
    page = 1,
    limit = 10
  ): Promise<PaginatedAnalyses> {
    if (!Types.ObjectId.isValid(userId)) {
      throw AppError.badRequest('Invalid user identifier', 'INVALID_USER_ID');
    }

    const safePage = Math.max(1, page);
    const safeLimit = Math.min(50, Math.max(1, limit));
    const skip = (safePage - 1) * safeLimit;

    const [analyses, total] = await Promise.all([
      Analysis.find({ userId: new Types.ObjectId(userId) })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(safeLimit),
      Analysis.countDocuments({ userId: new Types.ObjectId(userId) }),
    ]);

    return {
      analyses,
      total,
      page: safePage,
      limit: safeLimit,
      totalPages: Math.ceil(total / safeLimit),
    };
  }

  /**
   * Retrieves a specific analysis by ID, ensuring user ownership.
   */
  static async getAnalysisById(
    userId: string,
    analysisId: string
  ): Promise<IAnalysisDocument> {
    if (!Types.ObjectId.isValid(analysisId)) {
      throw AppError.badRequest('Invalid analysis identifier', 'INVALID_ANALYSIS_ID');
    }

    const analysis = await Analysis.findOne({
      _id: new Types.ObjectId(analysisId),
      userId: new Types.ObjectId(userId),
    });

    if (!analysis) {
      throw AppError.notFound('Analysis record not found', 'ANALYSIS_NOT_FOUND');
    }

    return analysis;
  }

  /**
   * Deletes a specific analysis by ID, ensuring user ownership.
   */
  static async deleteAnalysis(userId: string, analysisId: string): Promise<void> {
    if (!Types.ObjectId.isValid(analysisId)) {
      throw AppError.badRequest('Invalid analysis identifier', 'INVALID_ANALYSIS_ID');
    }

    const result = await Analysis.deleteOne({
      _id: new Types.ObjectId(analysisId),
      userId: new Types.ObjectId(userId),
    });

    if (result.deletedCount === 0) {
      throw AppError.notFound('Analysis record not found or already deleted', 'ANALYSIS_NOT_FOUND');
    }
  }
}
