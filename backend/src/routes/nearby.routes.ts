import { Router } from 'express';
import {
  getNearbyDoctors,
  matchDoctorWithAi,
  getNearbyDermatologists,
  getNearbyHospitals,
} from '../controllers/nearby.controller';

const router = Router();

// ─── Phase 3.5: PostgreSQL + PostGIS & AI Agent Endpoints ────────────────────

// GET /api/v1/nearby/doctors?lat=...&lng=...&radiusKm=...&specialty=...
router.get('/doctors', getNearbyDoctors);

// POST /api/v1/nearby/doctors/ai-match
// Body: { condition: "Melanoma", confidence: 0.92, userLat: 28.6, userLng: 77.2 }
router.post('/doctors/ai-match', matchDoctorWithAi);

// ─── OpenStreetMap Photon Endpoints ──────────────────────────────────────────
router.get('/dermatologists', getNearbyDermatologists);
router.get('/hospitals', getNearbyHospitals);

export default router;
