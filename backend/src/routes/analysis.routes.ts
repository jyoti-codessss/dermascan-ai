import { Router } from 'express';
import { authenticateToken } from '../middleware/auth.middleware';
import { handleImageUpload } from '../middleware/upload.middleware';
import {
  createAnalysisController,
  getAnalysesController,
  getAnalysisByIdController,
  deleteAnalysisController,
} from '../controllers/analysis.controller';

const router = Router();

// All analysis endpoints require an authenticated user session
router.use(authenticateToken);

// POST /api/v1/analyses — Upload image and run real HAM10000 inference
router.post('/', handleImageUpload, createAnalysisController);

// GET /api/v1/analyses — Get paginated real analysis history
router.get('/', getAnalysesController);

// GET /api/v1/analyses/:id — Get specific analysis result
router.get('/:id', getAnalysisByIdController);

// DELETE /api/v1/analyses/:id — Delete specific analysis result
router.delete('/:id', deleteAnalysisController);

export default router;
