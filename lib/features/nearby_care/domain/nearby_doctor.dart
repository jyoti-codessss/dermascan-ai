class NearbyDoctor {
  final String id;
  final String fullName;
  final String specialty;
  final List<String> subSpecialties;
  final String clinicName;
  final String address;
  final String phone;
  final String? website;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final String profileImageUrl;
  final String bio;
  final bool isAvailableToday;
  final String nextAvailableSlot;

  const NearbyDoctor({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.subSpecialties,
    required this.clinicName,
    required this.address,
    required this.phone,
    this.website,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.profileImageUrl,
    required this.bio,
    required this.isAvailableToday,
    required this.nextAvailableSlot,
  });

  factory NearbyDoctor.fromJson(Map<String, dynamic> json) {
    // Helper parsers to prevent String -> num cast crashes
    double parseDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? defaultVal;
    }

    int parseInt(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? defaultVal;
    }

    return NearbyDoctor(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ??
          json['name']?.toString() ??
          'Specialist Doctor',
      specialty: json['specialty']?.toString() ?? 'Dermatology',
      subSpecialties: (json['subSpecialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      clinicName: json['clinicName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      website: json['website']?.toString(),
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng']),
      distanceKm: parseDouble(json['distanceKm']),
      rating: parseDouble(json['rating'], 4.8),
      reviewCount: parseInt(json['reviewCount'], 100),
      experienceYears: parseInt(json['experienceYears'], 10),
      consultationFee: parseDouble(json['consultationFee'], 800.0),
      profileImageUrl: json['profileImageUrl']?.toString() ??
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300',
      bio: json['bio']?.toString() ?? '',
      isAvailableToday: json['isAvailableToday'] as bool? ?? true,
      nextAvailableSlot: json['nextAvailableSlot']?.toString() ?? 'Today',
    );
  }
}

class DoctorRecommendation {
  final NearbyDoctor doctor;
  final int matchScore;
  final String clinicalReasoning;
  final String recommendedAction;

  const DoctorRecommendation({
    required this.doctor,
    required this.matchScore,
    required this.clinicalReasoning,
    required this.recommendedAction,
  });

  factory DoctorRecommendation.fromJson(Map<String, dynamic> json) {
    return DoctorRecommendation(
      doctor: NearbyDoctor.fromJson(json['doctor'] as Map<String, dynamic>),
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 80,
      clinicalReasoning: json['clinicalReasoning']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? '',
    );
  }
}

class AiDoctorTriageResult {
  final String triageLevel;
  final String targetSpecialty;
  final String clinicalUrgencyNote;
  final DoctorRecommendation? topDoctorRecommendation;
  final List<DoctorRecommendation> alternativeDoctors;

  const AiDoctorTriageResult({
    required this.triageLevel,
    required this.targetSpecialty,
    required this.clinicalUrgencyNote,
    this.topDoctorRecommendation,
    this.alternativeDoctors = const [],
  });

  factory AiDoctorTriageResult.fromJson(Map<String, dynamic> json) {
    return AiDoctorTriageResult(
      triageLevel: json['triageLevel']?.toString() ?? 'ROUTINE',
      targetSpecialty: json['targetSpecialty']?.toString() ?? 'General Dermatology',
      clinicalUrgencyNote: json['clinicalUrgencyNote']?.toString() ?? '',
      topDoctorRecommendation: json['topDoctorRecommendation'] != null
          ? DoctorRecommendation.fromJson(
              json['topDoctorRecommendation'] as Map<String, dynamic>)
          : null,
      alternativeDoctors: (json['alternativeDoctors'] as List<dynamic>?)
              ?.map((e) =>
                  DoctorRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
