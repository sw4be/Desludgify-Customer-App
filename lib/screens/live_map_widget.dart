import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as embedded_map;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as geo;

import 'location_service.dart';
import 'theme_colors.dart';

class LiveMapWidget extends StatefulWidget {
  final double? truckLat;
  final double? truckLng;
  final bool requestLocation;
  final ValueChanged<Position>? onLocationChanged;
  final ValueChanged<geo.LatLng>? onLocationSelected;

  const LiveMapWidget({
    super.key,
    this.truckLat,
    this.truckLng,
    this.requestLocation = false,
    this.onLocationChanged,
    this.onLocationSelected,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  final embedded_map.MapController _embeddedMapController =
      embedded_map.MapController();
  geo.LatLng? _userLocation;
  String? _error;
  bool _loading = true;
  bool _locationRequestInProgress = false;

  static const _fallback = geo.LatLng(14.5995, 120.9842);

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  geo.LatLng? get _truckLocation =>
      widget.truckLat != null && widget.truckLng != null
      ? geo.LatLng(widget.truckLat!, widget.truckLng!)
      : null;

  Future<void> _loadUserLocation() async {
    if (_locationRequestInProgress) return;
    _locationRequestInProgress = true;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final position =
          await (widget.requestLocation
                  ? LocationService.getCurrentPosition()
                  : LocationService.getPositionIfAllowed())
              .timeout(const Duration(seconds: 15), onTimeout: () => null);
      if (!mounted) return;

      if (position == null) {
        setState(() {
          _userLocation = null;
          _loading = false;
          _error = 'Location off or denied. Enable permission, then retry.';
        });
      } else {
        final location = geo.LatLng(position.latitude, position.longitude);
        widget.onLocationChanged?.call(position);
        setState(() {
          _userLocation = location;
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userLocation = null;
        _loading = false;
        _error = 'Could not get your location. Showing the default map.';
      });
    } finally {
      _locationRequestInProgress = false;
    }
  }

  void _selectLocation(geo.LatLng location) {
    setState(() {
      _userLocation = location;
      _error = null;
    });
    widget.onLocationSelected?.call(location);
  }

  Future<void> _centerOnUser() async {
    await _loadUserLocation();
    final location = _userLocation;
    if (location != null) {
      _embeddedMapController.move(location, 16);
    }
  }

  Widget _buildEmbeddedMap(geo.LatLng user, geo.LatLng? truck) {
    return embedded_map.FlutterMap(
      mapController: _embeddedMapController,
      options: embedded_map.MapOptions(
        initialCenter: user,
        initialZoom: 14,
        onTap: (_, point) => _selectLocation(point),
        interactionOptions: const embedded_map.InteractionOptions(
          flags: embedded_map.InteractiveFlag.all,
        ),
      ),
      children: [
        embedded_map.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.clientapp',
          maxZoom: 19,
        ),
        embedded_map.MarkerLayer(
          markers: [
            if (_userLocation != null)
              embedded_map.Marker(
                point: user,
                width: 48,
                height: 48,
                child: Icon(
                  Icons.location_on,
                  color: context.appAccent,
                  size: 42,
                ),
              ),
            if (truck != null)
              embedded_map.Marker(
                point: truck,
                width: 52,
                height: 52,
                child: Icon(
                  Icons.local_shipping,
                  color: context.appText,
                  size: 34,
                ),
              ),
          ],
        ),
        const embedded_map.RichAttributionWidget(
          attributions: [
            embedded_map.TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = _userLocation ?? _fallback;
    final truck = _truckLocation;

    return Column(
      children: [
        if (_error != null)
          Material(
            color: context.isDarkMode
                ? const Color(0xFF3A1F22)
                : const Color(0xFFFFDAD6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: context.isDarkMode
                        ? const Color(0xFFFFB4AB)
                        : const Color(0xFFBA1A1A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.isDarkMode
                            ? const Color(0xFFFFB4AB)
                            : const Color(0xFFBA1A1A),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadUserLocation,
                    child: Text(
                      'Retry',
                      style: TextStyle(color: context.appAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              _buildEmbeddedMap(user, truck),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: 'center-on-user',
                  onPressed: _centerOnUser,
                  tooltip: 'Use my location',
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
