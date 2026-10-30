import { Router } from 'express';
import { chatController } from '../controllers/chat.controller';

const router = Router();

// POST /api/v1/chat
router.post('/', chatController);

export default router;
