import { MatchDoctorAiInput } from '../validators/doctor.validator';
import { searchNearbyDoctorsPostgres, DoctorResult } from './doctor-postgres.service';

export interface DoctorRecommendation {
  doctor: DoctorResult;
  matchScore: number; // 0 - 100
  clinicalReasoning: string;
  recommendedAction: string;
}

export interface AiTriageResult {
  triageLevel: 'ROUTINE' | 'PRIORITY' | 'URGENT';
  targetSpecialty: string;
  clinicalUrgencyNote: string;
  topDoctorRecommendation: DoctorRecommendation | null;
  alternativeDoctors: DoctorRecommendation[];
  scanContext: {
    condition: string;
    confidence: number;
    severity: string;
  };
}

/**
 * Autonomous AI Agent that triages skin scan findings, determines clinical urgency,
 * queries the PostGIS database via spatial tools, and generates personalized doctor referrals.
 */
export async function runDoctorMatchingAgent(
  input: MatchDoctorAiInput
): Promise<AiTriageResult> {
  const { condition, confidence, userLat, userLng, radiusKm } = input;
  const condLower = condition.toLowerCase();

  // ─── Step 1: Agent Planner & Triage Evaluation ────────────────────────────
  let triageLevel: 'ROUTINE' | 'PRIORITY' | 'URGENT' = 'ROUTINE';
  let targetSpecialty = 'General Dermatology';
  let clinicalUrgencyNote = '';

  if (
    condLower.includes('melanoma') ||
    condLower.includes('carcinoma') ||
    condLower.includes('malignan') ||
    condLower.includes('neoplasm')
  ) {
    triageLevel = 'URGENT';
    targetSpecialty = 'Mohs Micrographic Surgery';
    clinicalUrgencyNote =
      'High clinical suspicion of neoplastic skin lesion. Prompt dermoscopic evaluation and surgical margin consultation recommended within 7–14 days.';
  } else if (
    condLower.includes('eczema') ||
    condLower.includes('psoriasis') ||
    condLower.includes('dermatitis') ||
    condLower.includes('lichen')
  ) {
    triageLevel = 'PRIORITY';
    targetSpecialty = 'General Dermatology';
    clinicalUrgencyNote =
      'Active inflammatory dermatosis identified. Consultation recommended for topical corticosteroid or systemic biologic treatment regimen.';
  } else if (
    condLower.includes('pediatric') ||
    condLower.includes('child') ||
    condLower.includes('infant') ||
    condLower.includes('hemangioma')
  ) {
    triageLevel = 'PRIORITY';
    targetSpecialty = 'Pediatric Dermatology';
    clinicalUrgencyNote =
      'Pediatric presentation requires specialized pediatric dermatologic care with child-safe dosage and formulation protocols.';
  } else if (condLower.includes('scar') || condLower.includes('pigment') || condLower.includes('acne')) {
    triageLevel = 'ROUTINE';
    targetSpecialty = 'Cosmetic Dermatology';
    clinicalUrgencyNote =
      'Non-malignant dermatologic condition. Elective outpatient consultation for barrier repair, laser, or aesthetic intervention.';
  } else {
    triageLevel = confidence > 0.8 ? 'PRIORITY' : 'ROUTINE';
    targetSpecialty = 'General Dermatology';
    clinicalUrgencyNote =
      'Standard clinical evaluation recommended to confirm initial computer vision scan findings and perform tactile assessment.';
  }

  // ─── Step 2: Agent Tool Call — Spatial PostGIS Database Query ──────────────
  const { doctors } = await searchNearbyDoctorsPostgres({
    lat: userLat,
    lng: userLng,
    radiusKm: radiusKm || 35,
    page: 1,
    limit: 10,
  });

  // ─── Step 3: Agent Reasoning & Clinical Match Synthesis ───────────────────
  const recommendations: DoctorRecommendation[] = doctors.map((doc) => {
    let score = 70; // baseline
    const isExactSpecialty = doc.specialty.toLowerCase().includes(targetSpecialty.toLowerCase());
    const hasMatchingSubSpecialty = doc.subSpecialties.some((sub) =>
      condLower.includes(sub.toLowerCase()) || sub.toLowerCase().includes(condLower)
    );

    if (isExactSpecialty) score += 18;
    if (hasMatchingSubSpecialty) score += 12;
    if (doc.rating && doc.rating >= 4.8) score += 5;
    if (doc.isAvailableToday) score += 5;
    if (doc.distanceKm < 5.0) score += 5;

    score = Math.min(99, Math.max(65, score));

    // Generate clinical reasoning text
    let clinicalReasoning = '';
    if (isExactSpecialty) {
      clinicalReasoning = `${doc.fullName} is a premier specialist in ${doc.specialty} at ${doc.clinicName}, perfectly aligned with the identified ${condition}.`;
    } else {
      clinicalReasoning = `Experienced dermatologist with broad diagnostic capabilities located ${doc.distanceKm} km from your current location.`;
    }

    const recommendedAction = doc.isAvailableToday
      ? `Available today (${doc.nextAvailableSlot}). Same-day appointment recommended.`
      : `Next available appointment: ${doc.nextAvailableSlot}. Schedule a clinic visit.`;

    return {
      doctor: doc,
      matchScore: score,
      clinicalReasoning,
      recommendedAction,
    };
  });

  // Sort by match score descending
  recommendations.sort((a, b) => b.matchScore - a.matchScore);

  const topDoctorRecommendation = recommendations.length > 0 ? recommendations[0] : null;
  const alternativeDoctors = recommendations.slice(1, 4);

  return {
    triageLevel,
    targetSpecialty,
    clinicalUrgencyNote,
    topDoctorRecommendation,
    alternativeDoctors,
    scanContext: {
      condition,
      confidence,
      severity: input.severity || triageLevel.toLowerCase(),
    },
  };
}
