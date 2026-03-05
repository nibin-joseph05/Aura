import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';

class LiveMapWidget extends StatefulWidget {
  final List<Map<String, double>> points;
  final double height;

  const LiveMapWidget({super.key, required this.points, this.height = 250});

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  late final MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isMapReady &&
        widget.points.isNotEmpty &&
        widget.points != oldWidget.points) {
      _fitMap();
    }
  }

  void _fitMap() {
    if (!_isMapReady || widget.points.isEmpty) return;

    final latLngs = widget.points
        .map((p) => LatLng(p['lat']!, p['lng']!))
        .toList();
    final bounds = LatLngBounds.fromPoints(latLngs);

    if (bounds.northEast.latitude == bounds.southWest.latitude &&
        bounds.northEast.longitude == bounds.southWest.longitude) {
      final p = bounds.northEast;
      bounds.extend(LatLng(p.latitude - 0.005, p.longitude - 0.005));
      bounds.extend(LatLng(p.latitude + 0.005, p.longitude + 0.005));
    }

    try {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    } catch (e) {
      debugPrint('[LiveMapWidget] fitCamera error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_searching,
                size: 40,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Acquiring location...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final latLngs = widget.points
        .map((p) => LatLng(p['lat']!, p['lng']!))
        .toList();
    LatLngBounds bounds = LatLngBounds.fromPoints(latLngs);

    if (bounds.northEast.latitude == bounds.southWest.latitude &&
        bounds.northEast.longitude == bounds.southWest.longitude) {
      final p = bounds.northEast;
      bounds.extend(LatLng(p.latitude - 0.005, p.longitude - 0.005));
      bounds.extend(LatLng(p.latitude + 0.005, p.longitude + 0.005));
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(40),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            initialCenter: latLngs.isNotEmpty ? latLngs.first : LatLng(0, 0),
            initialZoom: latLngs.isNotEmpty ? 15.0 : 2.0,
            onMapReady: () {
              if (mounted) {
                setState(() => _isMapReady = true);
                _fitMap(); // Initial fit once ready
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.aura_app',
            ),
            if (latLngs.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: latLngs,
                    color: AppColors.accent,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: latLngs.first,
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                if (latLngs.length > 1)
                  Marker(
                    point: latLngs.last,
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
