import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'theme_colors.dart';
import 'dart:ui';
import 'live_map_widget.dart';
import 'location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleServiceScreen extends StatefulWidget {
  const ScheduleServiceScreen({super.key});

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final int _maxLength = 500;

  final List<String> _commonIssues = const [
    'Septic Overflow',
    'Foul Odor / Amoy',
    'Full Tank / Barado',
    'Slow Drainage',
    'Gurgling Sounds',
    'Backflow',
    'Routine Desludging',
    'Emergency Pumping',
  ];

  final Set<String> _selectedIssues = {'Septic Overflow', 'Foul Odor / Amoy'};

  bool _showSuccessModal = false;
  LatLng? _selectedLocation;
  String _locationStatus = 'Detecting your location...';

  Future<void> _detectServiceLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _selectedLocation = position == null
            ? null
            : LatLng(position.latitude, position.longitude);
        _locationStatus = position == null
            ? 'Turn on Location to geo-tag this service request.'
            : 'Service location detected and geo-tagged.';
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _locationStatus =
              'Allow location permission to geo-tag this request.',
        );
      }
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleIssue(String issue) {
    setState(() {
      if (_selectedIssues.contains(issue)) {
        _selectedIssues.remove(issue);
      } else {
        _selectedIssues.add(issue);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIssues.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.7),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: context.appText,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withValues(alpha: 0.7),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      'Request',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.appText,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Schedule Service',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in the details below to request a professional desludging team to your location.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: context.appMutedText.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _sectionLabel(
                      context,
                      Icons.location_on,
                      'SERVICE LOCATION',
                    ),
                    const SizedBox(height: 8),
                    _buildMapPicker(),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Exact service address',
                        hintText: 'House no. and street, Brgy. Hulo, Mandaluyong City',
                        prefixIcon: const Icon(Icons.home_outlined),
                        helperText: 'Include house/street number, barangay, and city.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _selectedLocation == null
                              ? Icons.location_disabled_outlined
                              : Icons.location_on,
                          size: 16,
                          color: _selectedLocation == null
                              ? context.appMutedText
                              : context.appAccent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locationStatus,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appMutedText,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _detectServiceLocation,
                          child: const Text('Retry'),
                        ),
                        IconButton(
                          tooltip: 'Open in Maps',
                          onPressed: _selectedLocation == null
                              ? null
                              : _openSelectedLocation,
                          icon: const Icon(Icons.open_in_new, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _sectionLabel(context, null, 'DESCRIBE YOUR ISSUE'),
                    const SizedBox(height: 8),
                    _buildIssueTextField(),
                    const SizedBox(height: 12),
                    _buildCommonIssues(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    Text(
                      'By submitting, you agree to our Service Terms and local environmental regulations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: context.appMutedText,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(left: 16, right: 16, bottom: 16, child: _buildBottomNav()),
          if (_showSuccessModal) _buildSuccessModal(),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, IconData? icon, String text) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: context.appMutedText),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: context.appMutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildMapPicker() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12562B).withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LiveMapWidget(
              requestLocation: true,
              onLocationChanged: (position) {
                if (!mounted) return;
                setState(() {
                  _selectedLocation = LatLng(
                    position.latitude,
                    position.longitude,
                  );
                  _locationStatus = 'Service location detected and geo-tagged.';
                });
              },
              onLocationSelected: (point) {
                LocationService.saveCoordinates(
                  point.latitude,
                  point.longitude,
                );
                setState(() {
                  _selectedLocation = point;
                  _locationStatus =
                      'Location adjusted manually and ready to geo-tag.';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSelectedLocation() async {
    final location = _selectedLocation;
    if (location == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps on this device.')),
      );
    }
  }

  Widget _buildIssueTextField() {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appBorder),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _issueController,
            maxLength: _maxLength,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 16, height: 1.5, color: context.appText),
            decoration: InputDecoration(
              hintText:
                  'Describe the issue with your septic tank or environmental concern...',
              hintStyle: TextStyle(color: context.appMutedText),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              counterText: '',
            ),
          ),
          Positioned(
            right: 16,
            bottom: 8,
            child: Text(
              '${_issueController.text.length}/$_maxLength',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: context.appMutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonIssues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: context.appAccent),
                const SizedBox(width: 4),
                Text(
                  'COMMON ISSUES (TAP TO ADD)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _clearSelection,
              child: Text(
                'Clear selection',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.appAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonIssues.map((issue) {
            final selected = _selectedIssues.contains(issue);
            return GestureDetector(
              onTap: () => _toggleIssue(issue),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? context.appAccent
                      : context.appSurfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? context.appAccent : context.appBorder,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF006D38,
                            ).withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? Icons.check : Icons.add,
                      size: 14,
                      color: selected
                          ? context.appOnAccent
                          : context.appMutedText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      issue,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected ? context.appOnAccent : context.appText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_selectedLocation == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Allow location access before continuing.'),
              ),
            );
            _detectServiceLocation();
            return;
          }
          Navigator.pushNamed(context, '/upload-images');
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.appAccent,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12562B).withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Click here to proceed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.appOnAccent,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: context.appOnAccent, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 1, overlay: true);
  }

  Widget _buildSuccessModal() {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: GestureDetector(
        onTap: () => setState(() => _showSuccessModal = false),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.appBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 40,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: context.appAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 36,
                        color: context.appAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Request Sent',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Team Alpha has been dispatched and will arrive within 24 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: context.appMutedText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _showSuccessModal = false);
                          Navigator.of(context).pushNamed('/live-tracking');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appAccent,
                          foregroundColor: context.appOnAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Track Arrival',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
