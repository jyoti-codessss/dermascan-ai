import { Request, Response, NextFunction } from 'express';
import { searchNearbyProviders } from '../services/places.service';
import { searchNearbyDoctorsPostgres } from '../services/doctor-postgres.service';
import { runDoctorMatchingAgent } from '../services/doctor-agent.service';
import {
  getNearbyDoctorsSchema,
  matchDoctorAiSchema,
} from '../validators/doctor.validator';
import { AppError } from '../utils/appError';

const sendSuccess = (res: Response, data: unknown, statusCode = 200) => {
  res.status(statusCode).json({ success: true, data });
};

/**
 * GET /api/v1/nearby/doctors
 * Queries Supabase PostGIS spatial DB; dynamically fetches from OSM Overpass & caches into Supabase if 0 results found.
 */
export const getNearbyDoctors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const parseResult = getNearbyDoctorsSchema.safeParse(req.query);
    if (!parseResult.success) {
      const err = parseResult.error.errors.map((e) => e.message).join(', ');
      throw AppError.badRequest(`Validation error: ${err}`, 'VALIDATION_ERROR');
    }

    const { doctors, total } = await searchNearbyDoctorsPostgres(parseResult.data);

    sendSuccess(res, {
      doctors,
      total,
      lat: parseResult.data.lat,
      lng: parseResult.data.lng,
      radiusKm: parseResult.data.radiusKm,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/v1/nearby/doctors/ai-match
 * Dispatches the AI Clinical Triage & Doctor Matching Agent.
 */
export const matchDoctorWithAi = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const parseResult = matchDoctorAiSchema.safeParse(req.body);
    if (!parseResult.success) {
      const err = parseResult.error.errors.map((e) => e.message).join(', ');
      throw AppError.badRequest(`Validation error: ${err}`, 'VALIDATION_ERROR');
    }

    const triageResult = await runDoctorMatchingAgent(parseResult.data);
    sendSuccess(res, triageResult, 200);
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/v1/nearby/dermatologists (Legacy Photon OpenStreetMap)
 */
export const getNearbyDermatologists = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const lat = parseFloat(req.query.lat as string);
    const lng = parseFloat(req.query.lng as string);
    const radius = req.query.radius ? parseInt(req.query.radius as string, 10) : 10000;

    if (isNaN(lat) || isNaN(lng)) {
      throw AppError.badRequest('Query parameters "lat" and "lng" must be valid numbers.', 'INVALID_COORDINATES');
    }

    const providers = await searchNearbyProviders(lat, lng, 'dermatologist', radius);
    sendSuccess(res, { providers, count: providers.length, lat, lng });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/v1/nearby/hospitals (Legacy Photon OpenStreetMap)
 */
export const getNearbyHospitals = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const lat = parseFloat(req.query.lat as string);
    const lng = parseFloat(req.query.lng as string);
    const radius = req.query.radius ? parseInt(req.query.radius as string, 10) : 10000;

    if (isNaN(lat) || isNaN(lng)) {
      throw AppError.badRequest('Query parameters "lat" and "lng" must be valid numbers.', 'INVALID_COORDINATES');
    }

    const providers = await searchNearbyProviders(lat, lng, 'hospital', radius);
    sendSuccess(res, { providers, count: providers.length, lat, lng });
  } catch (err) {
    next(err);
  }
};
