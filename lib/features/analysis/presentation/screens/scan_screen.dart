import 'dart:io';
import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/core/services/skin_analysis_service.dart';
import 'package:dermascan_ai/features/analysis/domain/analysis_record.dart';
import 'package:dermascan_ai/features/analysis/presentation/providers/analysis_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  SkinAnalysisResult? _result;
  String? _errorMessage;
  SkinScanModelType _selectedModelType = SkinScanModelType.lesion;

  /// Prompts model selection dialog before scanning / image picking
  Future<void> _showModelSelectionDialog({required ImageSource source}) async {
    final selected = await showModalBottomSheet<SkinScanModelType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Condition Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose the AI model tailored for your skin concern',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                // Option 1: Mole / Lesion (HAM10000 7 classes)
                _buildModelOptionTile(
                  context: ctx,
                  type: SkinScanModelType.lesion,
                  title: 'Mole / Lesion',
                  badge: '7 Classes',
                  subtitle: 'Pigmented spots, Melanoma, Nevi, and suspicious mole screening',
                  icon: Icons.lens_blur_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  isSelected: _selectedModelType == SkinScanModelType.lesion,
                  isDark: isDark,
                  onTap: () => Navigator.of(ctx).pop(SkinScanModelType.lesion),
                ),
                const SizedBox(height: 12),

                // Option 2: Rash / Eczema / Psoriasis (DermNet 23 classes)
                _buildModelOptionTile(
                  context: ctx,
                  type: SkinScanModelType.commonCondition,
                  title: 'Rash / Eczema / Psoriasis',
                  badge: '23 Classes',
                  subtitle: 'Eczema, Psoriasis, Acne, Fungal infection, Hives, and general rashes',
                  icon: Icons.healing_rounded,
                  iconColor: const Color(0xFF10B981),
                  isSelected: _selectedModelType == SkinScanModelType.commonCondition,
                  isDark: isDark,
                  onTap: () => Navigator.of(ctx).pop(SkinScanModelType.commonCondition),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedModelType = selected;
      });
      await _pickImage(source);
    }
  }

  Widget _buildModelOptionTile({
    required BuildContext context,
    required SkinScanModelType type,
    required String title,
    required String badge,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0F2B48) : const Color(0xFFF0F9FF))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 92,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
          _errorMessage = null;
        });
        await _runAnalysis();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image: $e';
      });
    }
  }

  Future<void> _runAnalysis() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final res = await SkinAnalysisService.instance.analyzeImage(
        _selectedImage!,
        modelType: _selectedModelType,
      );

      final record = AnalysisRecord(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        scannedAt: DateTime.now(),
        imagePath: _selectedImage!.path,
        conditionName: res.conditionName,
        confidencePercent: res.confidencePercent,
        summary: res.summary,
        riskLevel: res.riskLevel,
        modelVersion: _selectedModelType == SkinScanModelType.lesion
            ? 'HAM10000-ResNet50-v2.3.0'
            : 'DermNet-23-Classes-v1.0.0',
      );

      // Save to real Riverpod analysis history & local storage
      ref.read(analysisHistoryProvider.notifier).addRecord(record);

      setState(() {
        _result = res;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis error: $e';
        _isAnalyzing = false;
      });
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Red
      case 'moderate':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Skin Disease Scanner',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Prominent Medical Disclaimer ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is for informational purposes only. Please consult a dermatologist for an accurate diagnosis.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Model Selector Tabs ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedModelType != SkinScanModelType.lesion) {
                          setState(() {
                            _selectedModelType = SkinScanModelType.lesion;
                            if (_selectedImage != null) {
                              _runAnalysis();
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedModelType == SkinScanModelType.lesion
                              ? const Color(0xFF0284C7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Mole / Lesion',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _selectedModelType == SkinScanModelType.lesion
                                ? Colors.white
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedModelType != SkinScanModelType.commonCondition) {
                          setState(() {
                            _selectedModelType = SkinScanModelType.commonCondition;
                            if (_selectedImage != null) {
                              _runAnalysis();
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: _selectedModelType == SkinScanModelType.commonCondition
                              ? const Color(0xFF0284C7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Rash / Eczema / Psoriasis',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _selectedModelType == SkinScanModelType.commonCondition
                                ? Colors.white
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Image Viewfinder / Preview Card ───────────────────────────
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No Image Selected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Capture skin area or select from gallery',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                  // Scanning Animated Overlay
                  if (_isAnalyzing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Analyzing with ${_selectedModelType.title}...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedModelType == SkinScanModelType.lesion
                                ? 'Evaluating 7 HAM10000 lesion classes'
                                : 'Evaluating 23 DermNet common condition classes',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Action Buttons: Camera & Gallery with Model Dialog ────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () => _showModelSelectionDialog(source: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () => _showModelSelectionDialog(source: ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 20),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Error Message ───────────────────────────────────────────
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ─── Analysis Results Card ────────────────────────────────────
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Badge & Model Tag
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _result!.modelType.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRiskColor(_result!.riskLevel).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getRiskColor(_result!.riskLevel),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_result!.riskLevel} Risk',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _getRiskColor(_result!.riskLevel),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Primary Disease Condition & Confidence
                    Text(
                      _result!.conditionName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_result!.conditionName} - ${_result!.confidencePercent}% Confidence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getRiskColor(_result!.riskLevel),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _result!.confidence,
                        minHeight: 8,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRiskColor(_result!.riskLevel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Summary
                    Text(
                      _result!.summary,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),

                    if (_result!.alternatives.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'Differential Diagnoses',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._result!.alternatives.map((alt) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alt.conditionName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRiskColor(alt.riskLevel).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${alt.confidencePercent}% (${alt.riskLevel})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getRiskColor(alt.riskLevel),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],

                    const SizedBox(height: 20),

                    // AI Chatbot Helper Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E1B4B), const Color(0xFF1E293B)]
                              : [const Color(0xFFF5F3FF), const Color(0xFFEFF6FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF6C5DD3).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5DD3).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF6C5DD3),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ask AI Dermatologist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5DD3).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Gemini AI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6C5DD3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Confused or have questions? Get instant medical guidance and care tips for ${_result!.conditionName}.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Quick prompt chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildChatChip(
                                label: 'What is this?',
                                query: 'Explain what ${_result!.conditionName} is in simple terms, its causes and symptoms.',
                                isDark: isDark,
                              ),
                              _buildChatChip(
                                label: 'Home remedies & care',
                                query: 'What are safe home care tips and precautions for ${_result!.conditionName}?',
                                isDark: isDark,
                              ),
                              _buildChatChip(
                                label: 'Is it dangerous?',
                                query: 'Is ${_result!.conditionName} dangerous? When should I immediately visit a doctor?',
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final query = 'I scanned my skin concern and the AI analysis returned:\n'
                                    '- Condition: ${_result!.conditionName}\n'
                                    '- Confidence: ${_result!.confidencePercent}%\n'
                                    '- Risk Level: ${_result!.riskLevel}\n'
                                    '- Details: ${_result!.summary}\n\n'
                                    'Please explain this condition to me, whether I should worry, home care tips, and what doctor visits are suggested.';
                                context.push(RoutePaths.chat, extra: query);
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: const Text('Chat with AI About This Result'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5DD3),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Find Nearby Dermatologist Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(RoutePaths.nearbyCare),
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: const Text('Find Nearby Dermatologist'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatChip({
    required String label,
    required String query,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => context.push(RoutePaths.chat, extra: query),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline_rounded, size: 13, color: Color(0xFF6C5DD3)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
