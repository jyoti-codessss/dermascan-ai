import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/features/auth/domain/auth_state.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Screen for viewing and managing Personal Info, Demographics & Skin Profile.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;

  String _selectedGender = 'Not Specified';
  String _selectedSkinType = 'Type III (Medium / Olive tone)';
  String _selectedConcern = 'General Monitoring';
  bool _isSaving = false;

  final List<String> _genders = [
    'Not Specified',
    'Female',
    'Male',
    'Non-Binary',
    'Prefer not to say',
  ];

  final List<Map<String, String>> _skinTypes = [
    {
      'type': 'Type I',
      'label': 'Type I (Very Fair / Always Burns)',
      'desc': 'Ivory white, highly sensitive, never tans',
      'color': '0xFFFFE0BD',
    },
    {
      'type': 'Type II',
      'label': 'Type II (Fair / Usually Burns)',
      'desc': 'Fair skin, burns easily, tans minimally',
      'color': '0xFFFFD1A4',
    },
    {
      'type': 'Type III',
      'label': 'Type III (Medium / Olive tone)',
      'desc': 'Light brown/olive, burns moderately, tans gradually',
      'color': '0xFFE0AC69',
    },
    {
      'type': 'Type IV',
      'label': 'Type IV (Moderate Brown)',
      'desc': 'Olive/brown skin, rarely burns, tans easily',
      'color': '0xFFC68642',
    },
    {
      'type': 'Type V',
      'label': 'Type V (Dark Brown)',
      'desc': 'Dark brown skin, very rarely burns, tans deeply',
      'color': '0xFF8D5524',
    },
    {
      'type': 'Type VI',
      'label': 'Type VI (Deeply Pigmented)',
      'desc': 'Deep dark brown/black, never burns',
      'color': '0xFF3B2219',
    },
  ];

  final List<String> _skinConcerns = [
    'General Monitoring',
    'Acne & Breakouts',
    'Hyperpigmentation',
    'Eczema & Dermatitis',
    'Psoriasis & Scalp',
    'Suspicious Moles & Lesions',
    'Anti-Aging & Sun Damage',
    'Rosacea & Redness',
    'Skin Barrier Repair',
  ];

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _ageController =
        TextEditingController(text: user?.age != null ? user!.age.toString() : '');
    _selectedGender = user?.gender ?? 'Not Specified';
    _selectedSkinType =
        user?.skinType ?? 'Type III (Medium / Olive tone)';
    _selectedConcern = user?.primaryConcern ?? 'General Monitoring';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final ageVal = int.tryParse(_ageController.text.trim());

    final success =
        await ref.read(authNotifierProvider.notifier).updateUserProfile(
              displayName: _nameController.text.trim(),
              phoneNumber: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              gender: _selectedGender,
              skinType: _selectedSkinType,
              age: ageVal,
              primaryConcern: _selectedConcern,
            );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Personal Info updated successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;
    final userEmail = user?.email ?? 'user@dermascan.ai';
    final createdAtStr = user != null
        ? DateFormat('MMMM dd, yyyy').format(user.createdAt)
        : 'Active';

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surfaceGlass,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: tokens.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal Info',
          style: AppTypography.h3.copyWith(
            color: tokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.stitchBlue),
                  )
                : const Icon(Icons.check, color: AppColors.stitchBlue, size: 18),
            label: Text(
              'Save',
              style: TextStyle(
                color: _isSaving ? Colors.grey : AppColors.stitchBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══ 1. AVATAR & IDENTITY HEADER ═══
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(_nameController.text),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: tokens.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: tokens.borderGlass, width: 2),
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: AppColors.stitchBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userEmail,
                        style: AppTypography.bodySmall.copyWith(
                          color: tokens.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.greenAccent, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Verified Patient Account',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ═══ 2. BASIC ACCOUNT DETAILS ═══
                _buildSectionHeader('Account Information'),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: tokens.borderGlass),
                  ),
                  child: Column(
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: tokens.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                          prefixIcon: Icon(Icons.person_outline, color: tokens.primary),
                          filled: true,
                          fillColor: tokens.surfaceVariant.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Email (Read Only with lock)
                      TextFormField(
                        initialValue: userEmail,
                        readOnly: true,
                        style: TextStyle(color: tokens.onSurface.withValues(alpha: 0.7)),
                        decoration: InputDecoration(
                          labelText: 'Email Address (Locked)',
                          labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                          prefixIcon: Icon(Icons.email_outlined, color: tokens.primary),
                          suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                          filled: true,
                          fillColor: tokens.surfaceVariant.withValues(alpha: 0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: tokens.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          hintText: '+91 98765 43210',
                          hintStyle: TextStyle(color: tokens.onSurfaceVariant.withValues(alpha: 0.5)),
                          labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                          prefixIcon: Icon(Icons.phone_outlined, color: tokens.primary),
                          filled: true,
                          fillColor: tokens.surfaceVariant.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ═══ 3. CLINICAL DEMOGRAPHICS ═══
                _buildSectionHeader('Clinical Demographics'),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: tokens.borderGlass),
                  ),
                  child: Column(
                    children: [
                      // Age & Gender Row
                      Row(
                        children: [
                          // Age Field
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: tokens.onSurface),
                              decoration: InputDecoration(
                                labelText: 'Age (Years)',
                                labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                                prefixIcon: Icon(Icons.cake_outlined, color: tokens.primary),
                                filled: true,
                                fillColor: tokens.surfaceVariant.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: tokens.borderGlass),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: tokens.borderGlass),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Gender Dropdown
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _genders.contains(_selectedGender)
                                  ? _selectedGender
                                  : _genders.first,
                              dropdownColor: tokens.surface,
                              style: TextStyle(color: tokens.onSurface, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                                prefixIcon: Icon(Icons.wc_outlined, color: tokens.primary),
                                filled: true,
                                fillColor: tokens.surfaceVariant.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: tokens.borderGlass),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: tokens.borderGlass),
                                ),
                              ),
                              items: _genders.map((g) {
                                return DropdownMenuItem(
                                  value: g,
                                  child: Text(g, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedGender = v);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Fitzpatrick Skin Type Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _skinTypes.any((st) => st['label'] == _selectedSkinType)
                            ? _selectedSkinType
                            : _skinTypes[2]['label'],
                        dropdownColor: tokens.surface,
                        isExpanded: true,
                        style: TextStyle(color: tokens.onSurface, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Fitzpatrick Skin Phototype',
                          labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                          prefixIcon: Icon(Icons.palette_outlined, color: tokens.primary),
                          filled: true,
                          fillColor: tokens.surfaceVariant.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                        ),
                        items: _skinTypes.map((st) {
                          final colorHex = int.parse(st['color']!);
                          return DropdownMenuItem(
                            value: st['label'],
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Color(colorHex),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    st['label']!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedSkinType = v);
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Primary Skin Concern
                      DropdownButtonFormField<String>(
                        initialValue: _skinConcerns.contains(_selectedConcern)
                            ? _selectedConcern
                            : _skinConcerns.first,
                        dropdownColor: tokens.surface,
                        isExpanded: true,
                        style: TextStyle(color: tokens.onSurface, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Primary Skin Concern',
                          labelStyle: TextStyle(color: tokens.onSurfaceVariant),
                          prefixIcon: Icon(Icons.health_and_safety_outlined, color: tokens.primary),
                          filled: true,
                          fillColor: tokens.surfaceVariant.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: tokens.borderGlass),
                          ),
                        ),
                        items: _skinConcerns.map((sc) {
                          return DropdownMenuItem(
                            value: sc,
                            child: Text(sc, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedConcern = v);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ═══ 4. ACCOUNT METADATA CARD ═══
                _buildSectionHeader('Security & Metadata'),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: tokens.borderGlass),
                  ),
                  child: Column(
                    children: [
                      _buildMetaRow(
                        tokens,
                        icon: Icons.fingerprint,
                        label: 'Patient ID',
                        value: user != null && user.id.length > 12
                            ? '${user.id.substring(0, 8)}...${user.id.substring(user.id.length - 4)}'
                            : (user?.id ?? 'DS-77492'),
                        onCopy: user != null ? () => _copyToClipboard(user.id) : null,
                      ),
                      Divider(color: tokens.borderGlass, height: 20),
                      _buildMetaRow(
                        tokens,
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: createdAtStr,
                      ),
                      Divider(color: tokens.borderGlass, height: 20),
                      _buildMetaRow(
                        tokens,
                        icon: Icons.lock_outline,
                        label: 'Encryption Standard',
                        value: 'AES-256 (HIPAA Compliant)',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ═══ 5. SAVE BUTTON ═══
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stitchBlue,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                      elevation: 4,
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(
                      _isSaving ? 'Saving Changes...' : 'Save Profile Changes',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    AppThemeTokens tokens, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: tokens.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: tokens.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(Icons.copy, size: 15, color: tokens.primary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Patient ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
