typedef PlaceResult = NearbyProvider;

class NearbyProvider {
  final String id;
  final String placeId;
  final String name;
  final String type; // 'doctor' | 'dermatologist' | 'hospital' | 'clinic'
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final bool? openNow;
  final String? phoneNumber;
  final String? website;
  final double distanceKm;

  const NearbyProvider({
    this.id = '',
    this.placeId = '',
    required this.name,
    this.type = 'doctor',
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.rating,
    this.userRatingsTotal,
    this.openNow,
    this.phoneNumber,
    this.website,
    required this.distanceKm,
  });

  bool get isDermatologist => type == 'dermatologist';
  bool get isHospital => type == 'hospital';
  bool get isDoctor => type == 'doctor' || type == 'dermatologist';
  bool get isClinic => type == 'clinic';

  factory NearbyProvider.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? defaultVal;
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    return NearbyProvider(
      id: json['id']?.toString() ?? json['placeId']?.toString() ?? '',
      placeId: json['placeId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Specialist Provider',
      type: (json['type']?.toString() ?? json['category']?.toString() ?? 'doctor').toLowerCase(),
      address: json['address']?.toString() ?? '',
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng']),
      rating: json['rating'] != null ? parseDouble(json['rating'], 4.5) : null,
      userRatingsTotal: parseInt(json['userRatingsTotal'] ?? json['reviewCount']),
      openNow: json['openNow'] as bool?,
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString(),
      website: json['website']?.toString(),
      distanceKm: parseDouble(json['distanceKm']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'name': name,
      'type': type,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'openNow': openNow,
      'phoneNumber': phoneNumber,
      'website': website,
      'distanceKm': distanceKm,
    };
  }
}
