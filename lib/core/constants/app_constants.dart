/// Global application constants.
abstract final class AppConstants {
  static const String appName = 'DermaScan AI';
  static const String appTagline = 'Detect. Understand. Connect to Care.';
  static const String appVersion = '1.0.0';

  // Medical Disclaimer texts (required across result and analysis views)
  static const String medicalDisclaimerShort =
      'AI-generated information · Not a medical diagnosis.';

  static const String medicalDisclaimerFull =
      'AI-generated preliminary classification is for informational and educational purposes only. '
      'It does not constitute a definitive diagnosis or medical prescription and must not replace '
      'evaluation by a qualified healthcare professional. If you experience severe, rapidly changing, '
      'bleeding, or painful skin conditions, seek immediate medical attention.';

  static const String imageQualityGuidance =
      'For best results, ensure the photo is well-lit, clearly in focus, and centered on the affected skin area without filters.';
}
