import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/features/nearby_care/domain/nearby_doctor.dart';
import 'package:dermascan_ai/features/nearby_care/presentation/providers/nearby_care_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rock-solid, high-performance Nearby Care & Specialist Doctors Screen
class NearbyCareScreen extends ConsumerStatefulWidget {
  const NearbyCareScreen({super.key});

  @override
  ConsumerState<NearbyCareScreen> createState() => _NearbyCareScreenState();
}

class _NearbyCareScreenState extends ConsumerState<NearbyCareScreen> {
  final MapController _mapController = MapController();
  bool _isListView = false;
  bool _mapReady = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _safeMoveMap(double lat, double lng, [double zoom = 13.5]) {
    if (!_mapReady) return;
    try {
      _mapController.move(LatLng(lat, lng), zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Listen for coordinate changes to smoothly pan the map
    ref.listen<NearbyCareState>(nearbyCareNotifierProvider, (prev, next) {
      if (prev?.latitude != next.latitude || prev?.longitude != next.longitude) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _mapReady) {
            _safeMoveMap(next.latitude, next.longitude);
          }
        });
      }
    });

    final state = ref.watch(nearbyCareNotifierProvider);
    final notifier = ref.read(nearbyCareNotifierProvider.notifier);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ═══ 1. HEADER & CONTROLS ═══
          _buildHeader(topPad, state, notifier),

          // ═══ 2. MAP OR LIST VIEW (EXPANDED STABLE BOUNDARY) ═══
          Expanded(
            child: _isListView
                ? _buildListView(state, notifier)
                : _buildMap(state, notifier),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────
  Widget _buildHeader(double topPad, NearbyCareState state, NearbyCareNotifier notifier) {
    final dermCount = state.allProviders.where((p) => p.isDermatologist).length;
    final hospCount = state.allProviders.where((p) => p.isHospital).length;
    final docCount = state.nearbyDoctors.isNotEmpty
        ? state.nearbyDoctors.length
        : state.allProviders.where((p) => p.isDoctor || p.isDermatologist).length;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(top: topPad + 4, left: 12, right: 12, bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Location name + AI Match CTA + View Toggle
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.stitchBlue, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.areaName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // AI Doctor Match Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAiTriageModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.isAiMatching)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        const Text(
                          'AI Match',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _iconBtn(
                _isListView ? Icons.map_rounded : Icons.format_list_bulleted_rounded,
                () => setState(() => _isListView = !_isListView),
              ),
              const SizedBox(width: 4),
              _iconBtn(
                Icons.my_location_rounded,
                () {
                  notifier.locateAndFetch();
                  _safeMoveMap(state.latitude, state.longitude, 14.5);
                },
                color: AppColors.stitchBlue,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Quick city selector chips
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('🎯 Live GPS', state.areaName.contains('GPS') || state.areaName.contains('Live'),
                    () => notifier.locateAndFetch()),
                _chip('Mumbai', state.areaName.contains('Mumbai'),
                    () => notifier.fetchForLocation(19.0760, 72.8777, areaName: 'Mumbai')),
                _chip('Palghar / Thane', state.areaName.contains('Palghar') || state.areaName.contains('Thane'),
                    () => notifier.fetchForLocation(19.4200, 72.8300, areaName: 'Palghar & Thane')),
                _chip('Delhi NCR', state.areaName.contains('Delhi'),
                    () => notifier.fetchForLocation(28.6139, 77.2090, areaName: 'Delhi NCR')),
                _chip('Bengaluru', state.areaName.contains('Bengaluru'),
                    () => notifier.fetchForLocation(12.9716, 77.5946, areaName: 'Bengaluru')),
                _chip('Pune', state.areaName.contains('Pune'),
                    () => notifier.fetchForLocation(18.5204, 73.8567, areaName: 'Pune')),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Category filter pills
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterPill('All Care (${state.allProviders.length})',
                    state.activeFilter == NearbyCategoryFilter.all,
                    () => notifier.setFilter(NearbyCategoryFilter.all)),
                const SizedBox(width: 6),
                _filterPill('🩺 Derma ($dermCount)',
                    state.activeFilter == NearbyCategoryFilter.dermatologists,
                    () => notifier.setFilter(NearbyCategoryFilter.dermatologists)),
                const SizedBox(width: 6),
                _filterPill('👨‍⚕️ Doctors ($docCount)',
                    state.activeFilter == NearbyCategoryFilter.doctors,
                    () => notifier.setFilter(NearbyCategoryFilter.doctors)),
                const SizedBox(width: 6),
                _filterPill('🏥 Hospitals ($hospCount)',
                    state.activeFilter == NearbyCategoryFilter.hospitals,
                    () => notifier.setFilter(NearbyCategoryFilter.hospitals)),
              ],
            ),
          ),

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: IgnorePointer(
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.stitchBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── ROCK-SOLID MAP WITH OVERLAY BOTTOM CARD ─────────────────────────────
  Widget _buildMap(NearbyCareState state, NearbyCareNotifier notifier) {
    final currentCenter = LatLng(
      state.latitude != 0.0 ? state.latitude : 19.4200,
      state.longitude != 0.0 ? state.longitude : 72.8300,
    );

    final hasSelection = state.selectedDoctor != null || state.selectedProvider != null;

    return Stack(
      children: [
        // 1. ISOLATED REPAINT BOUNDARY FOR FLUTTER MAP
        Positioned.fill(
          child: RepaintBoundary(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentCenter,
                initialZoom: 13.5,
                minZoom: 3.0,
                maxZoom: 19.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onMapReady: () {
                  _mapReady = true;
                  _safeMoveMap(state.latitude, state.longitude, 13.5);
                },
              ),
              children: [
                // Fast CartoDB Voyager tiles with OSM fallback
                TileLayer(
                  urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dermascan.ai.dermascan_ai',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: _buildMarkers(state, notifier)),
              ],
            ),
          ),
        ),

        // 2. Verified Count Badge (Top Left)
        Positioned(
          top: 10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 14),
                const SizedBox(width: 5),
                Text(
                  '${state.filteredProviders.length} Medical Centers',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // 3. Floating GPS FAB (Bottom Right)
        Positioned(
          right: 14,
          bottom: hasSelection ? 168 : 16,
          child: SizedBox(
            width: 44,
            height: 44,
            child: FloatingActionButton(
              heroTag: 'nearby_gps_fab',
              onPressed: () {
                notifier.locateAndFetch();
                _safeMoveMap(state.latitude, state.longitude, 14.5);
              },
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: AppColors.stitchBlue,
              elevation: 4,
              shape: CircleBorder(
                side: BorderSide(color: AppColors.stitchBlue.withValues(alpha: 0.8), width: 1.5),
              ),
              child: const Icon(Icons.my_location_rounded, size: 22),
            ),
          ),
        ),

        // 4. FLOATING BOTTOM CARD (OVERLAY - DOES NOT RESIZE MAP)
        if (hasSelection)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildBottomCard(state),
          ),
      ],
    );
  }

  List<Marker> _buildMarkers(NearbyCareState state, NearbyCareNotifier notifier) {
    final markers = <Marker>[];

    // User GPS Location Dot
    if (state.latitude != 0.0 && state.longitude != 0.0) {
      markers.add(
        Marker(
          key: const ValueKey('user_gps_pin'),
          point: LatLng(state.latitude, state.longitude),
          width: 44,
          height: 44,
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final providers = state.filteredProviders;
    for (final p in providers) {
      final isSelected = state.selectedProvider?.id == p.id;
      final isDerm = p.isDermatologist;

      markers.add(
        Marker(
          key: ValueKey(p.id),
          point: LatLng(p.latitude, p.longitude),
          width: 38,
          height: 38,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              notifier.selectProvider(p);
              _safeMoveMap(p.latitude, p.longitude, 15.0);
            },
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDerm
                        ? [const Color(0xFF0284C7), const Color(0xFF0EA5E9)]
                        : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amberAccent : Colors.white,
                    width: isSelected ? 3.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected
                              ? Colors.amberAccent
                              : (isDerm ? const Color(0xFF0284C7) : const Color(0xFFDC2626)))
                          .withValues(alpha: isSelected ? 0.9 : 0.4),
                      blurRadius: isSelected ? 12 : 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDerm ? Icons.medical_services_rounded : Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ─── FLOATING BOTTOM CARD ────────────────────────────────────────────────
  Widget _buildBottomCard(NearbyCareState state) {
    final doc = state.selectedDoctor;
    final p = state.selectedProvider;

    final name = doc?.fullName ?? p?.name ?? 'Provider';
    final address = doc?.address ?? p?.address ?? '';
    final distance = doc?.distanceKm ?? p?.distanceKm ?? 0.0;
    final rating = doc?.rating ?? p?.rating;
    final phone = doc?.phone ?? p?.phoneNumber;
    final specialty = doc?.specialty ?? (p?.isDermatologist == true ? 'Dermatology & Skin Care' : 'Multispeciality Hospital');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: AppRadius.md,
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (doc != null)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1E293B),
                  backgroundImage: NetworkImage(doc.profileImageUrl),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: const Icon(Icons.person, size: 16, color: Colors.white70),
                )
              else
                Icon(
                  p?.isDermatologist == true ? Icons.medical_services_rounded : Icons.local_hospital_rounded,
                  color: p?.isDermatologist == true ? AppColors.stitchBlue : Colors.redAccent,
                  size: 22,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(color: AppColors.stitchBlue, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '${distance.toStringAsFixed(1)} km',
                style: const TextStyle(color: AppColors.stitchBlue, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => ref.read(nearbyCareNotifierProvider.notifier).clearSelection(),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, color: Colors.white70, size: 16),
                ),
              ),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(address, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (rating != null) ...[
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 3),
                Text(
                  '${rating.toStringAsFixed(1)} ★',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
              ],
              if (doc != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    '₹${doc.consultationFee.toInt()}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () => _launchCall(phone),
                  icon: const Icon(Icons.call, size: 13),
                  label: const Text('Call', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () => _launchDirections(
                    doc?.latitude ?? p?.latitude ?? 0.0,
                    doc?.longitude ?? p?.longitude ?? 0.0,
                  ),
                  icon: const Icon(Icons.directions, size: 13),
                  label: const Text('Navigate', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.stitchBlue,
                    foregroundColor: AppColors.onStitchBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── LIST VIEW ───────────────────────────────────────────────────────────
  Widget _buildListView(NearbyCareState state, NearbyCareNotifier notifier) {
    if (state.allProviders.isEmpty && state.nearbyDoctors.isEmpty) {
      return Center(
        child: Text(
          state.isLoading ? 'Finding nearby medical providers...' : 'No providers found nearby.',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.filteredProviders.length,
      itemBuilder: (context, index) {
        final p = state.filteredProviders[index];
        final isSelected = state.selectedProvider?.id == p.id;

        return Card(
          color: isSelected ? const Color(0xFF1E293B) : AppColors.surface,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md,
            side: BorderSide(
              color: isSelected ? AppColors.stitchBlue : AppColors.border,
            ),
          ),
          child: ListTile(
            leading: Icon(
              p.isDermatologist ? Icons.medical_services_rounded : Icons.local_hospital_rounded,
              color: p.isDermatologist ? AppColors.stitchBlue : Colors.redAccent,
            ),
            title: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text('${p.address}\n${p.distanceKm.toStringAsFixed(1)} km away • ${p.rating?.toStringAsFixed(1) ?? "4.8"} ★',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: AppColors.stitchBlue, size: 20),
                  onPressed: () => _launchCall(p.phoneNumber),
                ),
                IconButton(
                  icon: const Icon(Icons.directions, color: Colors.greenAccent, size: 20),
                  onPressed: () => _launchDirections(p.latitude, p.longitude),
                ),
              ],
            ),
            onTap: () {
              notifier.selectProvider(p);
              setState(() => _isListView = false);
            },
          ),
        );
      },
    );
  }

  // ─── AI CLINICAL DOCTOR MATCHING MODAL ────────────────────────────────────
  void _showAiTriageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(nearbyCareNotifierProvider);
            final triage = state.aiTriageResult;

            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFFA78BFA), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'AI Doctor Matching Agent',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a detected condition to match the best nearby specialist using clinical triage.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Preset condition chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _conditionActionChip('Melanoma / Mole (94%)', 'Melanoma', 0.94),
                      _conditionActionChip('Atopic Eczema (88%)', 'Eczema', 0.88),
                      _conditionActionChip('Psoriasis Plaque (82%)', 'Psoriasis', 0.82),
                      _conditionActionChip('Pediatric Rash (86%)', 'Pediatric Rash', 0.86),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (state.isAiMatching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF7C3AED)),
                            SizedBox(height: 12),
                            Text(
                              'Agent analyzing clinical severity & querying specialists...',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (triage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: triage.triageLevel == 'URGENT'
                            ? Colors.redAccent.withValues(alpha: 0.15)
                            : Colors.blueAccent.withValues(alpha: 0.15),
                        border: Border.all(
                          color: triage.triageLevel == 'URGENT' ? Colors.redAccent : Colors.blueAccent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: triage.triageLevel == 'URGENT' ? Colors.redAccent : Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  triage.triageLevel,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recommended: ${triage.targetSpecialty}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            triage.clinicalUrgencyNote,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Top Doctor Card
                    if (triage.topDoctorRecommendation != null) ...[
                      const Text(
                        'Top Recommended Specialist',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildTopDoctorMiniCard(triage.topDoctorRecommendation!, ctx),
                    ],
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _conditionActionChip(String label, String condition, double conf) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: const Color(0xFF1E293B),
      side: const BorderSide(color: Color(0xFF334155)),
      onPressed: () {
        ref.read(nearbyCareNotifierProvider.notifier).triggerAiDoctorMatch(
              condition: condition,
              confidence: conf,
            );
      },
    );
  }

  Widget _buildTopDoctorMiniCard(DoctorRecommendation rec, BuildContext sheetCtx) {
    final doc = rec.doctor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage: NetworkImage(doc.profileImageUrl),
                onBackgroundImageError: (e, s) {},
                child: const Icon(Icons.person, size: 20, color: Colors.white70),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${doc.specialty} • ${doc.clinicName}',
                      style: const TextStyle(color: AppColors.stitchBlue, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rec.matchScore}% Match',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rec.clinicalReasoning,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Fee: ₹${doc.consultationFee.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  ref.read(nearbyCareNotifierProvider.notifier).selectDoctor(doc);
                  _safeMoveMap(doc.latitude, doc.longitude, 15.0);
                },
                icon: const Icon(Icons.check, size: 14),
                label: const Text('View on Map', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stitchBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchDirections(double lat, double lng) async {
    try {
      await launchUrl(
        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  Future<void> _launchCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}'));
    } catch (_) {}
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.stitchBlue : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.stitchBlue : const Color(0xFF334155),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterPill(String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
