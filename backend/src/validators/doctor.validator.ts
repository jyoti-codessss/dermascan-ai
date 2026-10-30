import { z } from 'zod';

export const getNearbyDoctorsSchema = z.object({
  lat: z.coerce
    .number({ invalid_type_error: 'Latitude must be a valid number' })
    .min(-90, 'Latitude must be between -90 and 90')
    .max(90, 'Latitude must be between -90 and 90'),
  lng: z.coerce
    .number({ invalid_type_error: 'Longitude must be a valid number' })
    .min(-180, 'Longitude must be between -180 and 180')
    .max(180, 'Longitude must be between -180 and 180'),
  radiusKm: z.coerce
    .number({ invalid_type_error: 'Radius must be a number' })
    .min(1, 'Radius must be at least 1 km')
    .max(200, 'Radius cannot exceed 200 km')
    .default(25),
  specialty: z.string().optional(),
  minRating: z.coerce.number().min(0).max(5).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const matchDoctorAiSchema = z.object({
  condition: z.string().min(1, 'Condition diagnosis is required'),
  confidence: z.number().min(0).max(1).default(0.85),
  severity: z.enum(['low', 'medium', 'high', 'critical']).optional(),
  userLat: z.number().min(-90).max(90),
  userLng: z.number().min(-180).max(180),
  radiusKm: z.number().min(1).max(200).default(35),
});

export type GetNearbyDoctorsInput = z.infer<typeof getNearbyDoctorsSchema>;
export type MatchDoctorAiInput = z.infer<typeof matchDoctorAiSchema>;
