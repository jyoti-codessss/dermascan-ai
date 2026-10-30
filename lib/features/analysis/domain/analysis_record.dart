import 'package:flutter/foundation.dart';

/// Represents a real skin lesion analysis record.
@immutable
class AnalysisRecord {
  final String id;
  final DateTime scannedAt;
  final String imagePath;
  final String conditionName;
  final int confidencePercent;
  final String summary;
  final String riskLevel;
  final bool lowConfidence;
  final String modelVersion;

  const AnalysisRecord({
    required this.id,
    required this.scannedAt,
    required this.imagePath,
    required this.conditionName,
    required this.confidencePercent,
    required this.summary,
    this.riskLevel = 'Low',
    this.lowConfidence = false,
    this.modelVersion = 'HAM10000-ResNet50-v2.3.0',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'scannedAt': scannedAt.toIso8601String(),
        'imagePath': imagePath,
        'conditionName': conditionName,
        'confidencePercent': confidencePercent,
        'summary': summary,
        'riskLevel': riskLevel,
        'lowConfidence': lowConfidence,
        'modelVersion': modelVersion,
      };

  factory AnalysisRecord.fromJson(Map<String, dynamic> json) => AnalysisRecord(
        id: json['id'] as String? ?? 'scan_${DateTime.now().millisecondsSinceEpoch}',
        scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? '') ?? DateTime.now(),
        imagePath: json['imagePath'] as String? ?? '',
        conditionName: json['conditionName'] as String? ?? 'Skin Lesion',
        confidencePercent: (json['confidencePercent'] as num?)?.toInt() ?? 80,
        summary: json['summary'] as String? ?? '',
        riskLevel: json['riskLevel'] as String? ?? 'Low',
        lowConfidence: json['lowConfidence'] as bool? ?? false,
        modelVersion: json['modelVersion'] as String? ?? 'HAM10000-ResNet50-v2.3.0',
      );
}
